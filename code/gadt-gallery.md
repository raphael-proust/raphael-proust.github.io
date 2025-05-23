---
title: GADT Gallery
subtitle: GADT tutorial part 3 of 3
...

This final part of the GADT tutorial shows examples of GADTs used in the wild.
Check out [part 1 (My First GADT)](/code/my-first-gadt.html) for a basic introduction to GADTs and [part 2 (GADT Tips and Tricks)](/code/gadt-tips-and-tricks.html) for advanced techniques.


## Crowbar

[Crowbar](https://ocaml.org/p/crowbar/latest) is a fuzzing/property-based testing library.

When you use crowbar to test a function you provide generators for each of the function's parameter.
Then crowbar uses to generators to feed a large and varied set of inputs to the function.

The library revolves around the notion of generators.
It provides an abstract type for them:

```
type 'a gen
(** ['a gen] knows how to generate ['a] for use in Crowbar tests. *)
```

It also provides built-in generators:

```
val uint8 : int gen
(** [uint8] generates an unsigned byte, ranging from 0 to 255 inclusive. *)

val int8 : int gen
(** [int8] generates a signed byte, ranging from -128 to 127 inclusive. *)

(* etc. *)
```

Interestingly, it also provides a way to combine multiple generator by means of a GADT.

```
type ('k, 'res) gens =
  | [] : ('res, 'res) gens
  | (::) : 'a gen * ('k, 'res) gens -> ('a -> 'k, 'res) gens
(** multiple generators are passed to functions using a listlike syntax.
    for example, [map [int; int] (fun a b -> a + b)] *)

val map : ('f, 'a) gens -> 'f -> 'a gen
(** [map gens map_fn] provides a means for creating generators using other
    generators' output.  For example, one might generate a Char.t from a
    {!uint8}:
    {[
      open Crowbar
      let char_gen : Char.t gen = map [uint8] Char.chr
    ]}
*)
```
[source](https://github.com/stedolan/crowbar/blob/v0.2.1/src/crowbar.mli#L6)

The GADT allows you to pass an arbitrary assortment of generators to be mapped.
For example, the documentation included in the excerpts above shows both one- and two-generators mapping:  
`map [uint8] Char.chr`  
`map [int; int] (fun a b -> a + b)`

Unsurprisingly, the type for generators is [also a GADT](https://github.com/stedolan/crowbar/blob/v0.2.1/src/crowbar.ml#L12), although it is not exposed to users.


## Seqes and Lwtreslib

[Seqes](https://ocaml.org/p/seqes/latest) is a library for combining the [`Stdlib.Seq`](https://v2.ocaml.org/api/Seq.html) module with your choice of monad.
Interestingly, the library's tests are based on a formal description of the `Seq` API.
This API description is written out using a GADT which keeps track of both vanilla (Stdlib) and monadic types.

```
type (_, _) ty =
  | Int : (int, int) ty
  | Bool : (bool, bool) ty
  | Tup2 : ('va, 'ma) ty * ('vb, 'mb) ty ->
      (('va * 'vb), ('ma * 'mb)) ty
  | Option : ('v, 'm) ty -> ('v option, 'm option) ty
  (* etc. *)
```
[source](https://gitlab.com/raphael-proust/seqes/-/blob/0.3/test/pbt/testHelpers.ml?ref_type=tags#L121)

I've already written a blog post about [testing Seqes](/code/testing-seqes.html) which has a lot of details.


## Michelson

[Michelson](https://www.michelson.org/) is the programming language for the smart contracts on the Tezos blockchain.
It is a stack-based programming language with a cleverly optimised interpreter written in OCaml.

Interestingly, one of its intermediate representation has a type system which enforces stack discipline.

The stack discipline is enforced with GADT type parameters which represent the contents of the stack.
A stack is represented as two parameters: one for the top of the stack and one (an accumulator of tuple types) for the rest.
E.g., `(int, (int * (float * unit)))` is for a stack with two integers and a float; the first `int` is the parameter for the top of the stack, and the `int`-`float`-`unit` nested tuple is for the rest of the stack.

A sequence of instructions has parameters for the stack prior to execution and parameters for the stack after the execution.
It makes four parameters in total: top before, rest before, top after, rest after.

Sequences of instructions are expressed as chained instruction constructors: each instruction carries the next instruction in the sequence as its payload.
So in pseudo-code (omitting some details) a small program fragment for `1+2` might look like:  
`Push (1, Push (2, Add …))`

Here's an excerpt for the GADT definition:

```
type ('before_top, 'before, 'result_top, 'result) kinstr =
  | IAdd_int :
      (z num, 'S, 'r, 'F) kinstr
      -> ('a num, 'b num * 'S, 'r, 'F) kinstr
  | IIf : {
      branch_if_true : ('a, 'S, 'b, 'T) kinstr;
      branch_if_false : ('a, 'S, 'b, 'T) kinstr;
      k : ('b, 'T, 'r, 'F) kinstr;
    }
      -> (bool, 'a * 'S, 'r, 'F) kinstr
  | ISwap :
      ('b, 'a * ('c * 'S), 'r, 'F) kinstr
      -> ('a, 'b * ('c * 'S), 'r, 'F) kinstr
  (* etc. *)
```
[source](https://gitlab.com/tezos/tezos/-/blob/v19.1/src/proto_018_Proxford/lib_protocol/script_typed_ir.mli?ref_type=tags#L332)


## OCaml's Format internals

The OCaml's [`Stdlib` formatting module](https://v2.ocaml.org/api/Format.html) allows programmers to easily define custom printers:
`Format.printf "%s:%d: %s" file_name line_number error_message`

On the outside, the typing rules for format strings seem like magic built directly into the compiler.
This was the case until 10 years ago when most parts of the magic was rewritten into some GADTs.

At the core of it is the `fmt` type which has a constructor for each of the formatting string special sequence.
The constructors in this type carry the next constructor as a payload, forming a chain.
The chain of constructor accumulates some types as parameters of a function.

```
and ('a, 'b, 'c, 'd, 'e, 'f) fmt =
  | Char :                                                   (* %c *)
      ('a, 'b, 'c, 'd, 'e, 'f) fmt ->
        (char -> 'a, 'b, 'c, 'd, 'e, 'f) fmt
  | String :                                                 (* %s *)
      ('x, string -> 'a) padding * ('a, 'b, 'c, 'd, 'e, 'f) fmt ->
        ('x, 'b, 'c, 'd, 'e, 'f) fmt
  (* etc. *)
```
[source](https://github.com/ocaml/ocaml/blob/trunk/stdlib/camlinternalFormatBasics.ml#L365)

It is far beyond the scope of this gallery to explain the multiple type parameters of this GADT and to explore the many types that work together with `fmt` to provide the formatting feature.
Nonetheless, you can have a look at the source if you want to learn more:  
[`camlinternalFormatBasics`](https://github.com/ocaml/ocaml/blob/trunk/stdlib/camlinternalFormatBasics.ml)  
[`camlinternalFormat`](https://github.com/ocaml/ocaml/blob/trunk/stdlib/camlinternalFormat.ml)


## miragevpn configuration

EDIT NOTICE 2024-02-14: This section was added (after a reader's suggestion).

[`miragevpn`](https://github.com/robur-coop/miragevpn/) is a VPN implementation using the [mirage stack](https://mirage.io/).
VPNs can have quite complex configurations: which cyphers are enabled, with what options, using which keys; what addresses to connect to, with what protocol and options, etc.

The `miragevpn` project describe each configuration option as the constructor of a GADT.

```
  type 'a k =
    | Auth : Mirage_crypto.Hash.hash k
    | Auth_nocache : flag k
    | Auth_retry : [ `Interact | `Nointeract | `None ] k
    | Cipher
        : [ `AES_256_CBC | `AES_128_GCM | `AES_256_GCM | `CHACHA20_POLY1305 ] k
    (* etc. *)
```

[source](https://github.com/robur-coop/miragevpn/blob/c85f85999682593a0dd853103321a8c03ba9e94f/src/config.ml#L154)

This GADT is then used to instantiate a heterogeneous map provided by the [gmap library](https://github.com/hannesm/gmap).
(“Heterogeneous” here has the same meaning as in the “heterogeneous list” shown in [part 2](/code/gadt-tips-and-tricks.html#accumulator-of-types-tuples): it contains elements of different types.)

Parsing the configuration file returns a map.
And checking the value of a configurable option is just a lookup in the map.


## Nightmare's services

EDIT NOTICE 2025-01-10: This section was added (after a reader's suggestion).

[Nightmare](https://github.com/funkywork/nightmare/) is a library for supplementing the [Dream](https://aantron.github.io/dream/) framework.
One of the features it provides is a notion of service: a way to handle a request (serve a page or reply to an API call).
In order to enforce that the services match the handler to an appropriate endpoint (e.g., that the path includes needed parameters), the library defines a set of related GADTs.

1. A definition of paths (think URLs) with an arrow type accumulator: [`Path.t`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/path.ml).
2. A variety of simpler types:
    [`Method.t`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/method.ml#L23),
    [`Endpoint.t`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/endpoint.ml#L23),
    [`Handler`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/handler.ml#L23),
    [`Middleware.t`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/middleware.ml#L23).
3. A definition of services with constraints to ensure all the types above fit together: [`Service.t`](https://github.com/funkywork/nightmare/blob/3ac271377f651426f40b9f239138310461b0888b/lib/service/service.ml#L1)

The documentation for the types themselves is sparse.
But you can check the documentation of the constructor functions in the mli to learn more.

Other webservice-oriented libraries also use GADTs to keep track of similar invariants.
E.g., [eliom](https://github.com/ocsigen/eliom), [resto](https://gitlab.com/nomadic-labs/resto).


## Justified containers

EDIT NOTICE 2025-02-07: This section was added (after a reader's suggestion).

Taking inspiration from [`justified-containers`](https://github.com/matt-noonan/justified-containers), the [`justifying-ocaml`](https://github.com/ninjaaron/justifying-ocaml/blob/7dfa5423095e62eddb5fb2c3f792ef70fd0f7f14/justified.ml) uses GADTs to provide infallible lookup operations in a lookup table.

The infallible lookup uses a two step process:
1. the `mem` function returns not a boolean but a phantom-key (or `None` if there is no such value),
2. the `find` function takes a phantom-key and returns the associated value.

It is impossible to `find` a value without first proving that it exists.
This allows to call `mem` and deal with potentially missing entries a single time, followed by multiple finds (without having to deal with option/error) in multiple branches of the code.


## Call for suggestions

If you know of some interesting examples of GADTs in OCaml libraries, let me know and I might include them.
