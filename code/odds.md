---
title: Odds
...

EDIT 2022-06-10: I have rewrote the code using Effects, I have rewritten this page accordingly.

[Odds (OCaml Dice Dice Something)](https://github.com/raphael-proust/odds) is a library for rolling dice.
It provides deterministic rolls.
It uses effects to push all randomness in the control of the caller.

[Github repository](https://github.com/raphael-proust/odds)  
[Documentation](./odds/index.html)  


Odds is distributed with the companion program `roll` which interprets command line arguments as a dice expression, evaluates it and prints the result.

```
roll 3d6 + 1d8 + 2
```

Originally, Odds/`roll` was an excuse to freshen up on my OCaml, and especially on the packaging aspect.
More recently, it has turned into a personal and professional experiment with Effects.

## Code overview

The code is relatively simple: a [`formula`](./odds/Dice/index.html#type-formula) is a simple algebraic data type.
It can be built by-hand or parsed from a string.

The [`eval`](./odds/Dice/index.html#val-eval) function evaluates formulas.
When doing so it performs the [`Roll`](./odds/Dice/index.html##extension-decl-Roll) effect for every dice it needs to roll.
The binary using the Odds library is responsible for installing their choice of appropriate handler.

The [`roll.ml`](https://github.com/raphael-proust/odds/blob/master/src/roll.ml) file shows a simple example of a binary using the Odds library.
It installs a simple handler using OCaml's `Random` module.
Command-line flags for verbosity and PRNG seed affect solely the effect handler.

This architecture showcases the use of effects to keep the state local to the main binary.


### Tests

A simple test checks that the parser returns the expected result.

Another test checks that the `eval` function performs the expected effects and returns the expected result.
This test does not use randomness at all: instead the test uses pre-rolled dice.


### Effects

Effects simplified the code of Odds/`roll` significantly.
Instead of threading a random state through an expression made of lambdas, the evaluation function simply delegates the randomness to the binary.
This improves the code by making it

- simple: the code of the library is more readable and more concise, monads are not needed,
- agnostic: the library does not enforce the use a specific backend for randomness, instead the application chooses which to use, and
- testable: the test binary can install a dedicated effect handler to observe the behaviour of the library.
