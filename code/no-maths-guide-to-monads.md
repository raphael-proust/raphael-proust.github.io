---
title: A no-maths guide to monads
...

You can effectivelly use monads, even if you don't know “categories”, “monoids”, “morphisms” or all the other funny words sprinkled around the Haskell documentation.
This guide is intended for developers (thereafter “you”) who

- need to use monads, or are unsure if they need monads
- don't have the theoretical background mentioned in many tutorials

This guide assumes you know programming, and specifically some functional programming.
The examples in this guide are written in OCaml, a language with good support for (but no core dependency on) monads.


## Bindings

One of the main abstractions of programming is binding:  
naming a value.

```
(* binds the result of the multiplication to the variable name *)
let number_of_seconds_in_a_day = 60 * 60 * 24 ;;
```

Once a value has a name, the name can be used in place of the value.

```
let duration_in_seconds days = days * number_of_seconds_in_a_day ;;
```

It's such a basic feature that we don't often think about it.
It's such a basic feature but it's also such a core feature of programming.
Even more so in functional programming languages with immutable values.


## Not-quite values

Occasionally, we have something similar to a value, but, like, not exactly, like, ish, like, there is some abstraction wrapped around the value, like, it's boxed in some container, or like, it's not available just immediately but only through some boilerplate-y layer of some kind.
When you want to bind the honest salt-of-the-earth plain normal value underneath it all, you have to jump through a few hoops of syntax or safety or somesuch.

As a simple example, let's start with optional values.
You want a value, the programming language says it's maybe a value but maybe nothing or none or null or whatever your programming language calls it.
In this case you need to do a bit of legwork around the binding sites.

You end up writing code like the following.

```
let starting value =
   match Sys.getenv_opt "SEED" with
   | None -> None
   | Some seed_str ->
   match int_of_string_opt seed_str with
   | None -> None
   | Some seed -> Random.init seed; Some (Random.int 4096)
;;
```

You have to work around the `option` type's `None` constructor, but what you really want is to get the value under the `Some` constructor.
Also, you want to name the underlying value for later use.


## Abstracting the bindings

When you are writing repeating binding-related boilerplate, you can likely use a monad instead.
In the case of `option` above, you have the repeating general form

```
match <expression> with
| None -> None
| Some <variable name> -> <expression using the variable>
```

So you define

```
let bind x f =
    match x with
    | None -> None
    | Some x -> f x
;;
```

And now you can write

```
let starting value =
    bind (Sys.getenv_opt "SEED") (fun seed_str ->
    bind (int_of_string_opt seed_str) (fun seed ->
      Random.init seed; Some (Random.int 4096)))
;;
```

And that's it.
A monad.
Pretty-much.


## Syntax

Ok so you want your new abstraction to be usable?
It needs a bit of syntax.

In OCaml, you can use binding operators to provide a nice experience.

```
let ( let* ) = bind ;;
```

And then you get

```
let starting value =
    let* seed_str = Sys.getenv_opt "SEED" in
    let* seed = int_of_string_opt seed_str in
    Random.init seed; Some (Random.int 4096)
;;
```

In Rust you get to use the `let … ;?` bindings as built-in for Result and Option (but you don't get to define your own).
In Haskell you get to use `<-` bindings in `do` blocks.
In Racket you get to use `<-` bindings and `monad-do` blocks.


## Some generalisation

Still no maths… but let's take a slightly higher-level view for a bit.

Essentially, the monad has three parts:

First, the type.
In the example above it's `'a option`.
It indicates what kind of "not-quite-a value" you are handling, what kind of wrapper you have to reckon with.

Second, the `bind` function.
It takes two parameters:

- a "not-quite-a value"
- a function that operates on the normal plain honest underlying value.

The bind function can be given some additional syntax niceties depending on the language.

Third, the `return` function.
This wraps a normal value into a "not-quite-a value".
In the example above, we used the `Some` constructor directly.
If the monad is on a concrete type you can use a constructor directly, otherwise you might have to go through a function instead.

As a general form you can write the following interface to a monad:

```
module type MONAD = sig
    type 'a t
    val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
    val return : 'a -> 'a t
end ;;
```

And you can use it for the `option` type.

```
module OptionMonad
: MONAD with type 'a t = 'a option
= struct
    type 'a t = 'a option
    let ( let* ) x f = match x with None -> None | Some x -> f x
    let return x = Some x
end ;;
```

Depending on the monad, there might be a fourth part: `run`.

The `run` function "executes" the monad block.
You don't need it when the monad is based on a concrete type that you can inspect by hand.
For example you don't need a `run` function for the option monad because you can just check whether you get a `None` or a `Some`.
But if the monad is based on an abstract type, you need a way to recover the underlying result.


## What a monad "does"

There are monads for other not-quite-a-value abstractions.
More importantaly, the monads do different things, they acheive different goals.

The option monad above is a straightforward control-flow monad which interrupts a computation if a value is missing.

```
let* seed_str = Sys.getenv_opt "SEED" in
(* only if the environment variable is set
   does the computation reach this point *)
let* seed = int_of_string_opt seed_str in
(* only if the conversion to int succeeds
   does the computation reach this point *)
Random.init seed; Some (Random.int 4096)
```


**Result**  
The result monad is similar to the option monad in that it does the same thing.
The only difference is that failures carry information.

```
let ( let* ) x f = match x with
  | Error e -> Error e (* e is error information *)
  | Ok v -> f v (* carry on if x is successful *)
```


**List**  
If you want to apply your code to many possible values, you end up with some repeating patterns where you successively bind different values to the same variable.
You can abstract this with a monad.

```
let ( let* ) x f =
  List.map f x (* apply f to each value in the list x *)
  |> List.concat (* combine all the results *)
;;
```

Or more succintly

```
let ( let* ) x f = List.concat_map f x ;;
```

You can then write code which applies to all the listed input values:

```
let treasure_map =
   let* colour = [ "red"; "green"; "blue" ] in
   let* item = [ "key"; "lock" ] in
   let random_coordinates =
      (* generate fresh coordinates for each different
         combination of colour and item *)
      gen_coordinates () in
   [ (random_coordinates, colour, item) ]
;;
```

This monad doesn't really do control-flow.
It's more of a data-flow abstraction where multiple values are passed to the same function and the results are collected together.

The distinction between control-flow and data-flow monad is not necessarily relevant.
Monads can be somewhere in between.
For example,

**Backtracking**  
If you write a simple exploration algorithm using backtracking, you end up with some repeating patterns of code where you bind candidates to variable names.
(This example uses the `Seq` module to represent multiple possibilities.)

```
let ( let* ) x f = Seq.concat_map f x ;;
```

which you can then use to find a solution by exhaustively checking each candidate.
For example, finding pairs of numbers which have the same sum and product:

```
let* a = Seq.ints 0 in
let* b = Seq.ints 0 in
if a + b = a * b then Seq.return (a, b) else Seq.empty
```

For this simple backtracking monad you can define a `run` function:

```
let run b = match b () with
  | Seq.Nil -> None
  | Seq.Cons (v, _) -> Some v
```

The list monad and the backtracking monad are very similar.
In fact, the main difference is laziness in the evaluation:
the list monad traverses all the input, the backtracking monad explores enough of the input to find a solution.
You could even define the list monad as the backtracking monad with a different `run` function.

Ultimately it's not very important.
You can define your own dedicated monad even if there's a common monad available in your programming language or its ecosystem.

Keep an eye for repeating binding-related boilerplate in your (your!) code.  
Try to understand what this boilerplate does.  
See if a monad is a good fit for abstracting it away.  
Hopefully your code will be more readable for it.
