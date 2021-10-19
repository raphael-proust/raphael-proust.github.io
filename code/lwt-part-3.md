---
title: Lwt introduction/tutorial Part 3 of 2
...

[← Back to part 1](/code/lwt-part-1.html)  
[← Back to part 2](/code/lwt-part-2.html)

In this part 3 of this 2-part introduction/tutorial to Lwt, we collect a few remarks that are of lesser interest to users of Lwt.
Specifically, topics that are unimportant for building a mental model of Lwt.
We also collect addenda:

- [2020-07](#addendum-non-obvious-evaluation-order): a walkthrough of the execution of a small example program to demonstrate a potential source of bugs.


## Historical baggage

The documentation of Lwt has evolved to consistently use a sound terminology: promise, resolution, pending, etc.
This updated documentation gives a better description than the previous one.
However, whilst the documentation has evolved, the effective signature of `Lwt` (the identifiers for values, types, etc.) has been left mostly untouched for backwards compatibility.
This causes a dissonance in places such as the official documentation of `wakeup` (edited for brevity):

```
[wakeup r v] fulfills, with value [v], the pending
promise associated with resolver [r].
```

Compare with the documentation prior to big update in which it is said to act on a “sleeping” thread:

```
[wakeup t e] makes the sleeping thread [t] terminate
and return the value of the expression [e].
```

Updating the effective signature of `Lwt` has serious implication for backwards compatibility.
Doing so would probably require the introduction of a compatibility layer to allow other software to transition more easily.
And even with this compatibility layer, it is not obvious that the change would be worth it.
Of greater interest would be to update the documentation of other packages and libraries, including that of `lwt.unix`.
Indeed, another source of dissonance is when third-party libraries describe the abstraction they provide on top of Lwt in old, deprecated terms.

Anyway, bellow is what a modern interface could look like.
Note how the names match the concepts within Lwt and how named and optional parameters make some of the implicit behaviour explicit (e.g., the replacement of `task` and `wait` by a single function with a `cancelable` parameter).

```
(* BASE TYPE *)

type 'a promise
type 'a t = 'a promise

(* INTROSPECTION *)

type 'a state =
  | Fulfilled of 'a
  | Rejected of exn
  | Pending
val state: 'a t -> 'a state

(* RESOLUTION *)

type 'a resolver = 'a Lwt.u
(* note: [pending] replaces both [task] and [wait] *)
val pending: cancelable:bool -> unit -> ('a t, 'a resolver)
val resolve: ?later:unit -> 'a resolver -> ('a, exn) result -> unit
val fulfill: ?later:unit -> 'a resolver -> 'a -> unit
val reject: ?later:unit -> 'a resolver -> exn -> unit

(* OTHER INSTANTIATIONS *)

val resolved: 'a -> 'a t
val rejected: exn -> 'a t

(* COMBINATORS *)

val bind: 'a t -> ('a -> 'b t) -> 'b t
…
(* note: [any] replaces both [choose] and [pick] *)
val any: ~cancel_remaining:bool -> 'a t list -> 'a t
…
(* note [either] is the dual of [both] *)
val either: 'a t -> 'a t -> 'a t

(* CALLBACKS *)

val on_resolution: 'a t -> ('a -> unit) -> (exn -> unit) -> unit
val on_fulfillment: 'a t -> ('a -> unit) -> unit
val on_rejection: 'a t -> (exn -> unit) -> unit
…

(* MONADIC INTERFACE *)

val return: 'a -> 'a t
val ( let* ): 'a t -> ('a -> 'b t) -> 'b t
val ( >>= ): 'a t -> ('a -> 'b t) -> 'b t
```



## The ecosystem

Lwt provides a useful abstraction for handling concurrency in OCaml.
But further abstractions are sometimes necessary.
Some of these abstractions are distributed with Lwt:

`Lwt_unix` and the rest of the `lwt.unix` sub-library provide Lwt-aware interface to the operating system.
The main role of this library is to provide wrappers around potentially blocking system calls.
There is more details about it in.

`Lwt_list` (distributed with the `lwt` library) provides Lwt-aware list traversal functions.
E.g., `map_p: ('a -> 'b Lwt.t) -> 'a list -> 'b list Lwt.t` for applying a transformation to all the elements of a list concurrently.
The module takes care of synchronisation and propagating rejections.

`Lwt_stream` (distributed with the `lwt` library) provides streams: Lwt-aware lazy collections.
With streams you are given a promise of the next element rather the next element itself.

Many other abstractions are available through `opam`.
There are too many to list them all; here is one that I wrote as part of my work on Tezos:

`Lwt_pipeline` (distributed with the `lwt-pipeline` package) provides batch processing for list over multi-steps transformations.
Pipelines are assembled from steps (`('a, 'b) step`).
Steps are applied either synchronously (`sync: ('a -> 'b) -> ('a, 'b) step`) meaning that the application of the step does not yield, asynchronously-sequentially (`async_s: ('a -> 'b Lwt.t) -> ('a, 'b) step`) meaning that the application of the step may yield but that only a single element may be processed at once, or asynchronously-concurrently (`async_p: ('a -> 'b Lwt.t) -> ('a, 'b) step`) meaning that the application of the step may yield and that multiple elements may be processed concurrently.
In addition, elements that traverse the pipeline are kept in order.
Typical use looks like:

```
let p =
  cons (async_p fetch)
  @@ cons (sync parse)
  @@ cons (async_p analyse)
  @@ cons (async_s validate)
  @@ nil
run p data
```

And opam also has packages that provide Lwt-aware interfaces for servers, databases, APIs for specific services, etc.

And finally, Lwt has good support within `js_of_ocaml`.
This is not surprising considering both projects are linked to the [Ocsigen](https://ocsigen.org/home/intro.html) project.
The package [`js_of_ocaml-lwt`](https://ocsigen.org/js_of_ocaml/3.1.0/manual/lwt) even provides primitives for interacting with browser events (mouse button clicks, keyboard key presses, elements focus change, etc.).


## Warnings about this tutorial

It is important to realise that the simplified model of Part 2 is a simplified model.
It does not include all the details of the real implementation.

An important difference is the existence of proxy promises: when a promise is marked as being equivalent to another promise.
Proxy promises are useful internally for performance.
Specifically, in `bind` (and other similar functions), proxying can be used to avoid having to attach callbacks and cancellation links between the intermediate promise and the final promise.

So, whilst the model of Part 2 is useful to discuss the coarse semantics of Lwt, it is not sufficient to discuss the all the finer aspects of the semantics, nor any of the other aspects of Lwt such as performance or memory consumption.


-----------------------------------

## Addendum: non-obvious evaluation order

Below is a simple example program.
The program is interspersed with print statements (in the form of `print_endline`) to show the evaluation order.
These print statements stand in for any kind of side-effect that might happen in a real program.

The example program highlights some of the non-trivial behaviours that Lwt can exhibit.
The most interesting of these exhibited behaviours is an interaction of `bind` with `task`/`wakeup` leading to interleaving in the execution.

After the example program, we give a detailed walkthrough of the execution.
This walkthrough highlights and explains the behaviours of the program.


### The code

This is the example program.

```
let stop_point, wakey = Lwt.task ()

let side_promise, wakey =
  print_endline "Side 1";
  let* () = stop_point (* wait for event *) in
  print_endline "Side 2";
  let* () = Lwt.pause () (* wait one iteration *) in
  print_endline "Side 3";
  let* () = Lwt.pause () (* wait another iteration *) in
  print_endline "Side 4";
  Lwt.return ()

let main_promise =
  print_endline "Main 1";
  Lwt.wakeup wakey () (* send event *);
  print_endline "Main 2";
  let* () = Lwt.pause () (* wait one iteration *) in
  print_endline "Main 3";
  Lwt.return ()

let _main =
  print_endline "Scheduler starts";
  Lwt_main.run main_promise;
  print_endline "Scheduler ends"
```

The program produces the following output – which we explain below.

```
Side 1
Main 1
Side 2
Main 2
Scheduler starts
Side 3
Main 3
Scheduler ends
```

### The walkthrough

1. The standard OCaml top-down execution starts with the first `let`-binding: `Lwt.task` is called, it creates a pending promise and a resolver, these are bound to `stop_point` and `wakey` respectively.

2. The standard OCaml top-down execution continues with the evaluation of `side_promise`.

   The AST for `side_promise` starts with a sequence the left-hand side of which is executed.
   This produces the output `Side 1` as a side-effect.

   The right-hand side of the sequence in `side_promise`'s AST is a call to `bind` (through the binding operator alias `let*`).
   The first argument of this bind is `stop_point`.
   Because this first argument is a pending promise, `bind` creates a pending promise and attaches a callback to `stop_point`.
   The callback is responsible for making the pending promise created by `bind` progress when `stop_point` becomes resolved.
   The pending promise created by `bind` is returned.

   The returned pending promise is now bound to the variable `side_promise`.

3. The standard OCaml top-down execution continues: `main_promise` begins to be evaluated.

   The AST for `main_promise` is a (semi-colon-separated) sequence of three statements, followed by a call to `bind`.
   The sequence starts evaluating in order.
   The first statement produces the output `Main 1`.

   The second statement, `Lwt.wakeup wakey ()`, resolves the `stop_point` promise.
   Resolving the `stop_promise` causes the callbacks attached to it to be executed.
   There is one callback attached to it: the one that is responsible for making progress towards the resolution of `side_promise`.

   The callback is executed.
   Its execution produces the output `Side 2`.
   Its execution then reaches a `pause ()`, or, more specifically, it reaches a call to `bind` with `pause ()` as a first argument.
   This `pause ()` registers a new pending (paused) promise with the scheduler.
   The call to `bind` attaches a callback to this pending (paused) promise that is responsible for making `side_promise` progress towards resolution.

   The callback returns `()`, causing `wakeup` to return `()`, causing the execution to continue to the next statement in the sequence.

   The next statement produces the output `Main 2`.

   The next part of `main_promise`'s AST is a `pause ()`/`bind`.
   The `pause ()` registers a new pending (paused) promise with the scheduler.
   The `bind` creates a new pending promise and then attaches a callback to the pending (paused) promise that is responsible for making the newly created pending promise progress towards resolution.
   It then returns the newly created promise.

   The returned promise is now bound to `main_promise`.

4. The standard OCaml top-down execution continues and the evaluation of `_main` starts.
   This causes the output `Scheduler starts` to be printed.

   A call to `Lwt_main.run` follows.
   Because the promise passed to `Lwt_main.run` (`main_promise`) is pending, `Lwt_main.run` resolves each of the pending (paused) promises that are registered with the scheduler.
   Each time it resolves one pending (paused) promise, it triggers the execution of the callbacks attached to it.

   In the case of the pending (paused) promise from the `side_promise`, the callback produces the output `Side 3`, followed by a `pause ()`/`bind` which causes the creation and registration of a pending (paused) promise and the attachment of callbacks as described above.

   In the case of the pending (paused) promise from the `main_promise`, the callback produces the output `Main 3`, followed by `Lwt.return ()`.
   Because the callback ends with an already resolved promise, it resolves the `main_promise`.
   (Note that there aren't any callbacks attached to `main_promise` so there are no additional side-effects from this callback.)

   Because the `main_promise` promise is now resolved, the next iteration of the scheduler does not resolve pending (paused) promises.
   Instead, the scheduler simply returns the value that `main_promise` was fulfilled with: `()`.

   The evaluation of `_main` continues with the printing of `Scheduler ends`.

5. The standard OCaml top-down execution continues.
   It reaches the end of the program.
   This causes the program to `exit`.


### Notable exhibited behaviours

The execution above exhibits multiple interesting behaviours.
We focus on two.
First: the output `Side 4` is never printed.
This is because `main_promise` resolves after one iteration of the scheduler which does not give enough time (enough iterations) to `side_promise` to resolve.

Note that this specific behaviour is dependent upon the scheduler.
The example above was executed with the Unix scheduler (`Lwt_main.run` in the package `lwt.unix`).
A different scheduler, such as the one for `js_of_ocaml`, might differ.

Also note that in many cases, leaving some promises pending is not an issue and can even be a desired behaviour.
For example, in a server it is possible to call `Lwt_main.run` with a promise that only resolves when the process receives a signal (typically `SIGINT` or `SIGTERM`).
Leaving some side promises pending then is a non-issue.

Finally, note that it is very easy to work around this behaviour when desired.
You merely need to pass the joined promise `Lwt.join [main_promise; side_promise]` to `Lwt_main.run`.

Even if the list of promises that must be resolved is not known in advanced, you can register them dynamically in a global mutable variable and loop back to another call to `Lwt_main.run` until the global mutable variable contains only resolved promises.
Implementation is left as an exercise.

Second, an arguably more important behaviour to point out: some of the execution of `side_promise` was interleaved within a non-yielding section of the execution of `main_promise`.
More specifically, the output `Side 2` was printed between `Main 1` and `Main 2` even though there are no yield points between the two `Main` print statements.
In other words: we observed **interleaving without yielding.**

When you reason about promises as threads, this is unintuitive: it appears as a kind of context-switch without an explicit cooperation point between the cooperative threads.
However, there are no threads and there isn't even any "interleaving": there are just callbacks attached and called in order to make progress towards resolution.
And explicit yield points (the calls to `Lwt.pause` and `Lwt_unix.yield`) are mechanisms through which a promise' own resolution is delayed in order to allow other promises to progress towards resolution on their own.

What happens in the example above is actually that the code that makes the `main_promise` progress towards resolution (the expression that evaluates to `main_promise`) also makes the `side_promise` progress towards resolution.
The call to `wakeup` in the code that makes `main_promise` progress also makes `side_promise` progress.

In order to avoid this behaviour, this perceived interleaving, from happening, you merely need to not resolve other promises within your critical sections.
Avoid calling `wakeup` and other such functions: `wakeup_exn`, and even the somewhat misleadingly named `wakeup_later`.

You can move the promise resolution either syntactically or programmatically.
For the former case, simply move the call to `wakeup` to the end of your critical section.
For the latter case, simply replace the call with `ignore (let* () = Lwt.pause () in fun () -> Lwt.wakeup wakey (); Lwt.return ())`.

An important caveat: some other functions may also resolve promises.
For example, pushing a value into a stream may resolve a promise that is waiting for a value to appear on that stream.
It means that the following program might print an interrupted greeting.

```
let (s, push) = Lwt_stream.create ()

let p =
  let* () = Lwt_stream.next s in
  print_string "\nBANG\n!";
  Lwt.return ()

let main_promise =
  …
  let* () = Lwt.pause () in
  (* critical section begins *)
  print_string "Hello ";
  push (Some ());
  print_string "World!";
  (* critical section ends *)
  let* () = Lwt.pause () in
  …
```

Unfortunately, the documentation of `Lwt_stream` and other Lwt-adjacent libraries is often insufficient to understand which non-yielding function may lead to promise resolution and the corresponding execution of attached callbacks.
If you observe "interleaving", you will need to find which function is responsible for it and this task might involve reading some source code.
Once you have found this function, please consider contributing some documentation to the project it appears in.


## Addendum: other promise systems

Some other programming languages have concurrency systems that are roughly equivalent to OCaml's Lwt.
This section lists some of them.
It includes more links than details because the differences can be quite subtle and I am not proficient enough in each of the rough equivalents below.


### OCaml's Async

OCaml has another collaborative promise library: [Async](https://opensource.janestreet.com/async/) from Jane Street.
One of the important differences between Lwt and Async is the eagerness of evaluation.
Specifically, the `bind` function in Lwt does not yield whereas it does in Async.

Another of the important differences is the exception management.
Lwt propagates exception along the bind-graph.
Async uses [monitors](https://ocaml.janestreet.com/ocaml-core/latest/doc/async_kernel/Async_kernel/Monitor/index.html): runtime abstractions that are responsible for the handling of all exceptions raised within a certain portion of a program.

The other differences are not as important as far as the execution model (the focus of this introduction) is concerned.
However, one might be important as far as real-world use is concerned: Async is tightly integrated with the rest of the Jane Street libraries.


### OCaml's Fut

OCaml has another collaborative promise library: [Fut](https://erratique.ch/software/fut) by Daniel Bünzli.
This is not released software yet: the interface may change.

The main difference with Lwt is for exception handling: when the code that makes a promise progress towards resolution raises an exception, the promise is set to a specific state that indicates it will never determine and the exception is passed to a global handler.


### Javascript's Promises

Javascript's concurrency has evolved a lot from the origins of the language.
Modern Javascript, at time of writing, relies on [`Promise`s](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise).

Javascript Promises are similar to that of Lwt with the main differences being:

- the Promises are native to the language, not a library,
- the interface is smaller and focuses on providing the basic primitives, and
- Javascript's flexibility in terms of typing allows for more overloading (e.g., see `then` in the table below).

It is fairly easy to learn the basics of one system when you know the other.
In fact, the infix monadic style of Lwt maps well onto the method-chaining style used for Promises.
This is demonstrated by the two following samples.

```
get_coordinates () >>= fun (x, y) ->
get_input () >>= fun (dx, dy) ->
return (x+dx, y+dy)
```

```
get_coordinates().then((x, y) => {
get_input().then((dx, dy) => {
return(x+dx, y+dy)})})
```

And the binding operator style of Lwt maps well onto the async/await style used for Promises.
This is demonstrated by the two following samples.

```
let translate () =
  let* (x, y) = get_coordinates () in
  let* (dx, dy) = get_input () in
  return (x+dx, y+dy)
```

```
async function translate() {
  let (x, y) = await get_coordinates();
  let (dx, dy) = await get_input();
  (x+dx, y+dy)
}
```

(Note that a lighter syntax is possible in Javascript through the use of the `await` keyword which is roughly similar to the `let*` binding from Lwt.)

A rough equivalence table for the `Promise` object:

+-------------------------------+-------------------------------------+
| Javascript's `Promise`        | Lwt (OCaml)                         |
+===============================+=====================================+
| `Promise.resolve(v)`          | `Lwt.return v`                      |
+-------------------------------+-------------------------------------+
| `Promise.reject(v)`           | `Lwt.fail v`                        |
+-------------------------------+-------------------------------------+
| `p.then(onResolve)`           | `p >>= onResolve` when `onResolve`  |
|                               | returns a promise                   |
|                               |                                     |
|                               | `p >|= onResolve` otherwise         |
+-------------------------------+-------------------------------------+
| `p.then(onResolve, onReject)` | `Lwt.try_bind p onResolve onReject` |
+-------------------------------+-------------------------------------+
| `p.catch(onReject)`           | `Lwt.catch (fun () -> p) onReject`  |
+-------------------------------+-------------------------------------+
| `Promise.all([p, …])`         | `Lwt.all [p; …]`                    |
|                               |                                     |
| Rejected as soon as one       | Rejected if one promise is, but     |
| promise is rejected.          | only after all have resolved.       |
+-------------------------------+-------------------------------------+
| `Promise.race([p, …])`        | `Lwt.choose [p; …]`                 |
+-------------------------------+-------------------------------------+

There are some subtle differences about error management and some not so subtle differences inherited from the distinct typing disciplines (e.g., `>>=` and `>|=` correspond to the same `.then` method).
Despite those differences, the two systems are similar enough that familiarity with one helps to learn the other.

