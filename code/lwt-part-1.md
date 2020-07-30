---
title: Lwt introduction/tutorial Part 1 of 2
...

[Lwt](http://ocsigen.org/lwt) ([code](https://github.com/ocsigen/lwt/)) is a library for writing concurrent programs in OCaml.
It is used in multiple OCaml projects including
[Unison](https://www.cis.upenn.edu/~bcpierce/unison/) ([code](https://github.com/bcpierce00/unison)),
[Ocsigen](https://ocsigen.org/home/intro.html) ([code])(https://github.com/ocsigen/)),
[Mirage](https://mirage.io/) ([code](https://github.com/mirage/)) and
[Tezos](https://tezos.com/) ([code](https://gitlab.com/tezos/tezos/)).

I recently ran some internal training at [Nomadic Labs](https://nomadic-labs.com/) about Lwt: What it is? How to use it effectively? What to watch out for? Etc.
Below is a write-up of that training.
It covers: basic concepts (promises, states), simple use, description of the internals, and advanced use (cancellation and exception propagation).


# Prelude

Lwt is a library.
You can install it as an `opam` package named `lwt`.
Installing `base-unix` before is recommended to get access to operating system wrappers.

```
opam install base-unix
opam install lwt
```

The `lwt` package installs the `lwt` library (and `lwt.unix` sub-library if you have installed `base-unix`) that you can refer to in your `dune` build files.

```
(library
 (name ..)
 (public_name ..)
 (libraries lwt)
 (flags (:standard)))
```

Declaring a dependence to the `lwt` library in your `dune` build file gives you access to the `Lwt` module.

Lwt, `lwt`, `lwt`, `Lwt`


# Lwt as a black-box

Lwt is a library for creating and manipulating *promises*.

```
(** The type of a promise for a value of type ['a]. *)
type 'a t
```

A promise is a cell that may hold a value or an exception.
Moreover, a promise that doesn't hold a value or an exception, can change to hold a value or an exception.

A promise that doesn't hold anything is said to be *pending*.
When a promise that holds nothing changes to hold something it is said to *resolve*, to *be resolved*, or to *become resolved*.
In particular, a promise that resolves to hold a value is said to *fulfill*, to be *fulfilled*, or to *become fulfilled* whereas a promise that resolves to hold an exception is said to *reject*, to be *rejected*, or to *become rejected*.

The Lwt library provides a way to introspect the state of promise:

```
type 'a state =
  | Return of 'a
  | Fail of exn
  | Sleep

val state: 'a t -> 'a state
```

# A necessary side-note on terminology and backwards compatibility

The Lwt library is old.
It was originally written by [Jérôme Vouillon](https://www.irif.fr/~vouillon/) as a support library for the [Unison](https://www.cis.upenn.edu/~bcpierce/unison/) file synchroniser.
It became a core component of the [Ocsigen](https://ocsigen.org/home/intro.html) project which took care of the bulk of maintenance.
It continued to progress and gain a wider adoption in the OCaml community.

The Lwt library is old and carries a lot of historical baggage.
The most noticeable bagage is the dated terminology (in the interface and, to a lesser extent, in the documentation).
For example, the different variants for the type `state` (`Return`, `Fail` and `Sleep`) are based on an old description of Lwt as a thread library.
In fact, “Lwt” stands for Light-Weight Threads.

There are no threads in Lwt.
There are only promises.
But old descriptions of the library will occasionally contain dated references to threads.
And the interface of the library, because of backwards compatibility, is full of those references.


# Analogy

A promise, as a cell that may hold nothing, a value, or an exception, is similar to a combination of other types:

```
'a Lwt ≈ ('a, exn) result option ref
```

This gives the following similarity table:

`p: 'a t`   | `('a, exn) result option ref`   | `state p`
------------+---------------------------------+---------------
pending     | `None`                          | `Sleep`
fulfilled   | `Some (Ok _)`                   | `Return _`
rejected    | `Some (Error _)`                | `Fail _`

Note that this is just a similarity, not an equivalence.
The main difference is that a promise can only ever transition from holding nothing to holding either a value or an exception.


# Creating and combining promises

## Basic monadic interface

`Lwt.return: 'a -> 'a t`  
`return v` evaluates immediately to a promise of type that is already fulfilled with the value `v`.
This is the most basic way to create a promise.
By itself it is fairly useless, but it turns out to be essential as a building block for more complicated promises.
In particular, it fits as part of the Monadic interface to Lwt.

`Lwt.bind: 'a t -> ('a -> 'b t) -> 'b t`  
`bind p f` evaluates to a promise, the state of which depends on the call arguments:

- If `p` is fulfilled to `x`, then `bind p f` evaluates to the promise `f x`.
- If `p` is rejected with `exc`, then `bind p f` evaluates to a promise rejected with `exc`.
- If `p` is pending, then `bind p f` evaluates to a promise `p'` that is pending.
  When `p` resolves, it has the following effects:

    - if `p` is rejected, so is `p'`, and
    - if `p` is fulfilled with `x`, then `p'` becomes behaviourally identical to the promise `f x`.

Note that the notion of “becomes behaviourally identical to” is vague.
We give more details in Part 2 of this tutorial.
In the mean time, it means that the promise resolve at the same time and with the same value/exception.

`Lwt.( >>= ) : 'a t -> ('a -> 'b t) -> 'b t`  
The infix operator `>>=` is an alias for `bind`.
It is provided to allow for the use of the monadic style.

```
open_file name >>= fun handle ->
read_lines handle >>= fun lines ->
keep_matches pattern lines >>= fun lines ->
print_lines lines >>= fun () ->
..
```

`Lwt.fail: exn -> 'a t`  
`fail exc` evaluates immediately to a promise that is already rejected with the exception `exc`.
Note that, as we discuss below, the use of `fail` should be reserved for populating data-structures (and other similar tasks) but that, within one of Lwt's function, the use  of `raise` is preferred.

## Resolvers

`Lwt.task: unit -> 'a t * 'a u`  
`task ()` evaluates immediately to a pair `(p, r)` where `p` is a pending promise and `r` is its associated *resolver*.
For historical reasons, the resolver is often referred to as the wakener.

`Lwt.wakeup: 'a u -> 'a -> unit`  
`wakeup r v` causes the pending promise associated to the resolver `r` to become fulfilled with the value `v`.
If the promise associated to `r` is already resolved, the call raises `Invalid_argument` – except if it is cancelled, which we will talk about bellow.

`Lwt.wakeup_exn: 'a u -> exn -> unit`  
`wakeup r exc` causes the pending promise associated to the resolver `r` to become rejected with the exception `exc`.
If the promise associated to `r` is already resolved, the call raises `Invalid_argument` – except if it is cancelled, which we will talk about bellow.

The `task` primitive is very powerful.
It can be used to create never-resolving promises: `let never, _ = task ()`
It can also be used to make your own control structures.
For example, here is a function to pick the result from whichever of two promises is fulfilled first:

```
let first a b =
  let p, r = task () in
  let f v = match state p with
    | Sleep -> wakeup r v; return ()
    | _ -> return () in
  let _ : unit t = a >>= f in
  let _ : unit t = b >>= f in
  p
```

Many of the control structures that could be written by hand using `task` and `wakeup` are common enough to earn a place in the `Lwt` module.


## Common combinators

`Lwt.join: unit t list -> unit t`  
`join ps` is a promise that resolves when all the promises in `ps` have done so.
If all the promises of `ps` are already resolved when the call is made, then an already resolved promise is returned.
Note that if any of the promises is rejected, then the joined promise is also rejected (after all the other promises are resolved).
Otherwise, if all the promises are fulfilled, then the joined promise is also fulfilled.

`Lwt.all: 'a t list -> 'a list t`  
`all ps` is a promise that resolves when all the promises in `ps` have done so.
If all the promises of `ps` are already resolved when the call is made, then an already resolved promise is returned.
Note that if any of the promises is rejected, then the `all`-promise is also rejected (after all the other promises are resolved).
Otherwise, if all the promises are fulfilled, then the `all`-promise is also fulfilled.
The value that `all ps` is fulfilled with is a list of the values that the promises of `ps` are fulfilled with.
The order of the values is preserved.

`Lwt.both: 'a t -> 'b t -> ('a * 'b) t`  
`both p q` is a promise that resolves when both `p` and `q` have done so.
If both `p` and `q` are already resolved when the call is made, then an already resolved promise is returned.
Note that if either of `p` or `q` is rejected, then the `both`-promise is also rejected (after both `p` and `q` are resolved).
Otherwise, if both `p` and `q` are fulfilled, then the `both`-promise is also fulfilled.

`Lwt.choose: 'a t list -> 'a t`  
`choose ps` is a promise that resolves as soon as one of the promises in `ps` has done so.
If one or more of the promises in `ps` are already resolved when the call is made, then an already promise is returned.
Note that if the first promise to resolve is rejected, so is the choice promise.
And vice-versa if the first promise to resolve is fulfilled, so is the choice promise.
If multiple promises resolve at the same time (the condition for which we will discuss later), then a promise is chosen arbitrarily.


# Exception catching

`Lwt.catch: (unit -> 'a t) -> (exn -> 'a t) -> 'a t`  
The function `catch` attaches a handler to a given promise.
The handler is called if the promise is rejected.
This gives an oportunity to transform a rejection into a fulfillement.
Typical use is along the lines of:

```
let load_setting key =
  catch
    (fun () ->
      find_setting key >>= fun value ->
      let value = normalize value in
      if not (is_valid key value) then
        raise (Config_error "Invalid value");
      log "CONF: %s-%s" key value >>= fun () ->
      record_setting key value >>= fun () ->
      return value
    )
    (function
      | Not_found ->
        log "CONF: no value for %s" key >>= fun () ->
        return (default_setting key)
      | Invalid_argument msg ->
        log "CONF: invalid value for %s" key >>= fun () ->
        raise (Config_error "Cannot normalise value")
      | exc -> raise exc)
```

In this expression, the promise simply loads some information and does some minor processing on the value.
The handler treats different errors differently:
It recovers from the `Not_found` exception by providing a default value.
It transform `Invalid_argument` into a different exception.
It reraises any other (unexpected) exception.

Note also that both the promise and the exception handler use the `raise` primitive.

All throughout Lwt, when a function `f` takes, as argument, a function `g` that returns a promise, then calls to `g` within the body of `f` are wrapped into a `try`-`with` construct to transform exceptions into rejections.
E.g., in `bind p f` the application of `f` (to the value that `p` is fulfilled with) is protected by a `try`-`with`.
This is why, within a function that is passed to an Lwt primitive, it is safe to use `raise` instead of `fail`.

It is *possible* to use `fail` instead, but, as mentioned earlier, `raise` is *preferred*.
This is because `raise` records the location of the exception, providing additional information that is useful for debugging.


`Lwt.try_bind : (unit -> 'a t) -> ('a -> 'b t) -> (exn -> 'b t) -> 'b t`  
The function `try_bind` takes a promise and two handler: one for fulfilment and one for rejection.
More specifically, `try_bind f hf hr` behaves as `bind (f ()) hf` if `f ()` is fulfilled and as `catch (f ()) hr` if `f ()` is rejected.

`Lwt.finalize : (unit -> 'a t) -> (unit -> unit t) -> 'a t`  
The function `finalize` is similar to `try_bind` except it takes a single handler which is called when the given promise resolves.
Unlike `try_bind`, the handler in `finalize` cannot determine whether the promise was fulfilled or rejected.


# Breaking promises and pausing

`Lwt_main.run: 'a t -> 'a`  
`run p` is an expression that blocks until the promise `p` is resolved.
If `p` is already resolved when the call is made, then the expression does not block and returns a value immediately.
If `p` is fulfilled with the value `v`, the `run p` expression evaluates to the value `v`.
If `p` is rejected with the exception `exc`, the `run p` expression raises the exception `exc`.

The function `run` is intended to be used at the top-level of a program.
It forces the program to block, delaying `exit`, until the given promise is resolved.

Note that the `Lwt_main` module is part of the `lwt.unix` sub-library which depends on the `base-unix` package.
Different environments may provide alternatives to that function.

`Lwt.pause: unit -> unit t`  
`pause ()` is a pending promise which is resolved after all the other promises have been given a chance to progress towards resolution.
In Part 2 of this introduction/tutorial, we will talk in more details about the scheduling in Lwt, including the precise scheduling of `pause`.
In the mean time, from a practical point of view, `pause` introduces explicit points in the program where a promise is pending for a short time.
Consider the following program and the importance of `pause`: without it, the call to `count` loops forever consuming all the CPU and the value `counting` never evaluates to anything.

```
let r = ref 0 ;;
let rec count () =
  pause () >>= fun () ->
  incr r;
  count () ;;
let rec exit_on n =
  if !r >= n then
    raise Exit
  else begin
    pause () >>= fun () ->
    exit_on n
  end ;;
let main () =
  let counting = count () in
  let exiting = exit_on 10 in
  choose [ counting ; exiting ] ;;
```

Note that `return` and `bind` are no substitute for `pause`.
Specifically, the below variant of the `count` function loops forever.
This is because `Lwt.return ()` evaluates to an already resolved promise which causes `Lwt.( >>= )` to evaluates its right-hand side argument immediately.

```
(* This is incorrect: it loops forever *)
let rec count () =
  incr r;
  Lwt.return () >>= fun () ->
  count () ;;
```

`Lwt_main.yield: unit -> unit t`  
The function `yield` is a synonym for `pause`.
It exists for historical reasons: `pause` was added later as a backend-independent yielding mechanism.
There might be minor differences between `pause` and `yield`, but no difference that you should rely on.


# Part 2

There are other interesting features of Lwt.
And there are also features we have mentioned that we could not explain (cancelation) or not explain well (pause).
Unfortunately, to have a good understanding of those features, a good undrstanding of the inner workings of Lwt is required.
Part 2 of this introduction/tutorial provides details about the internal machinery, allowing us to understand the advanced features of Lwt.

[→ Onwards to part 2](/code/lwt-part-2.html)
