---
title: Dix-mille
...


Dix-mille (Ten-thousands) is a dice game with risk/reward management. An interesting mechanics forces players to make choices not only about their own risk but also about the potential rewards for other players.

An implementation walkthrough in OCaml is presented at the end of this post. It is entirely self-contained and can be compiled with the OCaml compiler (`ocamlc`, or `ocamlopt`):

```
ocamlc -o dixmille dixmille.ml
./dixmille
```

or executed directly with the OCaml toplevel (`ocaml`):

```
ocaml dixmille.ml
```

-----------------------------------------------

[Download the implementation walkthrough](/code/dixmille.ml)
