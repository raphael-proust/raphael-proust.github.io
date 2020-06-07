---
title: Lwt introduction/tutorial Part 3 of 2
...

[← Back to part 1](/code/lwt-part-1.html)  
[← Back to part 2](/code/lwt-part-2.html)

In this 2-part introduction/tutorial to Lwt, we collect a few remarks that are of little interest to users of Lwt.


# Historical bagage

The documentation of Lwt has evolved to consistently use a sound terminology: promise, resolution, pending, etc.
This updated documentation gives a better description than the previous one.
However, whilst the documentation has evolved, the effective signature of `Lwt` (the identifiers for values, types, etc.) has been left mostly untouched for backwards compatibility.
This causes a disonance in places such as the official documentation of `wakeup` (edited for brevity):

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
Indeed, another source of disonnance is when third-party libraries describe the abstraction they provide on top of Lwt in old, deprectaed terms.

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
..
(* note: [any] replaces both [choose] and [pick] *)
val any: ~cancel_rest:bool -> 'a t list -> 'a t
..
(* note [either] is the dual of [both] *)
val either: 'a t -> 'a t -> 'a t

(* CALLBACKS *)

val on_resolution: 'a t -> ('a -> unit) -> (exc -> unit) -> unit
val on_fulfillment: 'a t -> ('a -> unit) -> unit
val on_rejection: 'a t -> (exn -> unit) -> unit
..

(* MONADIC INTERFACE *)

val return: 'a -> 'a t
val ( >>= ): 'a t -> ('a -> 'b t) -> 'b t
```



# The ecosystem

Lwt provides a useful abstraction for handling concurrency in OCaml.
But futher abstractions are sometimes necessary.
Some of these abstractions are distributed with Lwt:

`Lwt_unix` and the rest of the `lwt.unix` sublibrary provide Lwt-aware interface to the operating system.
The main role of this library is to provide wrappers around potentially blocking system calls.
There is more details about it in [Part 2]().

`Lwt_list` (distributed with the `lwt` library) provides Lwt-aware list traversal functions.
E.g., `map_p: ('a -> 'b Lwt.t) -> 'a list -> 'b list Lwt.t` for applying a transformation to all the elements of a list concurrently.
The module takes care of synchronisation and propagating rejections.

`Lwt_stream` (disrtributed with the `lwt` library) provides streams: Lwt-aware lazy collections.
With streams you are given a promise of the next element rather the next element itself.

Many other abstractions are available through `opam`.
There are too many to list them all; here is one that I wrote:

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


# Warnings about this tutorial

It is important to realise that the simplified model of Part 2 is a simplified model.
It does not include all the details of the real implementation.

An important difference is the existence of proxy promises: when a promise is marked as being equivalent to another promise.
Proxy promises are useful internally for performance.
Specifically, in `bind` (and other similar functions), proxying can be used to avoid having to attach callbacks and cancelation links between the intermdiate promise and the final promise.

So, whilst the model of Part 2 is useful to discuss the coarse semantics of Lwt, it is not sufficient to discuss the all the finer aspects of the semantics, nor any of the other aspects of Lwt such as performance or memory consumption.
