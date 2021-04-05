---
title: Odds
...

[Odds (OCaml Dice Dice Something)](https://github.com/raphael-proust/odds) is a library for rolling dice.
It provides deterministic rolls and combinators for common operations.

[Github repository](https://github.com/raphael-proust/odds)  
[Documentation](/code/odds/index.html)  


Odds is distributed with the companion program `roll` which interprets command line arguments as a dice expression, evaluates it and prints the result.

```
roll 3d6 + 1d8 + 2
```

Mostly, Odds/`roll` is an excuse to freshen up on my OCaml, and especially on the packaging aspect.

## Code overview

The code is relatively simple: a dice expression is a function that expects a PRNG state (`Random.State.t`) and produces a value.
The combinators that operate on these simply create new closures that dispatch the PRNG state as needed.

```
type 'a t = Random.State.t -> 'a
let lift2 f x y = fun state ->
   let x = roll state x in
   let y = roll state y in
   f x y
```

The expressions are evaluated by applying the function to a PRNG state.
If no state is provided, one is created for the whole of the expression.

```
let roll ?state t =
   let state = match state with
      | None -> Random.State.make_self_init ()
      | Some state -> state
   in
   t state
```

Finally, two modules are provided: a monad and a lifting of all of [`Pervasives`](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html) integer functions.

```
module Monad: sig
   val return: 'a -> 'a t
   val bind: 'a t -> ('a -> 'b t) -> 'b t
   val ( >>= ): 'a t -> ('a -> 'b t) -> 'b t
   val map: 'a t -> ('a -> 'b) -> 'b t
   val ( >|= ): 'a t -> ('a -> 'b) -> 'b t
end
module Algebra: sig
   val ( ! ): int -> int t
   val ( + ): int t -> int t -> int t
   val ( - ): int t -> int t -> int t
   …
end
```

### Folding through rolls

The version above is a simplification: the library also provides a way to fold through all the dice rolls that happen when an expression is evaluated.
There is a `roll_fold` function:

```
val roll_fold:
   ?state: Random.State.t ->
   folder: ('acc -> int -> int -> 'acc) ->
   init: 'acc ->
   'a t ->
   ('a * 'acc)
```

To implement this, the dice expressions take an additional argument:

```
type 'a t = Random.State.t -> (int -> int -> unit) -> 'a
```

And the `roll_fold` function creates a reference to hold the accumulator, then wraps the folding function into an imperative version that updates the reference:

```
let roll_fold ?state ~folder ~init t =
   let state = match state with
      | None -> Random.State.make_self_init ()
      | Some state -> state
   in
   let folded = ref init in
   let folder x y = folded := folder !folded x y in
   let result = roll state folder t in
   (result, !folded)
```

This is somewhat inelegant.


### roll

The `roll` companion program simply parses its arguments as a dice expression and calls the library.
To parse the arguments, it uses the library parser.
Currently, the parser only supports a handful of operators: dice, addition, subtraction, multiplication and division.

A seed can be passed as an additional argument to initialise the PRNG state.

A verbose flag prints all intermediate rolls.



## Packaging

The main reason to start the project was to refresh on the packaging (and release, etc.) part of OCaml development.
This aspect of the OCaml ecosystem has evolved a lot.

[Topkg](http://erratique.ch/software/topkg) is a packaging tool written by Daniel Bünzli.
It takes care of pretty much everything packaging wise.
I encountered minor issues, mostly due to inexperience.
(I had to force-push to my Github repository because I had forgotten dome files.)

For the release part, I was unable to automatically push to opam because of a missing dependency (`opam-publish`).
I was then unable to install it explicitly because of an unrelated error (I need to unpin Lwt).
For now, I simply made a pull request on opam-repository manually.


