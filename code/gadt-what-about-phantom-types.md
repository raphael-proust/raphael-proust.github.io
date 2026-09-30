---
title: "GADT: what about phantom types"
subtitle: a supplement for the GADT tutorial
...

I recently discussed some domain-modelling techniques with a colleague.

Domain modelling is the creation and maintenance of abstractions that map onto your specific problem.
You are writing [a dice game](./dixmille.html): your domain is dice and rolls and scores and turns.
You are writing financial software: your domain is monies and accounts and transactions and balances.
Etc.

Providing abstractions which cover all the domain is important.
But so is providing abstractions which forbid leaving the domain.

For example, for a dice game, you could represent the result of a dice roll as an `int`, but then [you might roll a 7](https://yugipedia.com/wiki/Dice_game).

Depending on your language you may do this in different ways.
In OCaml you tend to either use types or modules (or a combination of both).


## Constructors

A _constructor_ can mean several things in the linguo of programming languages.
In the case of ADTs and GADTs, constructors are the names of the variants.

For examples, in

```
type v =
  | Int of int
  | Char of char
  | Bool of bool
  | List of v list
  | Array of v array
```

the constructors are `Int`, `Char`, `Bool`, `List`, and `Array`.

In the case of interfaces around abstract types, constructors are the functions returning values of this type.

```
type v
val int: int -> v
val char: char -> v
val bool: bool -> v
val list: v list -> v
val array: v array -> v
```

In OCaml you can chose to export a concrete type with the variant constructors available to the rest of the code. Or you can chose to hide them and you need to expose constructor functions to the rest of the code.

(There are intermediate approaches with private types or with a concrete type you inject into the abstract type, but this is beyond the scope of this post.)


## Enforcing invariants

Let's say you need to enforce a simple invariant on the type `v` of the example above:
lists and arrays can only contain ints, chars, or bools (but never lists nor arrays).

You can enforce the invariant at the level of types.
To this end you transform your regular ADT into a GADT.

```
type shallow = Shallow
type deep = Deep
type _ v =
  | Int : int -> shallow v
  | Char : char -> shallow v
  | Bool : bool -> shallow v
  | List : shallow v list -> deep v
  | Array : shallow v array -> deep v
```

Checkout [the tutorial on GADTs](./my-first-gadt.html) if any of this is unclear.

You can also enforce the invariant at the level of modules.
To this end you expose a private type with phantom types parameters.
Phantom types are types which appear during the compilation but they are never actuallised during execution.

In OCaml it is common (though not compulsory) to use polymorphic variants for phantom types.

```
type 'depth v
val int: int -> [`Shallow] v
val char: char -> [`Shallow] v
val bool: bool -> [`Shallow] v
val list: [`Shallow] v list -> [`Deep ] v
val array: [`Shallow] v array -> [`Deep ] v
```

As you can observe, the two approaches are quite similar.
It kinda looks like an alternative syntax or like a translation to a scala-ish language.


## GADTs vs. Phantom types

There are actual differences between GADTs and Phantom types, beyond syntax.
Here's some important considerations.

### Concrete vs. abstract types

The two approaches put you on different paths regarding types being concrete/abstract.
As a result, you inherit the pros and cons of each of those.

Abstract types force you to write destructor functions (à la `Either.fold`, `Either.map`, `Either.iter`) for the values.
That's because the user can't destruct the values directly.

Concrete types cause more backwards compatibility issues.

Constructor functions can provide more checks than those enforced by phantom types.
E.g., you can check that lists and arrays are non-empty, that ints are positive, etc.
Basically any dynamic check you can add along with the static phantom type check.

### Scope of enforcement

GADTs enforce the invariant at the level of the type definition.
This means that the invariant is enforced within the scope of the type definition.
Conversely, phantom types enforce the invariant at the level of the interface (or function types).
This means that the invariant can be broken within the scope of the type definition (typically, within the `.ml` or `struct`)

Sometimes this difference makes you go for GADTs (you get stronger guarantees inside your implementation), sometimes it makes you go for phantom types (you get to break the guarantees locally as an intermediate step of computation inside your implementation).

### Compatibility with polymorphic variants

GADTs should not be used with polymorphic variant types as type parameters.
This is not actually written in the OCaml manual (is it? I can't find it) but it is advised against.

Polymorphic variants are useful for a lot of domain modelling work because they can have sub-typing relationships.
For example, the [`Tyxml`](https://github.com/ocsigen/tyxml/blob/5.0.0/lib/html_types.mli) library uses polymorphic variant phantom type parameters to enforce the well-formedness of the constructed HTML.

If you need polymorphic variants with their sub-typing, you must use phantom types.


## Tips and tricks

You can narrow the scope in which phantom type constraints are unenforced with a simple `include`/`struct`/`sig` construction.

```
include (struct
  type t =
    | Int of int
    | Char of char
    | Bool of bool
    | List of t list
    | Array of t array
  type _ v = t
  let int i = Int i
  let char c = Char c
  let bool b = Bool b
  let list l = List l
  let array a = Array a
end : sig
  type 'depth v
  val int: int -> [`Shallow] v
  val char: char -> [`Shallow] v
  val bool: bool -> [`Shallow] v
  val list: [`Shallow] v list -> [`Deep ] v
  val array: [`Shallow] v array -> [`Deep ] v
end)
```

You can add `>` and `<` markers in your polymorphic variant phantom types if they capture a more nuanced invariant with some sub-typing.

```
type 'r v
val int: int -> [`Int] v
val char: char -> [`Char] v
val bool: bool -> [`Bool] v
type shallow = [ `Int | `Char | `Bool ]
val array: [< shallow] v array -> [ `Array ] v
type u8 = [ `Char | `Bool ]
val array8: [< u8 ] v array -> [ `Array ] v
```
