---
title: GADT Tips and Tricks
subtitle: GADT tutorial part 2 of 3
...

This Tips and Tricks page assume you have a basic working knowledge of GADTs:
you know what GADTs are for,
you know how to declare a new GADT,
you know how to write functions handling values of that declared GADT,
etc.
If this is not the case, check out part 1 of this tutorial:  
[My First GADT](/code/my-first-gadt.html).

Each section in this page presents one tip/trick for using GADTs.
As a running example, I'll use the GADT defined in part 1:

```
(* property types *)
type empty = Empty
type nonempty = NonEmpty

(* GADT tracking emptyness of a monomorphic list of integer *)
type _ int_list =
   | Nil : empty int_list
   | Cons : int * _ int_list -> nonempty int_list
```

Or occasionally other GADTs as needed.

## Multiple parameters

You can use multiple type parameters.
You can even mix-and-match GADT parameters and non-GADT polymorphism parameters.

For example, you can rewrite the `int_list` type to be polymorphic:

```
type ('a, _) elist =
   | Nil : ('a, empty) elist
   | Cons : 'a * ('a, _) elist -> ('a, nonempty) elist
```

You can track multiple properties and multiple polymorphic types.
If you have many of them, there comes a point where the multiple parameter syntax becomes difficult to read.
In this case, you can use a single object type instead:

```
type yes = Yes
type no = No
type _ elist =
   | Nil : < elt: 'a; empty: yes > elist
   | Cons : 'a * < elt: 'a; empty: _ > elist -> < elt: 'a; empty: no > elist
```

Whilst the declaration is more verbose, it scales better in terms of readability because each part of the type parameter has a label.
Notice that I replaced semantically meaningful names of properties ("empty"/"nonempty") with more generic boolean value names ("yes"/"no") because the method name now bears the semantic meaning ("empty").

(Important note: the GADT uses object types for parameters, but no object appears at runtime.)


# Private constructors for property types

When you define the property types you should consider whether to make them private or not.
If the types are only ever meant to be used as type parameters, then you should probably make them private.
It will avoid users of your library constructing values out of them.

Simply add a `private` keyword in the type declaration of the property types in the `.mli` file.

```
type yes = private Yes
type no = private No
```

You might be tempted to make the types abstract, but it actually creates a serious issue:
it hides from the type checker that the different property types are distinct,
which forces the type checker to assume that the different property types could be identical,
which forces the type checker to assume that the GADTs with different property type parameters could be identical.

Basically you make the type checker forget about the distinctness of the different parts of your sum.

Note that there are legitimate uses for public constructors in your property types.
If you are in one of those cases don't use `private`.


## Built-in types as property types

Sometimes, the property you are tracking maps onto the OCaml type system.
In this case you can use the OCaml built-in types for property types.

```
type _ v =
   | Int64 : int64 -> int64 v
   | Bool : bool -> bool v
```

This happens commonly when you are handling a programming language within OCaml.
In this case GADTs allow you to embed the programming language typing rules within the OCaml type system.

```
type _ expr =
   | Value : 'a v -> 'a expr
   | Equal : 'a expr * 'a expr -> bool expr
   | IfThenElse : bool expr * 'a expr * 'a expr -> 'a expr
   (* more constructors as needed *)
```

Here a typing rule encoded by the GADT is that equality checks can only happen between values of the same type (the payload of `Eq` is `'a expr * 'a expr`).


## "Functions" over types

Sometimes you want the type parameter in your GADT to depend on the type parameter of one of the constructor argument.
For example, consider the case where you want to track the parity of the number of elements of a list.

```
(* types for the parity property *)
type odd = Odd
type even = Even
```

A straightforward way to do so is to have two distinct `Cons` constructors.

```
type (_, 'a) l =
   | Nil : (even, 'a) l
   | ConsE : 'a * (odd, 'a) l -> (even, 'a) l
   | ConsO : 'a * (even, 'a) l -> (odd, 'a) l
```

It works.
But many of the functions you might want to write such as, say, `iter` will have duplicate code for the “duplicate” constructors.

```
let rec iter
: type e. ('a -> unit) -> (e, 'a) l -> unit
= fun f l -> match l with
   | Nil -> ()
   | ConsE (x, xs) -> f x; iter f xs
   | ConsO (x, xs) -> f x; iter f xs
```

If it is proving too verbose for your specific use case, you can condense those `Cons` constructors into a single one by adding an argument.

```
type ('previous, 'current) parity =
   | O : (even, odd) parity
   | E : (odd, even) parity

type (_, 'a) l =
   | Nil : (even, 'a) l
   | Cons : 'a * ('p, 'q) parity * ('p, 'a) l -> ('q, 'a) l
```

The functions that do not care about parity can simply ignore the `parity` parameter.
The functions that do care can match on it.

The `parity` type serves both to carry information about the current parity of the constructor and as a function to relate the parity of the current `Cons` to the parity of the previous `Cons`.

Note how the first parameter of the `parity` type is the parity for the sub-list carried by the `Cons` constructor.
The second parameter is the parity for the current list.
Thus `parity` encodes a "function" over the parity property, computing the current parity (second parameter) based on the previous parity (first parameter).

To drive the point home regarding `parity` being a similar to a function, notice, within the definition of `Cons`, how `('p, 'q) parity` matches `('p, 'a) l -> ('q, 'a) l`.


## List syntax

This is not a GADT tip/trick because it applies to all ADTs.
Still, this tip/trick can be quite useful when combined with accumulator types (next tip/trick) so I'm including it here.

If your GADT (or plain ADT) is akin to lists, then you can use the built-in list constructors `[]` and `(::)`.
If you do so, then you can use the built-in list syntactic sugar for values of the type you declare.

```
type _ elist =
   | [] : < elt: 'a; empty: yes > elist
   | ( :: ) : 'a * < elt: 'a; empty: _ > elist -> < elt: 'a; empty: no > elist
```

With this type declaration, writing programs becomes easier.

```
(* declaring values using the standard list syntax *)
let xs = [3;4;5]

(* matching over values using the standard list syntax *)
let rec length
: type e. <elt: 'a; empty: e> elist -> int
= function
   | [] -> 0
   | _ :: xs -> 1 + length xs
```

Sometimes your type has some list-like aspects but also some other features.
In this case you can mix the standard list constructors with other constructors.

```
(* a type for s-expressions *)
type t =
   | [] : t
   | (::) : t * t -> t
   | Atom : string -> t
let dune_file =
   [ Atom "library";
      [ Atom "libraries" ; Atom "cmdliner" ; Atom "bos" ; Atom "astring" ];
      [ Atom "name"; Atom "queenslib" ] ]
```

(This example describe the dune file from [The Queen's head](/code/queenshead.html).)


## Accumulator of types: tuples

The type parameter of your GADT can accumulate types from different parts of the corresponding value.
A common example is the heterogeneous list:

```
type _ hlist =
   | [] : unit hlist
   | (::) : 'a * 'b hlist -> ('a * 'b) hlist
```

This allows you to keep track of the types of the different elements of the list, which can all be distinct.

```
let xs
: (int * (string * unit)) hlist
= [3; "this"]
(* the type annotation is not necessary,
   the compiler can infer it *)

let hd
: ('a * _) hlist -> 'a
= fun (x :: _) -> x
```

You can also accumulate not the type of the constructor's argument, but a type derived from the type of the constructor's arguments.
As a somewhat artificial example, you can have heterogeneous list of mutable references but you can ignore the `ref` in the property type.

```
type _ hrlist =
   | [] : unit hrlist
   | (::) : 'a ref * 'b hrlist -> ('a * 'b) hrlist

let rec set_all
: type t. t hrlist -> t hlist -> unit
= fun rs vs -> match rs, vs with
| [], [] -> ()
| r :: rs, v :: vs -> r := v; set_all rs vs
```

(Aside: Note how the OCaml compiler is able to disambiguate the different list construcors in the patterns based on the type annotation for the function.)


## Accumulator of types: arrows

Another common accumulator is arrow types.
This is often useful when you need to pass a variable number of values that correspond (in number and in type) to some function's parameters.
You end up with a call that looks like `f [x; y; z] (fun a b c -> …)` where `f` consumes the values `x`, `y`, and `z` in order to provide the arguments `a`, `b`, and `c`.

Consider the following example:

```
(* validator returns [Some error_msg] if invalid, [None] if valid *)
type 'a validator = 'a -> string option

(* a list of validators,
   [raw] is the type of the function without validation
   [validated] is the type of the function with validation *)
type ('raw, 'validated) validators =
   | [] : ('r, ('r, string) result) validators
   | (::) : 'a validator * ('r, 'v) validators -> ('a -> 'r, 'a -> 'v) validators

(* this is to consume all arguments when a validation has failed *)
let rec traverse_and_fail
: type b a. string -> (a, b) validators -> b
= fun msg vs -> match vs with
   | [] -> Error msg
   | _ :: vs -> fun _ -> traverse_and_fail msg vs

(* The main wrapper: [validate validators f] is a function
   similar to [f] but it checks the validity of its arguments. *)
let rec validate
: type raw validated. (raw, validated) validators -> raw -> validated
= fun vs f -> match vs with
   | [] -> Ok f
   | v :: vs ->
      fun x -> match v x with
         | None -> validate vs (f x)
         | Some msg -> traverse_and_fail msg vs

(* for example, [repeat] is a function for printing a string
   multiple times, but if fails on negative numbers of times and
   on empty strings *)
let repeat =
   validate
      [ (fun x -> if x < 0 then Some "negative" else None)
      ; (fun s -> if s = "" then Some "empty" else None) ]
      (fun x s -> for i = 1 to x do print_endline s done)
```


## Nested GADTs

What if your property types were also GADTs?
This can be useful when the property you are trying to track forms a sort of hierarchy.

Consider the case of a de/serialisation library in which you define codecs (`'a codec`) which are consumed by de/serialisation functions (`read : 'a codec -> char Seq.t -> 'a` and `write : 'a codec -> 'a -> char Seq.t`).

Values take a different number of bytes to represent.
In your inner representation for a `codec` you want to keep track of this number of bytes.
But it turns out that some values take

- a statically known number of bytes which is independent from the value itself (e.g., all `char`s take one byte, all `uint16` take two bytes),
- a dynamically knowable number of bytes which depends on the value itself (e.g., a null-terminated string, a utf-8 encoded unicode code-point),
- an unknowable number of bytes (e.g., a non-terminated string).

The third property might seem strange: how can you decode that?
There are two uses for them.

First, for a user-facing codec, it means that deserialisation needs additional information from the outside.
For example, if there is already a size header in the transport protocol, then there is no need for it in the application protocol and so it could simply be a non-terminated string.

Second, this unknowable property is also useful for building sound codecs.
Specifically, it helps the library keep track of unknowable-size chunks so that it can enforce there being exactly one size header for each such chunk.

Anyway, the property types are as follows (where the `s` prefix is for “sizedness”).

```
type s_static = SStatic : int -> s_static
type s_dynamic = SDynamic : s_dynamic
type _ s_knowable =
   | KnowableStatic : s_static s_knowable
   | KnowableDynamic : s_dynamic s_knowable
type s_unknowable = SUnknowable : s_unknowable
type _ sized =
   | Static : s_static s_knowable sized
   | Dynamic : s_dynamic s_knowable sized
   | Unknowable : s_unknowable sized
```

And we can define aliases for convenience:

```
type static = s_static s_knowable sized
type dynamic = s_dynamic s_knowable sized
type 'a knowable = 'a s_knowable sized
type unknowable = s_unknowable sized
```

And with this we can define the `codec` type

```
type ('a, 's) codec =
   | Uint8 :
      (* small int represented as exactly one byte *)
      (int, static) codec
   | String :
      (* string represented as a bunch of bytes,
         the size is unknowable because there are no headers and no terminators *)
      (string, unknowable) codec
   | SizeHeader :
      (* the header must have a knowable size so we can decode it,
         the main payload is unknowable,
         the result is dynamic (knowable): decode the header, that's the size *)
      (int, _ knowable) codec * ('a, unknowable) codec -> ('a, dynamic) codec
   | List :
      (* the elements of a list must have a knowable size so we know when one
         stops and the next starts,
         the result is unknowable because the number of elements can vary *)
      ('a, _ knowable) codec -> ('a list, unknowable) codec
   (* etc. *)
```

Using this GADT, it is impossible to produce a codec which has too many size headers.
Also importantly, if you produce a codec which has an unknowable size, then it is tracked in the type system and the decoding function can require an additional size argument.

```
(* autonomous decoding for self-standing codecs *)
val read : ('a, _ knowable) codec -> char Seq.t -> 'a

(* extra information (size) required for unknowable-sized codecs *)
val read_unknowable : int -> ('a, unknowable) codec -> char Seq.t -> 'a
```

This example is taken from an unreleased branch of the [`data-encoding` library](https://opam.ocaml.org/packages/data-encoding/) in which some invariant maintenance is shifted to the type system.


## A type variable cannot be deduced

EDIT NOTICE (2025-01-10): This section was added.


The compiler might reject some GADT definitions if it doesn't have enough information about the instantiated types.
For example, the following definition

```
module Mk
   (P:sig type 'a t end)
= struct
   type _ t = Wrap : 'a -> 'a P.t t
end
```

is rejected with the following error message

```
Error: In the GADT constructor
         Wrap : 'a t -> 'a P.t t
       the type variable 'a cannot be deduced from the type parameters.
```

The issue is that you can call the functor `Mk` with a parameter `P` where the type could be anything, including some problematic type definitions.

If this happens, you can circumvent the limitation in one of two ways.
You can enforce the type constructor `P.t` is injective:

```
module Mk
   (P:sig type !'a t end) (* Note the ! character *)
= struct
   type _ t = Wrap : 'a -> 'a P.t t
end
```

Alternatively, you can add a type paramter to the definition of the GADT to track the type parameter separately.

```
module Mk
   (P:sig type 'a t end)
= struct
   type (_, _) t = (* Note the second parameter *)
      | Wrap : 'a ->
         (* allow the compiler to track 'a, separately from 'a P.t *)
         ('a P.t, 'a) t
end
```

This is used in the testing library of Seqes, were a GADT describes the signature of the output of a functor: [`SUPPORT1.ty`](https://gitlab.com/raphael-proust/seqes/-/blob/036e035d040d2619c57e5670c85e8e3b7e654c83/test/pbt/testHelpers.ml#L100).


## Next part: the gallery

The next part of the tutorial is a gallery of interesting GADTs in different public open-source OCaml packages:  
[GADT Gallery](/code/gadt-gallery.html)
