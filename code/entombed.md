---
title: Entombed
...

[Entombed](https://en.wikipedia.org/wiki/Entombed_(Atari_2600)) is an Atari game from 1982.
Entombed has been the subject of [an exhaustive software-archæology study](https://programming-journal.org/2019/3/4/).
This study explains the inner-working of the game, with an important focus on the procedural generator for the game's labyrinths.

I have recreated this procedural generator in OCaml:  
[Gitlab repository](https://gitlab.com/raphael-proust/entombed) (under MIT license)


## No-nonsense variant

A compact, single-file, zero-dependency version is available in the root of the repository.
It can be executed directly by `ocaml`:

```
$ ocaml entombed.ml
▓▓░░▓▓░░░▓▓░░░▓▓░░▓▓
▓▓▓▓░░░▓▓░░▓▓░░░▓▓▓▓
▓▓▓░░▓▓▓░░░░▓▓▓░░▓▓▓
▓▓░░▓▓░░░▓▓░░░▓▓░░▓▓
▓▓▓▓▓░░▓▓▓▓▓▓░░▓▓▓▓▓
▓▓░░░░▓▓░░░░▓▓░░░░▓▓
▓▓░▓▓░▓░░▓▓░░▓░▓▓░▓▓
▓▓▓▓░░▓▓░▓▓░▓▓░░▓▓▓▓
▓▓░▓▓░░░░▓▓░░░░▓▓░▓▓
▓▓░░░░▓▓░▓▓░▓▓░░░░▓▓
▓▓░▓▓░▓░░░░░░▓░▓▓░▓▓
▓▓▓▓░░▓▓▓░░▓▓▓░░▓▓▓▓
▓▓▓░░▓▓░░░░░░▓▓░░▓▓▓
▓▓░░▓▓░░▓▓▓▓░░▓▓░░▓▓
▓▓▓▓░░░▓▓░░▓▓░░░▓▓▓▓
▓▓░░░▓▓░░░░░░▓▓░░░▓▓
▓▓▓▓░░░░▓▓▓▓░░░░▓▓▓▓
```

The sources are short and to the point.
They are straightforward to read once you have read the paper mentioned above.

First, the table that determines the output of the procedural generator.
The entries of these tables are either `wall` for when the procedural generator outputs a wall, `room` when it outputs a room, or `None` for when the procedural generator picks an output at random during generation.
There are 32 entries in the table because the procedural generator determines the content of one cell of the labyrinth based on the content of 5 other cells.

```
let table =
   let wall = Some true and room = Some false in
   [| wall; wall; wall; None; room; room; None; None;
      wall; wall; wall; wall; None; room; room; room;
      wall; wall; wall; None; room; room; room; room;
      None; room; wall; None; None; room; room; room; |]
```

Then the function that uses the procedural generator table is defined.
This `cell5` function converts 5 distinct boolean into one number and reads the corresponding entry in the table.
In case of `None`, it generates a random cell content instead.

```
let state = Random.State.make_self_init ()
let cell () = Random.State.bool state
let cell5 a b c d e =
   let ( << ) b i = (if b then 1 else 0) lsl i in
   try
      Option.get @@
      table.((e<<0) lxor (d<<1) lxor (c<<2) lxor (b<<3) lxor (a<<4))
   with Invalid_argument _ -> cell ()
```

Then the labyrinth is generated.
The first line is hard-coded and a for-loop takes care of the other lines.
Within this for-loop, each line is traversed and the cells are filled one after the other.
The details for which indexes are read to feed into the procedural generator are detailed in the paper mentioned above.

```
let l = Array.init 17 (fun _ -> Array.make 8 false)
let () =
   l.(0) <- [| false; false; true; true; false; false; false; true |]
let () =
   for y = 1 to 16 do for x = 0 to 7 do
      l.(y).(x) <- (
         if x = 0 then
            cell5 true false (cell ()) l.(y-1).(x) l.(y-1).(x+1)
         else if x = 1 then
            cell5 false l.(y).(x-1) l.(y-1).(x-1) l.(y-1).(x) l.(y-1).(x+1)
         else if x < 7 then
            cell5 l.(y).(x-2) l.(y).(x-1) l.(y-1).(x-1) l.(y-1).(x) l.(y-1).(x+1)
         else (* x = 7 *)
            cell5 l.(y).(x-2) l.(y).(x-1) l.(y-1).(x-1) l.(y-1).(x) (cell ()))
   done done
```

Finally, the labyrinth is printed onto the standard output.
Walls are represented by a dark-grey block and rooms by a light-grey block.
Note that, in order to save on memory, the game generates a half labyrinth and extends it through symmetry.
Full details are in the paper mentioned above.

```
let () =
   let render wall = print_string (if wall then "▓" else "░") in
   for y = 0 to 16 do
      render true; render true;
      for x = 0 to 7 do render l.(y).(x) done;
      for x = 7 downto 0 do render l.(y).(x) done;
      render true; render true;
      print_newline ()
   done
```

## Full-fat variant

A more engineered variant of the program is written in the `src/` directory of the repository.
It features:

- Documentation of both the implementation and the interfaces.
- Separate modules for separate parts of the program (generator, renderer, etc.).
- Command-line parameters to control many aspect of the generation and rendering process.
- Standard OCaml packaging (`dune` build file, and `opam` package file).
