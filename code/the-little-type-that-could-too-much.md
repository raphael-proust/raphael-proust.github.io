---
title: The little type that could too much
...

## Part 1: Hashtbl, Mashtbl, Smashtbl, Slashtbl, Clashtbl, Crashtbl

The `Hashtbl` module of the OCaml's `Stdlib` exposes a parametric type `('a, 'b) t`. As [the documentation](https://ocaml.org/manual/5.5/api/Hashtbl.html) explains, they are used as mutable key-value stores in imperative code.

However, the module doesn't expose just a "hashed association table". Instead, the module exposes a data-structure and functions meant to model the notion of "environments" in the programming-language and compiler domains. Specifically: it's a one-to-ordered-list association table with some helpers to work on the head of the ordered list. This only becomes clearer further down in the documentation:

- The [`add` function](https://ocaml.org/manual/5.5/api/Hashtbl.html#VALadd) contains a warning: adding a binding doesn't remove the previous bindings, it just shadows them.
- The [`remove` function](https://ocaml.org/manual/5.5/api/Hashtbl.html#VALremove) "restores the previous binding".
- The [`find_all` function](https://ocaml.org/manual/5.5/api/Hashtbl.html#VALfind_all) returns "the list of all data associated with [the key]".
- etc.

(The same behaviour exists for specialised hash tables obtained via `Hashtbl.Make`. I'll only discuss the `Hashtbl` module for brevity.)

This behaviour is somewhat surprising because the semantics differs from other languages' stdlibs: [Python's `dict`](https://docs.python.org/3/library/stdtypes.html#dict), [Rust's `HashMap`](https://doc.rust-lang.org/std/collections/struct.HashMap.html). This behaviour is also arguably less intuitive and more complex: the state of the Hashtbl after you call `remove` is not known.

It is possible to use the Hashtbl in a way that corresponds to the other languages' semantics: just use `replace` instead of `add`. You can find such uses in the ~~wild~~ publicly released packages of opam repository. For example, [dream's graphql's subscriptions](https://github.com/camlworks/dream/blob/master/src/graphql/graphql.ml#L213) and [ringo's resource cache tables](https://gitlab.com/nomadic-labs/ringo/-/blob/master/src/aches/rache/functors.ml?ref_type=heads#L62).

The issue is that you have to do it consistently. Mixing and matching is a possible source of bugs or memory leak. There are no guardrails. All you get is a `Hashtbl.t` and you are left to determine whether you should call `add` or `replace`, whether `find_all` is relevant or not.

At [Ahrefs](https://ahrefs.com/), we've taken to linting out the use of `Hashtbl.add` and enforcing the arguably simpler `Hashtbl.replace` semantic. That's our guardrail. Just a linter. In the rare cases that we do want to maintain bindings to a growable list of values, we have a dedicated module implementing just this. And it seems we're not the only ones: [ocaml-uri's config](https://github.com/mirage/ocaml-uri/blob/main/config/gen_services.ml#L21) exposes a `hashtbl_add_list` function to accumulate values into a list explicitly.

Ideally, the multiple uses of a `Hashtbl` would be exposed as different modules. One module to manage environments exposing `add` a `find_opt` and `find_all`; one module to manage one-to-one association tables exposing `replace` and `find_opt`.

```
module HashEnvTbl : sig
  type ('a, 'b) t

  (* equivalent to Hashtbl.add *)
  val push : ('a, 'b) t -> 'a -> 'b -> unit

  (* equivalent to Hashtbl.find_opt *)
  val peek: ('a, 'b) t -> 'a -> 'b option

  (* equivalent to Hashtbl.find_and_remove *)
  val pop: ('a, 'b) t -> 'a -> 'b option

  [… some other functions …]

end

module Hash1to1Tbl : sig
  type ('a, 'b) t

  (* set the value bound to the given key *)
  val set : ('a, 'b) t -> 'a -> 'b -> unit

  (* equivalent to Hashtbl.find_opt *)
  val get: ('a, 'b) t -> 'a -> 'b option

  (* remove the binding for the given key *)
  val unset: ('a, 'b) t -> 'a -> 'b option

  [… some other functions …]

end
```

I don't know that it is worth changing the Stdlib. It would open a can of worm of design with backwards compatibility considerations. And it would place the burden of maintenance on a team which already handles a lot of work. (Maybe I'll make a patch to the documentation, mentioning the quirk earlier on.) But I think it's an important consideration for altlibs.

More importantly, this Hashtbl quirk is small and interesting example for the rest of this post.


## Part 2: Lwt_stream, one type to rule them all

The `Lwt_stream` module of the Lwt library exposes a parametric type `'a t`. The documentation doesn't state any intended uses. It simply states somewhat tautologically that a `'a Lwt_stream.t` is "a stream holding values of type `'a`".

In practice, a `Lwt_stream` is a sequence of values which become available at different times in the life of the program. The only guarantee of the data-structure is that the ordered is preserved inside the stream: values added in a given ordered are processed in the same order.

### Part 2a: 推, 拉 and so much more

There aren't really many guarantees about the data-structure because it supports many different uses with many different requirements. Common uses include:

**Lwt stream for push-based pipelines.** You can use Lwt streams to hold and transport values which are added as they become available (e.g., read from a pipe). Each addition triggers a cascade of computations. The rhythm of the processing pipeline is dictated by the uses of the `push` function.

```
(* reimplementing `Lwt_io.read_lines` for the sake of example *)
let lines_of_ic ic =
  let s, push = Lwt_stream.create () in
  let rec feed () =
    match Lwt_io.read_line_opt ic with
    | None -> push None; Lwt.return ()
    | Some l -> push Some l; feed ()
  in
  Lwt.async feed;
  s
;;

let () = Lwt_main.run (
  (* values drip through from stdin and are processed as they become available *)
  lines_of_ic Lwt_io.stdin
  |> Lwt_stream.map String.uppercase_ascii
  |> Lwt_stream.iter_s (Lwt_io.write_line Lwt_io.stdout)
) ;;
```

**Lwt stream for pull-based pipelines.** You can use Lwt streams to hold and transport values which are lazily computed when they become needed. The rhythm of the processing pipeline is dictated by the uses of the calls to the `get` function.

```
let r = ref (-1);;
let ints = Lwt_stream.from_direct (fun () -> incr r; !r);;

let rec f () =
  let* _ : string = Lwt_io.read_line Lwt_io.stdin in
  let* i =
    (* request an int: computed here on demand *)
    Lwt_stream.get ints
  in
  let i = Option.get i in
  let* () = Lwt_io.write_line (string_of_int i) in
  f ()
;;
```

**Lwt stream for buffering.** You can use Lwt stream to keep a hold of values if you expect to receive the data in batches.

```
let () = Lwt_main.run (
  Lwt_io.read_lines Lwt_io.stdin
  |> Lwt_stream.map_list (fun line -> List.of_seq (String.to_seq line))
  (* the line is split by char, the stream has batches of data fed in *)
  |> Lwt_stream.iter_s (fun c -> [… idk, something that takes a bit of time …])
) ;;
```

**Lwt stream for back-pressure.** You can use Lwt stream to hold and transport data in a processing pipeline where processing might take more time than the data becoming available. The stream can apply back-pressure to the pushing side in order to limit the number of values held by the stream. The rhythm of the data-acquisition process is dictated by the speed of the processing.

```
let lines_of_ic ic =
  let s, push = Lwt_stream.create_bounded 1 in
  let rec feed () =
    match Lwt_io.read_line_opt ic with
    | None -> push#close; Lwt.return ()
    | Some l ->
        (* because the stream is bounded, this operation will block until the space is free *)
        push#push l
  in
  Lwt.async feed;
  s
;;

let rec wmap s f =
  let* v = Lwt_stream.get s in
  match v with
  | None -> Lwt.return ()
  | Some v ->
      let* v = f v (* this can take a lot of time *) in
      let* () = Lwt_io.write_line v Lwt_io.stdout in
      wmap s f
;;

let () = Lwt_main.run (
  let s = lines_of_ic Lwt_io.stdin in
  wmap s (fun line -> [… idk, something that takes a lot of time …])
) ;;
```

**Lwt stream as a generic wrapper for other collections.** You can use a stream as a generic data-structure for ordered collections (lists, arrays, strings, seqs). This is useful because Lwt provides a bounded-concurrency iterator for streams.

```
let list_iter_n ?max_concurrency f xs =
  Lwt_stream.iter_n ?max_concurrency f (Lwt_stream.of_list xs)
;;
let array_iter_n ?max_concurrency f xs =
  Lwt_stream.iter_n ?max_concurrency f (Lwt_stream.of_array xs)
;;
```


Each of these uses is valid. But beware of mixing and matching uses. If a library provides you with a stream, you better hope they document the intended use very well, or you will end up with bugs, memory leaks, and raised exceptions.

For example, it's fine to share a push function amongst multiple writers in the case of an unbounded stream. But doing so for a bounded stream will likely result in an exception. That is because back-pressure streams are intended for single-writer only.


### Part 2b: What to do?

The `Lwt_stream` module is a sore point of the Lwt API. I often personally recommend against it. But then people ask me what they should use instead and I rarely have a good answer.

There's `Lwt_seq` and `seqes`, there's `lwt-pipeline`, there's `lwt-watcher`, there's `lwt-pipe`, there's a myriad other little helpers. Maybe one of them fits your use-case?

I'll be working on providing separate modules for the different uses, possibly aggregating some of the community's helpers. I'll focus on on providing one abstraction/intended-use for each helper (even if I end up sharing some implementation details). In the meantime, let me know if you've ever needed to wrestle the Lwt_stream API to get something out of it. I might be able to make room for your use-case.

## Part 3: Lwt, a well-behaved core type with too many helpers

The `Lwt` module itself, the very core of the Lwt library, has a similar problem as Hashtbl and Lwt_stream. Not exactly the same problem: the `'a t` type does serve the one single purpose of promises for concurrency. But a related problem: the many functions handling the promises correspond to widely different levels of abstraction and are often intended for different audiences.

### Part 3a: mixing levels of abstraction

As a basic example, using an explicit promise (`task` or `wait`) and resolver (`wakeup`) should really only be used for providing new abstractions on top of the promises (such as for writing `Lwt_list`, `Lwt_seq`, `ringo`, `lwt-exit`, etc.). It shouldn't be used for application code when you are just writing service handlers for your web server.

The issue is all the functions (from `bind` (and the friendlier `let*`) to `task`) are presented together in the same namespace. This encourages users to dip to a lower level of abstraction when they only rely on the high-level composition. The code becomes harder to understand and relies on complex behaviour of Lwt primitives.

To give more of an idea of what I think is wrong with the `Lwt` API, here's a list of what functions that application code should be using:

- `return` (and `return_* pre-allocated variants),
- `bind` (but actually as `let*` or `let%lwt`),
- `catch` (and `finalize` and `try_bind` or `try%lwt`),
- `pause`,
- `join` (as well as `all` and `both`),
- `pick` (and `choose` and n-variations),
- `cancel` (but see below for a short discussion of cancellation).

These functions (and these functions only) should be in the module named `Lwt` which is often opened globally. The rest should be in separate namespaces for the different audiences (library writers, test writers, bug chasers).

There are surely a few exceptions for specific cases of application code. But in general, every time you stray from the list above, it's a good time to ask whether you should provide a new abstractions in a new library for you application code.  
Using `dont_wait` or `async`? You should make a background task pool so that you can check the unfinished tasks when you exit.  
Using `protected`, `no_cancel`, or `wrap_in_cancelable`? You should make a wrapper which register the uncancellable task in a global or local data-structure that exit can be delayed for those not-to-be-cancelled actions to finish.  
Etc.

### Part 3b: lwt-modern

What to do about all that? Well it's not very satisfying to have a list of dos and donts on this here webpage. I've been thinking of providing a `lwt-modern` package (or `lite-wait`? or `prom`?) that's essentially `Lwt` but rewritten to eschew all the historical baggage.

First, it would separate the core part intended for end-users from the low-level part intended for writing new synchronisation abstractions.

Second, it would have new cancellation-related primitives. I, a maintainer of Lwt of several years and user of Lwt for even longer, cannot remember which of `task` and `wait` is the cancellable one, which of `pick` and `choose` does the cancellation, and what do `no_cancel` and `protected` actually do. The whole cancellation feature needs better semantics with better names.

Third, it would expose a bigger zoo of smaller synchronisation utilities. In the same vein as splitting `Lwt_stream` into smaller, more focused pieces, there needs to be some basic building blocks of synchronisation. This would probably take time. And it might also involve curating a list of third-party libraries.

Any other ideas? Let me know!
