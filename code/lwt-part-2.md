---
title: Lwt introduction/tutorial Part 2 of 2
...

[← Back to part 1](/code/lwt-part-1.html)  

In order to understand the advanced features of Lwt, it is necessary to understand the internals of Lwt: how promises are created, stored, resolved, etc.
This page delves into those details.
It assumes familiarity with the basic concepts of Lwt covered in [Part 1](/code/lwt-part-1.html).

To be more precise, this part of the tutorial gives an acceptably precise working model of Lwt, but not an exact one.
In particular, we do not mention any parts that are not necessary for the understanding of the user-facing features.

## A simple model of a promise

To start with, consider that a promise is simply a cell for a value.
The cell can take different values that map almost exactly on the `state` type.
The actual type of promises in our only-slightly-simplified model is as follows:

```
type 'a internal_state =
  | Fulfilled of 'a
  | Rejected of exn
  | Pending of 'a pending

type 'a t = { mutable state : internal_state }
```

Basically, internally, Lwt maintains its promise similar to a `state` cell, but with added information for the pending promises.
We give more details on the added information on a by-need basis below.
For now suffice to say that `pending` contains the information that Lwt needs in order to handle all that can happen to a still-to-be-resolved promise.

We can already think of some of the simpler primitives as code over this simplified model:

```
let return v = { state = Fulfilled v }
let fail exc = { state = Rejected exc }
let state p = match p.state with
  | Fulfilled v -> Return v
  | Rejected exc -> Fail exc
  | Pending _ -> Sleep
```

But we cannot write much more at this point.
So we refine the model and expand on the definition of `pending`.


## Callbacks

`Lwt.on_any: 'a t -> ('a -> unit) -> (exn -> unit) -> unit`  
If `p` is pending, it attaches the callbacks to `p`;
consequently, when `p` resolves, either of `hf` or `hr` is called depending if the promise is fulfilled or rejected.
If `p` is already resolved, `on_any p hf hr` calls either `hf` or `hr` immediately.

### Internal representation

This is achieved by attaching callbacks to pending promises.
When Lwt modifies the internal state of a promise from `Pending` to either `Fulfilled` or `Rejected`, Lwt also calls all of the attached callbacks.
As a first approximation, we simply declare:

```
type 'a pending = {
  mutable when_fulfils: ('a -> unit) list;
  mutable when_rejects: (exc -> unit) list;
  ..
}
```

And Lwt calls the callbacks when it changes the state of the promise.
For example, here is the implementation of `task` and `wakeup` in our simplified model.

```
type 'a u = 'a t
let task () =
  let p = { state = Pending .. } in
  (p, p)
let wakeup p v =
  match p.state with
  | Pending { when_fulfils; } ->
      p.state <- Fulfilled v;
      List.iter (fun f -> f v) when_fulfils
  | _ -> raise (Invalid_argument "..")
let wakeup_exn p exc =
  match p.state with
  | Pending { when_rejects; } ->
      p.state <- Rejected exc;
      List.iter (fun f -> f exc) when_rejects
  | _ -> raise (Invalid_argument "..")
```

The internals are a little bit more complicated than that, in particular with respect to error management.
But the general idea is as above.

### Other explicit callbacks

There are variants of `on_any` that attach different callbacks.
Their semantics can be inferred from their name and type signature, but we list them here anyway.

`Lwt.on_success: 'a t -> ('a -> unit) -> unit`  
`on_success p h` calls `h` when `p` is fulfilled.
If `p` is already fulfilled, it calls `h` immediately.
Nothing happens if `p` is already rejected, is eventually rejected, or is never resolved.

`Lwt.on_failure: 'a t -> (exc -> unit) -> unit`  
`on_failure p h` calls `h` when `p` is rejected.
If `p` is already rejected, it calls `h` immediately.
Nothing happens if `p` is already fulfilled, is eventually fulfilled, or is never resolved.

`Lwt.on_termination: 'a t -> (unit -> unit) -> unit`  
`on_termination p h` calls `h` when `p` is resolved.
If `p` is already resolved, it calls `h` immediately.
Nothing happens if `p` is never resolved.


### Implicit callbacks

Lwt also uses callbacks to implement promise combinators such as `bind`.
To give an idea of how, here is an implementation in the simplified model.
The details are different, notably with respect to error management and some optimisations, but the gist is similar: return a pending promise that is resolved by callbacks attached to other promises.

```
let bind p f =
  (* create the final promise p'' *)
  let p'', r = task () in
  (* attach callbacks to the original promise p *)
  on_any p
    (fun v ->
      (* call `f` to get the intermediate promise p' *)
      let p' = f v in
      (* attach callbacks to p' in order to resolve p'' *)
      on_any p'
        (fun v -> wakeup r v)
        (fun exc -> wakeup_exn r exc))
    (fun exc -> wakeup_exn r exc);
  (* return the final promise *)
  p''
```

There are other uses of callbacks (in `join`, `choose`, etc.), but studying them does not provide more insight into the inner workings of Lwt.
One of the thing to take from this model, one of the things that this model is accurate enough to describe, is that Lwt does not maintain a full list of all the existing promises in a data-structure.

For example, in the `bind` above, the final promise `p''` is created, then a reference to it is kept by the callbacks attached to `p`, and then it is returned.
Lwt does not keep `p''` in a list/table/map of promises.
There are some exceptions to this which we mention below.


## Cancellation

`Lwt.Canceled: exn`  
The `Canceled` exception is used by Lwt to handle promise cancellation.
The `Canceled` exception is treated differently than others in several of the Lwt primitives.
For example, `wakeup` will fail if the associated promise is already resolved, except if it is rejected with `Canceled`.
As a result, the following code does not raise an exception – but it would with a different exception:

```
let _, r = task () ;;
wakeup_exn r Canceled ;;
wakeup r 0 ;;
```

`Lwt.cancel: 'a t -> unit`  
`cancel p` causes `p` to be rejected with `Canceled`.
Except that sometimes it does not do that, and sometimes it does much more than that.

### Cancelable, not cancelable

Some promises are cancelable (calling `cancel` on them causes them to be rejected with `Canceled`) others are not (calling `cancel` on them is a no-op).
For example, consider the difference between `task` and `wait`.

`Lwt.wait: unit -> 'a t * 'a u`  
`wait ()` is similar to `task ()` except that the returned promise is not cancelable.
Calling `cancel` on the promise created by `wait` has no effect.

There is no way to test whether a promise is cancelable – besides actually canceling it and observing a change of state.


### The semantics of simple cancellation

The specific semantics of cancellation (detailed below) are inherited from a way of thinking about threads rather than promises.
Consider the following code with uninteresting details elided:

```
let p =
  .. >>= fun .. ->
  .. >>= fun .. ->
  let .. = .. in
  let .. = .. in
  .. >>= fun .. ->
  .. >>= function
  | .. -> return ..
  | .. ->
    .. >>= fun .. ->
    let .. = .. in
    .. >>= fun .. ->
    return ..
```

The control-flow within `p` is relatively simple: it mostly goes from line to line traversing bind operators and there is a single branching point.
The control-flow is simple enough that it is easy to think about `p` as a “thread”: a series of instructions that execute in relative independence to the rest of the program.
Or, slightly more but not entirely accurate, you can think of `p` as a promise and the expression that `p` is bound to as a thread which eventually resolves `p`.
Either way, the `cancel` function works well on the “thread” `p`: it interrupts the thread at whatever point of its execution it currently is.

The correct, thread-less, description is that `cancel p` finds whichever of the intermediate promise of `p` is currently pending and rejects it with `Canceled`.

### Set up for cancellation propagation

In order to find the pending intermediate promise of `p`, Lwt stores additional information in pending promises.
Specifically, it stores a list of promises to propagate the cancellation to.

```
type cancelation = Self | Others of 'a t list
type pending = {
  ..
  cancelation: cancelation;
}
```

The promise combinators simply set the `cancelation` field of `pending` when they create the promise.
For example, `task` and `wait` work as follows.

```
let task () =
  let p =
    { state =
        Pending {
          ..;
          cancelation = Self; }
    }
  in
  (p, p)
let wait () =
  let p =
    { state =
        Pending {
          ..;
          cancelation = Others []; }
    }
  in
  (p, p)
```

And `bind` actually performs more legwork than previously shown.

```
let bind p f =
  match p.state with
  | Fulfilled v -> f v
  | Rejected exc -> Rejected exc
  | Pending pending ->
      let p'' =
        { state =
            Pending {
              ..;
              cancelation = Others [ p ]; }
        }
      in
      .. (* set up callbacks to resolve p'' *)
      p''
```

And more complex combinators such as `choose` and `join` include multiple promises in their `Others` cancellation field.

### Propagating cancellation

Using this additional information, Lwt can find the pending promises that a given promise depends on.

```
let rec cancel p =
  match p.state with
  | Fulfilled _ -> ()
  | Rejected _ -> ()
  | Pending { cancelation = Self } ->
      wakeup_exn p Canceled
  | Pending { cancelation = Others ps } ->
      List.iter cancel ps
```

This is a mock implementation on the simplified model.
In particular, the cancellation works in two separate phases: collect all promises that the cancellation affects, and then trigger all the cancellations.
This is to avoid subtle bugs where some cancellation has side-effects that modify the state of some of the not yet traversed promises.

### Cancellation-focused combinators

As mentioned, the semantics of `cancel` are easy to grasp for simple examples such as promises daisy-chained in a simple flow control.
On the other hand, the semantics of `cancel` on complex constructions can be difficult to understand.
In particular, cancelling a promise `p` may cancel other promises that share a common ancestor with `p`.

In order to avoid unwanted side-effects, Lwt provides a few combinators to tweak the behaviour of the cancellation mechanism.
Specifically, these combinators introduce new promises with carefully crafted `cancelation` fields that cause the propagation of cancellation to behave in the desired way.

`Lwt.protected: 'a t -> 'a t`  
`protected p` is a promise `pp` that is similar to `p`: it has the same state and it resolves similarly.
However, when the cancellation propagation described above reaches `pp`, then `pp` is rejected with `Canceled` but nothing happens to `p`.
In our simplified model, this is achieved by setting `pp`'s `cancelation` field to `Self`.

`Lwt.no_cancel: 'a t -> 'a t`  
`no_cancel p` is a promise `pp` that is similar to `p`: it has the same state and it resolves similarly.
However, when the cancellation propagation described above reaches `pp`, then nothing happens.
In our simplified model, this is achieved by setting `pp`'s `cancelation` field to `Others []`.


## Pausing and scheduling

As seen previously, Lwt's scheduling is eager.
Specifically, when given an already resolved promise and a function that returns an already resolved promise, `bind` returns and already resolved promise.
As a result, the user must call `pause` (or `yield`) in order to force the Lwt scheduler to give opportunities to other promises to progress towards resolution.

To achieve this, Lwt stores the pending promises created with `pause` into a global variable.
By itself, this promise can make no progress.
However, when the scheduler's main-loop is running, it resolves paused promises at each iterations.

```
let paused_promises = ref []
let pause () =
  let p = { state = Pending { .. } } in
  paused_promises := p :: !paused_promises;
  p
let rec run p =
  match p.state with
  | Fulfilled v -> v
  | Rejected exc -> raise exc
  | Pending _ ->
      let all_paused = !paused_promises in
      paused_promises := [];
      List.iter (fun p -> wakeup p ()) all_paused;
      run p
```

Note, however, that different environment have different ways to deal with paused promises.
For example, in Unix the scheduler only kicks in when a call to `Lwt_main.run` is on-going.
By contrast, in `js_of_ocaml` the scheduler is always running.
For compatibility with other environment, you cannot rely on `pause` to hold your promises pending until you call `Lwt_main.run`.

Also note that the mock scheduler above is only for building a mental model.
The specifics differ, but the core idea is there.


## OS interactions

The last part of Lwt that this tutorial covers is interaction with the operating system.
Whilst it is possible to call functions from OCaml's `Unix` module, such functions are oblivious to Lwt and may cause issues.
Most notably, these functions may block the execution of the program.

There are multiple ways to interact with the OS without blocking.
For the most common OS interactions (e.g., creating files, reading from pipes, accepting incoming connections, etc.), Lwt comes with the sub-library `lwt.unix` which includes the module `Lwt_unix` which contains Lwt-aware wrappers for the `Unix` module.

`Lwt_unix.sleep: float -> unit t`  
The promise `sleep t` is a pending promise that becomes resolved after `t` seconds have elapsed.
Note that the resolution of the promise only happens if the scheduler is running – i.e., if there is an ongoing call to `Lwt_main.run`.
If the scheduler is not running when the timer expires, then the promise is only resolved the next time the scheduler is started.

Another way to call blocking functions is to wrap them in `Lwt_preemptive.detach` (provided by `lwt.unix`) or, equivalently, in `Mwt.run` (provided by `mwt`).
This solution relies on OCaml's `Thread` module to isolate the blocking calls in a different execution context.
It is mostly useful when making calls to a third-party library that does not provide Lwt-aware system primitives.

Blocking system calls are maintained in their own global variable.
The scheduler checks these calls at each iteration, causing the process to actually sleep if none of the calls are done and no paused promises can be found.


## Part 3

The third and final part of this 2-part introduction/tutorial collects some miscellaneous remarks of little practical use.

[→ Onwards to part 3](/code/lwt-part-3.html)  
[← Back to part 1](/code/lwt-part-1.html)
