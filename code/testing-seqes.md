---
title: Testing Seqes
...

## Seqes

The [Seqes library](https://gitlab.com/nomadic-labs/seqes) provides monadic traversors for the [`Seq`](https://v2.ocaml.org/api/Seq.html) module of the OCaml Stdlib.
Specifically, the Seqes library provides functors parametrised over a monad, returning monad-friendly `Seq`-like modules and monad-friendly `Seq`-compatible modules.

```
module IO = struct
  type 'a t = …
  let return x = …
  let bind x f = …
end
module SeqIO = Seqes.Standard.Make1(IO)
let dump strings =
  lines
  |> Seq.filter (fun string -> string <> "")
  |> SeqIO.iter
      (fun line ->
        IO.bind
          (write_string line)
          (fun () -> write_char '\n'))
```

### Motivation

The [Octez project](https://gitlab.com/tezos/tezos/) uses the [Lwt](https://github.com/ocsigen/lwt/) monad for IO, the [Result](https://v2.ocaml.org/api/Result.html) monad for error-management, and the combination of the two for error-managed IO.
There is [a significant part of the source code](https://gitlab.com/tezos/tezos/-/tree/v15.1/src/lib_lwt_result_stdlib) providing monadic helpers for different data-structures of the Stdlib: [`List`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/List/index.html), [`Map`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Map/index.html), [`Set`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Set/index.html), [`Hashtbl`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Hashtbl/index.html), etc.
These modules provide the normal functionality from the Stdlib as well as monadic traversors.
They can be seen as a generalisation of [`Lwt_list`](https://ocsigen.org/lwt/latest/api/Lwt_list).

There is also a [`Seq`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Seq/index.html) module.
However, the Stdlib's `Seq` module exports types which cannot be mixed freely with monads.
Consequently, there are also companion modules to `Seq` in Octez: [`Seq_s`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Seq_s/index.html), [`Seq_e`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Seq_e/index.html), and [`Seq_es`](https://ocaml.org/p/tezos-lwt-result-stdlib/15.1/doc/Tezos_lwt_result_stdlib/Lwtreslib/Bare/Seq_es/index.html).
Each one is a module similar to `Seq`, but with monads baked directly into the type.
For example:

+--------------------------------------+----------------------------------------+
| `Stdlib.Seq`:                        | `Seq_s`:                               |
+======================================+========================================+
|  ```                                 | ```                                    |
|  type 'a t = unit -> 'a node         | type 'a t = unit -> 'a node Lwt.t      |
|  and 'a node =                       | and 'a node =                          |
|    | Nil                             |   | Nil                                |
|    | Cons of 'a * 'a t               |   | Cons of 'a * 'a t                  |
|  ```                                 | ```                                    |
+--------------------------------------+----------------------------------------+

These `Seq*` modules were added at the time of OCaml version 4.13, when the `Seq` module was relatively small.
The code was written out entirely by hand — or, rather, by the use of advanced text-editor features: [a meta-programming of sort](/code/vi-as-a-programming-language.html).

With the release of OCaml 4.14, the `Seq` module has grown significantly.
It has become unreasonable to maintain the monad-specialised code.
Hence Seqes.

### Implementation

The development of Seqes started at the [mirage-os retreat of 2022](/code/mirage-retreat-2022-10.html).
Discussions during this retreat have contributed greatly to the library.
The implementation is based on functors.
Each functor of the library takes a monad as parameter and returns a module which is identical to Stdlib's `Seq` but with the added monad.

There are several functors because there are different kinds of monads and you might want different things from them.
This is explained in more details in the documentation of the library.
But all the functors produce modules that are identical to the whole or to a subset of the `Seq` module with some monad in it.

There are a few cool tricks in the implementation of this library.
But this post is focused on a different matter: the tests.


## Testing the implementation

As mentioned above, discussions during the mirage-os retreat contributed to the library.
Some of the most important discussions happened with [Jan Midtgaard](https://github.com/jmid) who knows a lot about randomised testing.
He encouraged me to base the tests on a formal description of the library's API (something he has done for other projects), very much shaping the tests of Seqes.


### What to test?

As mentioned above the Seqes library produces modules which are similar to the Stdlib `Seq` module, with a light peppering of monad.
This is true of the signatures of the modules: they contain exactly the same function types as the Stdlib `Seq` module with some monad type constructors here and there.
This is also true of the implementation of the modules: they contain exactly the same function definitions as the Stdlib `Seq` with some monadic `bind` and `return` here and there.

(The library is released under the LGPL license because the bulk of the content of the functors is based on the code from the Stdlib `Seq` module, with the added monadifications.)

In other words, the modules produced by the library's functors are supposed to be equivalent to the Stdlib `Seq` module, modulo the monad parameter.
This property is easy to test, provided the monad is simple:

```
module Identity = struct
  type 'a t = 'a
  let return x = x
  let bind x f = f x
end
```

With this specific monad, the produced modules should be indistinguishable from the Stdlib's.
In other words,

- given a module produced by the library

    ```
    module SeqId = Seqes.Monadic1.Make(Identity)
    ```

- given a function that appears in this module

    ```
    Seq.find : 'a Seq.t -> ('a -> bool) -> 'a option
    SeqId.find : 'a SeqId.t -> ('a -> bool) -> 'a option Identity.t
    ```

    (Note: the type `'a option Identity.t` is an alias for the type `'a option`.)

- and given inputs that are the equivalent modulo the monad

    ```
    s_stdlib : 'a Seq.t
    s_seqid : 'a SeqId.t
    f : 'a -> bool
    ```

- the applications in `Seq` and `SeqId` should lead to the same result modulo the monad:

    ```
    Seq.find f s_stdlib = SeqId.find f s_seqid
    ```

The "modulo the monad" wording is somewhat hand-wavy here.
But in practice it's easy to write down the exact property for any given function of the interface.

All in all, the Seqes library lends itself to property-based testing.


### Property-based testing: how

The first time I encountered property-based testing in OCaml was when [Gabriel Scherer](https://gallium.inria.fr/~scherer/) wrote tests for a library I maintain: [data-encoding](https://gitlab.com/nomadic-labs/data-encoding).
I was impressed with the amount of testing that could be done from so little code and I have been using this kind of tests a lot since then.

In OCaml there are several libraries dedicated to writing property-based tests.

- [Crowbar](https://github.com/stedolan/crowbar):
  a solid library with support for the [AFL](https://lcamtuf.coredump.cx/afl/) fuzzer.
- [Monolith](https://gitlab.inria.fr/fpottier/monolith):
  a library specialised in testing functions against a reference implementation.
- [QCheck](https://github.com/c-cube/qcheck):
  a generic property-based testing library with good tooling integration and a large set of value generators.

I went for QCheck because it supports generators for functions, I was already familiar with this library, it has good integration with [Alcotest](https://github.com/mirage/alcotest), and I had an expert on hands from the very start (the aforementioned Jan).

In QCheck, a test is fully described by

- a generator for input values,
- a property over the inputs (i.e., a function from the inputs to a boolean),
- some optional parameters for tweaking the test,
- some optional metadata for making the test report readable.

```
QCheck2.Test.make :
  (* some optional parameters here *)
  'a QCheck2.Gen.t    (* generator *)
  -> ('a -> bool)      (* property *)
  -> QCheck2.Test.t
```


### A formal description of the API

The property mentioned above (equivalence of `Seq.find` and `SeqId.find`) is easy to describe in QCheck.
However, the property is only one of many: one for each function of the signature.
And the whole suite of properties must be checked for each functor of the library.

Writing this test suite by hand is unreasonably verbose.
This verbosity would impact maintainability.
But it could also hide some issues with the code: it makes it harder to check that the test suite is complete and correct.

Thankfully, it is possible to minimise boilerplate by the clever application of [GADTs](https://v2.ocaml.org/manual/gadts.html).
More concretely, consider the signature of the `Seq` module:
only a handful of types and type constructors are used;
they can be described by a data-type.

E.g., for the function

```
find_map : ('a -> 'b option) -> 'a Seq.t -> 'b option
```

The type-description data-type needs to include the following constructors:

```
type ty =
  | Option of ty
  | Seq of ty
  | Lambda of ty * ty
  (* … *)
```

Type parameters (the `'a` and `'b`) are somewhat difficult to handle and so I simplified the problem by considering that all the polymorphic parts of the interface are instantiated with the `char` type.
(I chose `char` because it doesn't appear in the interface of `Seq` at all and because it is simple without being trivial.)

```
type ty =
  (* … *)
  | Char
  (* … *)
```

As is, this `ty` is not very usable.
That's because I cannot write functions that consume values of this type to return interestingly typed values.
For example, I want to generate equality functions based on those type descriptions.
Such an equality function should have a type that matches the values being checked.
E.g., `eq_of_ty (Option Char)` should have type `char option -> char option -> bool`.
And so I need to keep track of the type of the values the type of which is being described.

After some experimentation the following type ended up covering all the testing needs:

```
type (_, _) ty =
  | Unit : (unit, unit) ty
  | Char : (char, char) ty
  | Int : (int, int) ty
  | Nat : (int, int) ty
  | Bool : (bool, bool) ty
  | Tup2 : ('va, 'ma) ty * ('vb, 'mb) ty ->
      (('va * 'vb), ('ma * 'mb)) ty
  | Option : ('v, 'm) ty -> ('v option, 'm option) ty
  | Either : ('va, 'ma) ty * ('vb, 'mb) ty ->
      (('va, 'vb) Either.t, ('ma, 'mb) Either.t) ty
  | Lambda : ('vk, 'vr, 'mk, 'mr) params * ('vr, 'mr) ty ->
      ('vk, 'mk) ty
  | Seq : ('va, 'ma) ty -> ('va Seq.t, 'ma SeqId.t) ty
  | Monad : ('va, 'ma) ty -> ('va, 'ma) ty
and (_, _, _, _) params =
  | [] : ('vr, 'vr, 'mr, 'mr) params
  | ( :: ) : ('vp, 'mp) ty * ('vk, 'vr, 'mk, 'mr) params ->
      ('vp -> 'vk, 'vr, 'mp -> 'mk, 'mr) params
```

The type constructor `ty` carries two type parameters for the two sides of the property being checked: the Stdlib side and the Seqes side.
The Stdlib side parameters use `v` as a prefix (for *vanilla*), and the Seqes side parameters use `m` (for *monadic*).
E.g., the type descriptor `Option (Monad Char)` has the type `(char option, char option) ty`.

Note that the with the `Identity` monad, the `Identity.t` type constructor can be omitted.
And, in fact, the `Monad` constructor could be removed altogether.
It is left because of future plans to test against monads other than `Identity`.
(Stay tuned for a future post about that.)

The `Lambda` constructor has one argument for parameters (of type `params`) and one for return.
The argument for parameters describes the lambda's parameters, using the `params` type.
The `params` type has four type parameters because it needs to keep track of both the parameters types as well as the return types, for both the Stdlib side and the monadic side.
For example,

```
let params
  : ( (char -> char -> int Seq.t)
    , int Seq.t
    , (char -> char -> int SeqId.t)
    , int SeqId.t
    ) params
  = [Char; Char]
in
Lambda (params, Seq Int)
  : ( (char -> char -> int Seq.t)
    , (char -> char -> int SeqId.t)
    ) ty
```


### From the formal description to the tests

Equipped with this formal type-description type, it is possible to extract the building blocks of a QCheck tests, namely an equality function and an input generator.
The equality function (`eq_of_ty : ('v, 'm) ty -> ('v -> 'm -> bool)`) has trivial ground types, simple type constructors, trivial lambdas, and interesting sequences.

```
let eq_of_ty =
  | Unit -> fun () () -> true
  | Int -> fun a b -> a = b
  (* … more ground types *)
  | Option ty -> (fun a b -> match a, b with
      | Some a, Some b -> eq_of_ty ty a b
      | None, None -> true
      | Some _, None -> false
      | None, Some _ -> false
  )
  (* … more type constructors *)
  | Lambda _ -> invalig_arg "eq_of_ty.Lambda"
  | Seq ty -> (fun v m ->
      let eq = eq_of_ty ty in
      let rec loop n v m =
        if v < 0 then
          true (* only compare to a certain length *)
        else
          match v (), m () with
          | Seq.Nil, SeqId.Nil -> true
          | Seq.Cons (x, v), SeqId.Cons (y, m) ->
              eq x v && loop (n-1) v m
          | _ -> false
      in
      loop 100 v m)
  | Monad ty -> eq_of_ty ty
```

The input generator function (`gen_of_ty : ('v, 'm) ty -> (v * m) QCheck2.Gen.t`) generates a pair of equivalent-modulo-the-monad values.
It has trivial ground types, simple type constructor, complex lambdas, and simple sequences.

```
let gen_of_ty =
  | Unit -> QCheck2.Gen.map (fun x -> (x, x)) QCheck2.Gen.unit
  | Int -> QCheck2.Gen.map (fun x -> (x, x)) QCheck2.Gen.int
  (* … more group types *)
  | Option ty ->
      QCheck2.Gen.oneof [
        QCheck2.Gen.return (None, None);
        QCheck2.Gen.map (fun (v, m) -> (Some v, Some m)) (gen_of_ty ty);
      ]
  (* … more type constructors *)
```

For the sequence, the function generates a list of values and then converts it to a pair of the different sequence types — [see code](https://gitlab.com/nomadic-labs/seqes/-/blob/daa277e2f7bdcec5af48bef962acc8a6c876e7d5/test/pbt/helpers.ml#L54).
For the lambdas, the function generates a single vanilla function, and then patches it by monadifying the parameters and return value — [see code](https://gitlab.com/nomadic-labs/seqes/-/blob/daa277e2f7bdcec5af48bef962acc8a6c876e7d5/test/pbt/helpers.ml#L324).
This part is fiddly and it took several attempt to get right.
It's also complicated to generalise based on the arity of the functions.
As a result, this part of the test helpers is somewhat verbose and it is hard-coded to support only the arities actually used in the `Seq` interface.

Equipped with these two function, I can write `test_of_ty`:


```
let test_of_ty
: type vk vr mk mr.
     string                    (* name of test *)
  -> ( (vk, vr, mk, mr) params (* description of arguments *)
     * (vr, mr) ty )           (* description of return values *)
  -> vk                        (* stdlib function *)
  -> mk                        (* monadic function *)
  -> QCheck2.Test.t
= fun name (params, tyr) vf mf ->
  match params with
  | [] -> assert false (* no parameterless functions *)
  | [tya] ->
      QCheck2.Test.make
        ~name
        (gen_of_ty tya) (* inputs generator *)
        (fun (va, ma) ->
          (eq_of_ty tyr) (* equality for return values *)
            (vf va)      (* value returned by stdlib *)
            (mf ma)      (* value returned by seqes *)
        )
  (* … support for more arities *)
```

### Actually writing the tests down

To avoid some verbosity, I define a small DSL:

```
module DSL = struct
  let unit = Unit
  let data = Char
  (* … more ground types  *)
  let ( * ) a b = Tup2 (a, b)
  (* … more type constructors *)
  let ( @-> ) p r =
    (* used for inner lambdas *)
    Lambda (p, r)
  let ( --> ) p r =
    (* used for top-level lambdas *)
    let _ =
      (* force type constraints *)
      Lambda (p, r)
    in
    (p, r)
end
```

This makes test declarations easy:

```
let test_fold_left =
  test_of_ty "fold_left"
    DSL.([ [data; data] @-> data; data; seq data ] --> monad data)
    Seq.fold_left
    SeqId.fold_left
```

## Testing the test suite

The test-suite is built on robust foundations which ensure some level of correctness.
For example, a failure of a test cannot be due to a mismatch between the inputs generator and the function being checked.

Moreover, the `ty`-based construction allows to separate the tests into different components: the inputs generator, the equality checker, the test declarations.
Reviewing the test suite can be done one component at a time.
This is much easier than revieweing a test suite without `ty`: each test has its own generator which needs to be reviewed.

Nonetheless, there could easily be issues in the test suite.
The simplest issue could be a missing test (say forgetting to test `iter`).
Another issue would be to test the library function (say `exists`) against a different yet type-compatible reference function (say `for_all`);
such an issue could hide an implementation bug.
A further issue would be that the tests would not cover a good range of input values (say never generating empty sequences).

So I wanted to test the test suite!

In another conversation with Jan he mentioned [mutaml](https://github.com/jmid/mutaml): a mutation testing tool for OCaml.

### Mutation testing

Mutation testing is a technique wherein you modify your code and check that the tests catch the modification.
For example, you change `if n = 0 then …` into `if n <> 0 then …`, you run your test suite, and you check that the tests fail.

If a mutation goes undetected by your test suite, then the test suite is likely incomplete.
(Alternatively, some of the code is dead-code.)

With a large enough set of mutations, we can increase confidence in the test suite.
In order to obtain a large set of mutations, we need to automate the process of mutating and running the test suite.
This is what mutaml provides.

### mutaml

The mutaml project provides multiple tools which, taken together, let you exercise your test suite against many mutations.

The first tool is a ppx-rewriter which introduces mutations in your code.

```
dune build --instrument-with mutaml
```

This will generate environment-based conditional mutations: something akin to `if (if env_has "MUTATION_XX" then n <> 0 else n = 0) then …`.
This approach allows the second tool to check many mutations without the need to recompile each time.

```
mutaml-runner "dune exec --no-build test/pbt/test_monadic1.exe"
```

This `mutaml-runner` generates a report: listing the test status for each mutation.
The third tool analyses this report.
It shows a summary of the findings (essentially an estimate of the coverage of the test suite) as well as each of the mutations that went undetected (if any).
These mutations are presented as a simple diff, eliminating the noisy environment-based approach that helps the runner:

E.g.,
```
Mutation "lib/standard.ml-mutant6" passed

--- lib/standard.ml
+++ lib/standard.ml-mutant6
@@ -163,7 +163,7 @@
             return false
         | Cons (y, ys) ->
             let* b = f x y in
-            if b then
+            if not b then
               return true
             else
               exists2 f xs ys
```

### Miscellaneous advice

- Make sure to disable your dune-cache when running the commands above to avoid interferences with previous work.

- Set the environment variables `QCHECK_LONG=true` and `QCHECK_LONG_FACTOR=50` to make the tests more thorough and avoid false successes.

- Edit the `_build/default/mutaml-mut-files.txt` files to only run through a subset of the mutations.

### Status of mutaml

The mutaml project is in alpha.
It needs some more work (on the UX side most notably) but it is already very useful.

Using mutaml, I had a similar feeling as when I first started using property-based testing: that of having found a very useful and practical tool that can change my programming habits significantly and for the better.
I fully intend to use mutaml in more and more projects.

I would recommend you give it a try.
