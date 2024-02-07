---
title: My First GADT
subtitle: GADT tutorial part 1 of 3
...

GADTs in OCaml… You probably don't need them, but –who knows– maybe one day you will.
Also they can make for fun puzzles to figure out.
So here's a small tutorial to get you started.

The primary use of GADTs is to delegate the maintenance of some invariants of your code to the OCaml compiler's type checker.
In other words, you can use GADTs to encode custom additional typing rules which relate to some aspect of your program's logic (as opposed to the built-in typing rules which relate to the runtime safety of all programs).


## Prologue

A few notes before we start.

**You probably don't need GADTs.**
That's because you can use some other OCaml features to encode many of of the invariants that you might care about.
For example, you can use a module with a small interface around an abstract or private type.
You can also use runtime checks and return `option` or `Either.t` values.

**What even are GADTs?**
“GADT” stands for Generalised Algebraic Data Type.
I don't know why it's _Generalised_, but the _ADT_ part is essentially your sum types and product types.
Sums and products being the stuff of algebra, we have ADTs.

There are two syntaxes for sum types in OCaml, only [the more recent one](https://v2.ocaml.org/manual/gadts.html#s%3Agadts) can be used in GADTs.
Here's a comparison of the two syntaxes for the `option` type:

```
(* Classic, terse syntax *)
type 'a option =
   | None
   | Some of 'a
```

```
(* Modern, verbose, GADT-compatible syntax*)
type _ option =
   | None : 'a option
   | Some : 'a -> 'a option
```

There are two kinds of product types in OCaml: tuples and records.
This tutorial uses a mix of them just like most of the code out there.

**This tutorial has several parts.**
This first part starts with a simple GADT definition and shows how to manipulate values of that type.
It doesn't delve into anything too advanced.

A second part focuses on different techniques to use when making GADTs.
A third part focuses on real-world examples.

**All the code is available to download and play with.**
Files are linked to at different points of the tutorial.


## My Very First GADT

For your very first GADT, you will make a type which is analogous to `int list` but with a type parameter indicating whether the list is empty or not.
In other words, you make a type where the possible emptiness of a list (of integers) can be tracked by the type system.

First, declare some types which represent the property that you want to track.

```
type empty = Empty
type nonempty = NonEmpty
```

Then, declare a type `int_list` with a single type parameter which is instantiated with the property types.

```
type _ int_list =
   | Nil : empty int_list
   | Cons : int * _ int_list -> nonempty int_list
```

Note how each constructor (`Nil` and `Cons`) instantiates the type parameter differently:  
`Nil : empty int_list`  
`Cons : … -> nonempty int_list`

Based on this information, the type checker is able to assign different property types for the parameter of different values.

```
let nil : empty int_list = Nil
let onetwo : nonempty int_list = Cons (1, Cons (2, Nil))
(* you don't need the type annotations,
   the compiler can infer them. *)
```

That's it, your very first GADT.


## Using the GADT: a specialised function

Because you can enforce emptiness/fullness, you can write exception free version of, say, `Stdlib.List.hd`:

```
let hd
: nonempty int_list -> int
= fun (Cons (x, _)) -> x
```

This function's type restrict the input to only `nonempty int_list`.
This has two effects:
First, it prevents callers from passing an `empty int_list` value.
In other words, you encoded an additional rule for the type system to track.
Second, it allows you to only consider the `Cons` constructor within the body of the function.

You can try to break a few things: call `hd Nil`, add a `Nil` case to the function definition, change the type declaration of the function.
Try it!


## Using the GADT: a generic function

You can also write functions that are generic and accept both `empty` and `nonempty` parameters.

```
let is_empty
: type e. e int_list -> bool
= function
   | Nil -> true
   | Cons _ -> false
```

Note the `type e.` prefix inside the type annotation of the function.
This is needed because the type parameter `e` is different in different parts of the function.
Without it the compiler gives an error.
Try it!

You can also write generic recursive functions.
The type annotation uses the same prefix for the same reason.

```
let rec iter
: type e. (int -> unit) -> e int_list -> unit
= fun f l ->
   match l with
   | Nil -> ()
   | Cons (x, xs) -> f x; iter f xs
```

Try to define a few useful functions for this type or check out the file [`veryfirst.ml`](/code/my-first-gadt/veryfirst.ml).


## Using the GADT: existential constructor

You can write generic functions, but you cannot create a generic data-structure which hosts values of either property indiscriminately.
If you try, you get an error message.
Try the following value declaration:

```
(* broken code: type error *)
let kvs = [
   ("a", Nil);
   ("b", Cons (0, Nil));
   ("c", Cons (1, Cons (4, Nil)));
]
```

The error makes sense because the type of this value would be `(string * _ int_list) List.t` and what does that `_` even is in this context?
Another way to think about the error is to think about the return type for the following function:  
`let find_value key = List.assoc key kvs`

When you need to store values with different property parameters into a single data-structure, you need to introduce an existential constructor.
It's a new type with a new constructor which wraps the GADT so that the property type parameter disappears.
By convention, it's often call `Any` (because it wraps _any_ of the GADT value) or `E` (for “exists”).

```
type any_int_list = Any : _ int_list -> any_int_list
```

You can use it to host values with different property parameters into a single data-structure.

```
let kvs = [
   ("a", Any Nil);
   ("b", Any (Cons (0, Nil)));
   ("c", Any (Cons (1, Cons (4, Nil))));
]
```

You can recover the wrapped/hidden type parameter locally by matching:

```
let iter_any f xs =
   match xs with
   | Any Nil -> ()
   | Any (Cons _ as xs) ->
      (* in this branch only, [xs] has type [nonempty int_list] *)
      iter f xs
```


## Kinda useless

This GADT is sort of useless.
Sure you can write exception-less versions of `List.hd` and such, but it's not practical.

The main issue is that `int_list` is a new type: you cannot use functions from the `Stdlib` or any existing library.
You have to rewrite everything you need yourself.
(You could convert to `int Seq.t` but then you lose the type information.)

Note that because of the didactic intent behind `int_list`, I cut some corners in making it.
It can be made somewhat practical.
But as is it is not.

A better alternative is to use a private type alias.
See [`altveryfirst.ml`](/code/my-first-gadt/altveryfirst.ml) for an example.


## Part 2

Now that you know the basics of how to define and use a GADT, check out the next part of this tutorial:  
[GADT Tips and Tricks](/code/gadt-tips-and-tricks.html).
