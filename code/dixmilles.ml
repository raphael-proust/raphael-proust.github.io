(* # Foreword: Dix-milles

   Dix-milles (Ten-thousands) is a dice game with risk/reward management. An
   interesting mechanics forces players to make choices not only about their own
   risk but also about the potential rewards for other players.

*)

(* # Introduction: dixmilles.ml

   This file contains all the code necessary to play dix-milles. Typically, each
   individual module would be defined in their own separate file. However, the
   aim of this implementation of dix-milles is didactic. As such, it is intended
   to be read by a human more than it is intended to be compiled by a computer –
   although it is compilable by a computer.

   To ease reading, the different components of the implementation are placed in
   the same file. This gives a linear reading experience where the order is
   fixed as intended. This also frees the reader from having to set up a work
   environment that supports multi-files queries and such.

   This implementation walkthrough assumes the reader is familiar with basic
   coding, but assumes no advanced knowledge.

   With that in mind, here's a walkthrough of an implementation of dix-milles.

*)

(* # Notations:

   In OCaml, comments, like this one, are delimited by bracket-asterisk (`(*`)
   and asterisk-bracket (`*)`).

   In this file, we use markdown in all comments: code is surrounded by
   backticks (like `so`) and emphasis is marked with asterisks (like *so* ).
   Unlike standard markdown, the indentation of text is meaningless: it merely
   follows the indentation of the code.

*)

(* # Part 0: Preparation *)

module Utils = struct
  module List = struct
    let rotate l = (List.tl l) @ [List.hd l]
    let map_head f l = f (List.hd l) :: List.tl l
  end
end


(* # Part 1: Domain modeling

   Dix-milles is a dice game: during the course of the game, players roll
   (six-sided) dice. This first part of the implementation is intended to make
   it easy for the rest of the code to work with dice.

   This is called *domain modeling*, in which you create abstractions
   corresponding to the concepts that you handle in the program. If you make a
   dice game, the program handles (an abstraction of) dice, and if you make
   accounting software, the program handles monies, accounts, and balances.

   An important part of domain modeling in OCaml, and other similar languages,
   is to define *types*. The type system is a useful tool for the programmer. It
   takes some practice to use effectively, and practice often comes in the form
   of the compiler shouting at you, but it is worth the time spent.

*)

(* ## Aside: modules

   The implementation is separated into modules. The module language in OCaml is
   powerful, but we only use it for two reasons:

   - namespaces: Functions, values and types are defined inside a module so that
     the rest of the code refers to them under the module name. E.g., `D6.roll`
     rolls one six-sided die, but `D6s.roll` rolls multiple six-sided dice.
   - visibility: Some functions, values and types are defined within a module
     but are not exported in the module's signature. This limits their scope to
     the module itself, guaranteeing that code outside of the module cannot
     access them.

   Depending on specific intent, there are a few ways to introduce modules in
   OCaml. We use one form only:

   ```
   module Foo : sig
     <signature items are listed here>
   end = struct
     <implementation items are listed here>
   end
   ```

   The [OCaml manual](https://caml.inria.fr/pub/docs/manual-ocaml/index.html)
   has examples (Chapters 1-6) and formal descriptions (Chapters 7 and 8) of all
   the syntactic constructs.

*)

module D6 : sig

  (* The type `t` is for values that represent a rolled, six-sided die.

     (From outside the module it is refered to as `D6.t` (as per the discussion
     on namespaces above), but inside the module (including in the comments
     within the module) it is simply refered to as `t`.)

     The type `t` is a sum type (also known as a variant type, akin to a union).
     In this case, a rolled dice can take one of the following six values:
     `One`, `Two`, `Three`, `Four`, `Five`, `Six`.

   *)
  type t =
    | One
    | Two
    | Three
    | Four
    | Five
    | Six

  (* Another possibility would be to represent a rolled die by an integer (with
     the built-in type `int`).

     However, for our purpose the sum type is more appropriate because `int`s do
     not have static guarantees about their range (i.e., `7` would be a valid
     rolled die as far as the type system is concerned). Thus, using the sum
     type helps us lean on the type system to guarantee that all our data is
     sound. Doing so, we offload some of the reasoning about our program to an
     automated system.

     Moreover, for our purpose, rolled die are not numbers: they are never
     added together nor compared. True, the face value of a die is a good
     mnemonic for the scoring system of the game of dix-milles, but dix-milles
     could be played with dice that have abstract symbols on their faces.

  *)

  (* `roll ()` returns a single, rolled six-sided die. *)
  val roll : unit -> t

  (* The following two functions are used for pretty-printing. This is
     boilerplate code that is useful for showing the state of the game during
     interactive sessions, but it is not necessary to the game engine itself. *)
  val pp : Format.formatter -> t -> unit
  val print : t -> string

end = struct

  type t =
    | One
    | Two
    | Three
    | Four
    | Five
    | Six

  let roll () =
    (* NOTE: the `Random.int` function returns values between 0 (inclusive) and
       the passed argument (exclusive). Hence, `Random.int 6` returns either of
       those six values: `0`, `1`, `2`, `3`, `4`, `5`.

       This means the values are off-by-one: `0` is for `One` and so on. This
       happens in other parts of this implementation and is a very common
       occurrence in a lot of programs. *)
    match Random.int 6 with
    | 0 -> One
    | 1 -> Two
    | 2 -> Three
    | 3 -> Four
    | 4 -> Five
    | 5 -> Six
    | _ ->
      (* The specifications of `Random.int` guarantee that no other value can be
         obtained. *)
      assert false

  (* Boilerplate pretty-printing code. The specifics are out of the scope of
     these explanations. *)
  let pp fmt = function
    | One -> Format.pp_print_string fmt "⚀"
    | Two -> Format.pp_print_string fmt "⚁"
    | Three -> Format.pp_print_string fmt "⚂"
    | Four -> Format.pp_print_string fmt "⚃"
    | Five -> Format.pp_print_string fmt "⚄"
    | Six -> Format.pp_print_string fmt "⚅"
  let print d = Format.asprintf "%a" pp d

end


module D6s : sig

  (* The type `t` is for values representing a dice roll: a set of 6-sided dice
     that have been rolled.

     This is still part of the domain modeling. In fact, rolls of 6-sided dice
     are more important than an individual rolled 6-sided die for our purpose.
     The former is central to the game mechanics, the latter could be skipped
     although it would make some of the code later harder to read.

     Note that, in this here module's signature, the type `t` is *abstract*. It
     means that the definition of the type (its representation) is not exported
     to the other modules. As a result, code outside of this module can only
     work with values of the type `t` via the functions exported in this module.

     (The type definition is available locally in this module's implementation
     (see below) so functions of this module can still work with it.)

     Making a type abstract helps guarantee some invariants on the values of
     that type. Specifically, it ensures that local reasoning about the type is
     always correct: no code outside of this module can modify values in place,
     create new values, or otherwise break invariants.

  *)
  type t

  (* `empty` is a dice roll for zero (0) dice. *)
  val empty : t

  (* `make d6s` is a dice roll for the dice in `d6s`.

     `make [] = empty` is always `true`.
  *)
  val make : D6.t list -> t

  (* `roll n` is a dice roll of `n` randomly rolled dice.

     - `roll n` raises `Invalid_argument` if `n < 0`
     - `roll 0 = empty` is always `true`
     - `roll 1` is *equivalent* to `make [D6.roll ()]`. However, the expression
       `roll 1 = make [D6.roll ()]` causes either of the left-hand side or
       right-hand side expression to be evaluated first, which changes the PRNG
       state, which causes the other expression to evaluate under a different
       context. As a result, the expression may be `true` or `false`.
  *)
  val roll : int -> t

  (* `ones t` is the number of dice that have rolled `One` (one) in `t`.
     E.g., the following expressions are `true`:
     `ones (make []) = 0`,
     `ones (make [D6.One]) = 1`,
     `ones (make [D6.One; D6.One]) = 2`,
     `ones (make [D6.Two]) = 0`, and
     `ones (make [D6.One; D6.Two; D6.Three]) = 1`.
  *)
  val ones : t -> int

  (* `twos`, `threes`, `fours`, `fives`, `sixes`. See `ones` above. *)
  val twos : t -> int
  val threes : t -> int
  val fours : t -> int
  val fives : t -> int
  val sixes : t -> int

  (* `subset ~small ~big` is `true` iff `big` is a dice roll that includes the
     dice from `small`.

     In other words `subset ~small ~big` is `true` iff
     ∀ `face` ∈ { `ones`, `twos`, .., `sixes` }, `face small <= face big.
  *)
  val subset : small:t -> big:t -> bool

  (* `diff t1 t2` is a dice roll that includes the rolls from `t1` with the
     rolls from `t2` subtracted.

     In other words, ∀ `face` ∈ { `ones`, .., `sixes` },
     `face (diff t1 t2) = face t1 - face t2`.

     `diff t1 t2` raises `Invalid_argument` if
     `subset ~small:t2 ~big:t1` is `false`.
  *)
  val diff : t -> t -> t

  (* `Algebra` exposes the functions `subset` and `diff` as infix operators. In
     OCaml, an infix operator is defined by surrounding it in brackets. See the
     [manual]() for more details.
  *)
  module Algebra : sig

    (* `a <= b` is `subset ~small:a ~big:b` *)
    val ( <= ) : t -> t -> bool

    (* `a - b` is `diff a b` *)
    val ( - ) : t -> t -> t

  end

  (* `cardinal t` is the number of dice rolled in `t`.

     E.g., the following statements are `true`:
     - `cardinal (roll n) = n`,
     - `cardinal empty = 0`, and
     - `cardinal (diff t1 t2) = cardinal t1 - cardinal t2` (if `diff` does not
       raise `Invalid_argument`).
  *)
  val cardinal : t -> int

  (* Boilerplate code for pretty printing *)
  val pp : Format.formatter -> t -> unit
  val print : t -> string

end = struct

  (* A dice roll is represented by an array. At index `i`, the array has an
     element that indicates the number of D6 that have been rolled with the side
     matching the index.

     INVARIANT: These arrays are always of length 6. *)
  type t = int array

  (* NOTE: Beware of off-by-one errors: the face `One` is at index `0`, etc. *)
  let index_of_face =
    let open D6 in
    function
    | One -> 0
    | Two -> 1
    | Three -> 2
    | Four -> 3
    | Five -> 4
    | Six -> 5

  let init_empty () = [| 0 ; 0 ; 0 ; 0 ; 0 ; 0 |]

  (* Because the exported functions never modify a `t` in-place, it is safe to
     present the outside world with a single `empty` value. *)
  let empty = init_empty ()

  let roll n =
    if n < 0 then
      raise (Invalid_argument "D6s.roll")
    else begin
      (* initialises an new empty `t` *)
      let acc = init_empty () in
      for _ = 1 to n do (* repeat n times *)
        let i = index_of_face (D6.roll ()) in
        (* modify the local `t` in place *)
        acc.(i) <- acc.(i) + 1;
      done;
      (* return the local `t`. This value may be used outside of the present
         module (because the function `roll` is exported). However, remember
         that from the outside of the present module, `t`s are abstract which
         means that from the outside, this `t` can only be used as argument to
         functions of this module. *)
      acc
    end

  let make ds =
    (* initialises an new empty `t` *)
    let acc = init_empty () in
    List.iter
      (* For each element of `ds` .. *)
      (fun d ->
         (* .. increment the matching element in `acc`. *)
         let i = index_of_face d in
         acc.(i) <- acc.(i) + 1)
      ds;
    acc

  (* Note again the off-by-one-ness: arrays (and lists and other indexable
     collections) are 0-indexed meaning that their first element is at index
     `0`, their second element at index `1`, etc. *)
  let ones t = t.(0)
  let twos t = t.(1)
  let threes t = t.(2)
  let fours t = t.(3)
  let fives t = t.(4)
  let sixes t = t.(5)

  let unsafe_diff a b = Array.map2 (-) a b
  let subset ~small ~big = Array.for_all (fun x -> 0 <= x) (unsafe_diff big small)
  let diff a b =
    let r = unsafe_diff a b in
    if Array.exists (fun x -> x < 0) r then
      raise (Invalid_argument "D6s.diff")
    else
      r

  module Algebra = struct
    let (<=) small big = subset ~small ~big
    let (-) = diff
  end

  let cardinal = Array.fold_left (+) 0

  (* pretty printing *)
  let pp_n_times fmt n f =
    for _ = 1 to n do
      Format.pp_print_string fmt f
    done
  let pp fmt t =
    pp_n_times fmt t.(0) "⚀";
    pp_n_times fmt t.(1) "⚁";
    pp_n_times fmt t.(2) "⚂";
    pp_n_times fmt t.(3) "⚃";
    pp_n_times fmt t.(4) "⚄";
    pp_n_times fmt t.(5) "⚅"
  let print t = Format.asprintf "%a" pp t

end


(* Part 2: points and counting them

   This section is still about building foundations for the game. It can still
   be considered domain modeling, although there are more advanced functions
   written here: it is not only about the basic primitives and abstractions but
   also about some of the peculiarities of this specific game rather than the
   domain of dice game in general.

*)


(* Counting points *)
module Points : sig

  (* Points, as accumulated by a player, are represented by an integer (of the
     type `int`). Note, however, that the integer is marked as `private`. This
     ensures that points cannot be constructed outside of this here module. Such
     a restriction is useful because of one of the peculiarity of the game:

     GAME RULE: if you go beyond the target score (10000), your score "bounces".
     E.g., if you have 9750 points, you are 250 points away from the target
     score. If, in this situation you score 400 points, then, out of the 400
     points you scored, 250 points are used to increase your score up to the
     target score (10000), and the remainder (400 - 250 = 150 points) decreases
     your score down from the target score. Your final score is the target score
     minus 150 points: 10000 - 150 = 9850 points.

     To minimise the number of possible bugs, it is better to implement such
     logic once and for all, and let all other parts of the code use the one
     reference implementation. This is enforced by the use of the private type:
     the other parts of the code can use the scores as ints, but they cannot
     construct the scores except by using the reference implementation, the
     function `add` provided in this here module.

  *)
  type t = private int

  (* `zero` is `0` as a `t` *)
  val zero : t

  (* `add t i` adds `i` points to `t`, it implements the game rule discussed
     above: the score bounces back from the target score. *)
  val add : t -> int -> t

  (* `target` is `10_000` as a `t`. Providing `target` as an explicit value
     (rather than letting other parts of the code write out the literal `10000`)
     has two advantages: (1) we can change the game to use a different target by
     changing one line of the code, and (2) we ensure that no typo introduces a
     bug. *)
  val target : t

end = struct

  (* Locally, the type `t` is not private and is manipulated like an int. *)
  type t = int

  (* GAME RULE: The aim is to get ten thousand points. *)
  let target = 10_000

  let zero = 0

  let add t n =
    let sum = t + n in
    if sum <= target then
      sum
    else
      (* “bounce” when the total is beyond the target *)
      target - (sum - target)

end


(* The `Scoring` module implements the counting of points yielded by a dice
   roll. Different dice roll offer different choices to the player.

   The names in this module are more abstract. This is because the game is
   normally taught by showing (rather than naming) things. As a result,
   different players use different names for the same concepts depending on who
   taught them the game. Some rules are also expressed in a hand-wavy langauge
   that computers do not understand.

*)
module Scoring : sig

  (* An `atom` is a multiset of dice that scores a given number of points
     according to the rules. E.g., `[Six; Six; Six]` (a set of three six-sided
     dice that all rolled `Six`) is worth `600` points.

     An `atom` is represented by a `D6s.t`. (Or more technically, “a value of
     the type `atom` is represented by a value of the type `D6s.t`.”)

     The private restriction means that values of the type `atom` cannot be
     constructed outside of this module. This strikes a middle ground between
     - a concrete type (which can be constructed and destructed (meaning
       observed in some details) by any part of the code) and
     - an abstract type (which can only be constructed and destructed by parts
       of the code that have access to the definition).
     With a private type, the values can only be constructed by parts of the
     code that have access to the unrestricted definition (inside the module)
     but it can be destructed (e.g., it can be converted to `D6s.t` for free)
     anywhere.
  *)
  type atom = private D6s.t

  (* `v` lists all the existing atoms from the rules *)
  val v : atom list

  (* GAME RULE: it is possible to select multiple atoms from a roll.

     Thus, the type `t` is a series of atom. The number of points a `t` scores
     is an aggregate of the number of point each of its atom scores. *)
  type t = atom list

  (* Computes the aggregate score from a list of atom. *)
  val score: t -> int

  (* Computes the aggregate number of dice in a list of atom. *)
  val cardinal: t -> int

  (* Finds all the possible `t` that can be picked from a roll. *)
  val choices : D6s.t -> t list

  (* Pretty printing *)
  val print: t -> string
  val pp: Format.formatter -> t -> unit

end = struct

  type atom = D6s.t
  type t = atom list

  let scorer : (atom * int) list =
    let open D6 in (* for `One`, `Two`, etc. *)
    let open D6s in (* for `make: D6.t list -> D6s.t` *)
    [
      (* GAME RULE: One is worth 100 points on its own *)
      make [One], 100;
      (* GAME RULE: Repetitions of Ones are worth points as follows: 1000 for
         three Ones, 10 times more for each additional One. *)
      make [One; One; One], 1_000;
      make [One; One; One; One], 10_000;
      make [One; One; One; One; One], 100_000;
      (* GAME RULE: Repetitions of all other numbers are worth points as
         follows: Dx100 for three Ds, 10 times more for each additional D.  *)
      make [Two; Two; Two], 200;
      make [Two; Two; Two; Two], 2_000;
      make [Two; Two; Two; Two; Two], 20_000;
      make [Three; Three; Three], 300;
      make [Three; Three; Three; Three], 3_000;
      make [Three; Three; Three; Three; Three], 30_000;
      make [Four; Four; Four], 400;
      make [Four; Four; Four; Four], 4_000;
      make [Four; Four; Four; Four; Four], 40_000;
      (* GAME RULE: Five is worth 50 points on its own. *)
      make [Five], 50;
      make [Five; Five; Five], 500;
      make [Five; Five; Five; Five], 5_000;
      make [Five; Five; Five; Five; Five], 50_000;
      make [Six; Six; Six], 600;
      make [Six; Six; Six; Six], 6_000;
      make [Six; Six; Six; Six; Six], 60_000;
    ]

  let v = List.map fst scorer

  (* Score an atom by looking it up in the list `scorer` *)
  let score_atom c = List.assoc c scorer
  (* Score a `t` by summing the scores of all its atoms *)
  let score c = List.fold_left (fun acc c -> acc + score_atom c) 0 c

  let cardinal c = List.fold_left (fun acc c -> acc + D6s.cardinal c) 0 c

  (* This is the first significant piece of code. The function `choices` takes a
     dice roll and finds all the possible subsets of scoring dice that can be
     selected by a player to continue playing.

     The function `choices: D6s.t -> t list` calls the recursive function
     `choices: D6s.t -> (atom * int) list -> t list`. The former,
     declared later on in the implementation, shadows the latter. This is a
     common pattern in OCaml to hide some additional arguments that must be
     initialised in one specific way.

     The recursive function `choices` calls `after` with the sole purpose of
     eliminating duplicates in the final result. Without it, the choices that
     are returned are correct but they include, say, both `[[One]; [Five]]` and
     `[[Five]; [One]]` which are equivalent in the game.

  *)

  (* `after xs y` is the largest suffix of `xs` that starts with `y`.

     E.g., `after [0;1;2;3] 2` is `[2;3]`.

     If `y` does not appear in `xs`, then `after xs y` is `[]`.
  *)
  let rec after xs y =
    match xs with
    | [] -> []
    | z :: zs ->
      if y = z then
        xs
      else
        after zs y

  (* `choices d6s v` is a list of all the possible `t` that are valid subsets of
     `d6s`. *)
  let rec choices t v =
    let open D6s.Algebra in
    v (* Take all scoring atoms *)
    |> List.filter (fun pick -> pick <= t) (* Find those that appear in [t]*)
    |> List.map (fun pick ->
        (* each of those is a valid pick *)
        [pick] ::
        (* and so is
           this valid pick followed (`pick :: _`)
           by picks (`choices`)
           from the leftover (`t - pick`) *)
        List.map
          (fun further_choice -> pick :: further_choice)
          (choices (t - pick) (after v pick))
      )
    |> List.flatten (* cleaning up *)

  (* Shadowing `choices` so it is always applied to the expected `v`. *)
  let choices t = choices t v

  (* Boilerplate code for pretty-printing *)
  let pp_atom fmt a = Format.fprintf fmt "%a(%d)" D6s.pp a (score_atom a)
  let pp fmt d =
    let open Format in
    fprintf fmt "%a (%d)"
      (pp_print_list
         ~pp_sep:(fun fmt () -> pp_print_string fmt "·")
         pp_atom)
      d
      (score d)
  let print t = Format.asprintf "%a" pp t

end


(* Part 3: The game engine

   With all the domain fully modeled, the next part of the code is about running
   the game. The code that follows handles players making decisions, turns
   following turns, points being accumulated, and checking for victory.

*)

(* A `Strategy` is a way that players make decisions *)
module Strategy : sig

  (* A player can make three kinds of choices:
     - choose which dice to **pick** out of a roll,
     - choose whether to **bank** the current running points or continue
       rolling,
     - choose whether to **keep** the **run** of the previous player's or start
       afresh.

     Thus, a strategy is a set of three functions, one for each of these
     choices.

     Note that the type of `t` here is parametrised by `'game`. The parameter is
     intended to be given the `Game.t` type. However, because that type is
     defined later (see below in the `Game` module), we cannot use it here.

     In a way, the type `t` and the type `Game.t` are mutually recursive (i.e.,
     the type of strategies depends on the type of games, and vice versa as seen
     below). There are multiple ways to break that mutual dependency, here we
     parameterise the earlier type by the later type. As a consequence, it is
     not possible to instantiate the deisred strategies yet, this is done later
     (see module `Strategies` once the module `Game` is defined.
  *)
  type 'game t = {
    pick: (game:'game -> choices:Scoring.t list -> Scoring.t);
    bank: (game:'game -> bool);
    keep_run: (game:'game -> bool);
  }

end = struct

  type 'game t = {
    pick: (game:'game -> choices:Scoring.t list -> Scoring.t);
    bank: (game:'game -> bool);
    keep_run: (game:'game -> bool);
  }

end


(* A `Player` is a participant in the game. *)
module rec Player : sig

  (* The type `Player.t` is for the values that the game engine uses to
     represent players. Players are defined by an identifier (this is not
     strictly necessary but it is useful to determine which player actually
     won), a count of points that have already been banked, and a strategy
     (i.e., a decision making process).

     Note that `Player.t`s have a `Strategy.t` which means that they
     (transitively) depend on the type `Game.t`. As a result, the type
     `Player.t` is mutually recursive with the type `Game.t`. Unlike with
     `Strategy.t` we do not break this mutual recursion with a type parameter.
     Instead, we make the modules `Player` and `Game` mutually recursive. Note
     how the modules are declared:

     ```
     module rec Player : sig … end = struct … end
     and Game : sig … end = struct … end
     ```

  *)
  type t = {
    id: string;
    banked: Points.t;
    strategy: Game.t Strategy.t;
  }

  (* `make name strategy` is a player with the identifier `name`, the strategy
     `strategy` and 0 points banked. *)
  val make: string -> Game.t Strategy.t -> t

  (* `bank player points` adds `points` to the count of banked points of the
     player.

     More specifically, `bank p points` is a value of type `Player.t` that is
     identical to `p` except that the count of banked points is increased by
     `points`. This means that values of the type `Player.t` do not actually
     change: instead, new values with different counts of point are created. *)
  val bank: t -> int -> t

  (* Boilerplate code for pretty-printing *)
  val pp: Format.formatter -> t -> unit

end = struct

  type t = {
    id: string; (* for display only *)
    banked: Points.t;
    strategy: Game.t Strategy.t;
  }

  let make id strategy = { id; banked = Points.zero; strategy; }

  let bank player score =
    (* The syntax `{ v with f = x }` is a new value of the same type as `v`
       with all fields identical to `v`'s except for `f` that is `x`. *)
    { player with banked = Points.add player.banked score }

  let pp fmt { id; banked; _ } = Format.fprintf fmt "%s (%d)" id (banked :> int)
end

and Game : sig

  (* The type `Game.t` is for values that represent the state of a game at a
     specific point. *)
  type t = {
    players: Player.t list (* invariant: non-empty *);
    running: int;
    dice: int;
  }

  (* `make players` is the initial state of a game involving the players listed
     in the `players` argument.

     At the initial state, there are 5 dice available and 0 running points. *)
  val make: Player.t list -> t

  (* `play t` runs a game of dix-milles, starting in the state `t`. It returns
     the first state in which one of the players has reached the target number
     of point.

     In other words, `play t` is the first state reaching a victory condition in
     the sequence of states starting from `t`.
  *)
  val play: t -> t

  (* Boilerplate code for pretty-printing *)
  val pp: Format.formatter -> t -> unit

end = struct

  (* GAME PARAMETER: The game is played with five (5) dice. *)
  let number_of_dice = 5

  type t = {
    players: Player.t list;
    running: int; (* The running total *)
    dice: int; (* The number of available dice *)
  }

  let make players = { players ; running = 0; dice = number_of_dice; }

  let pp fmt { players; running; dice; } =
    Format.fprintf fmt
      "Dice: %d\n\
       Running points: %d\n\
       You:%a\n\
       Others:%a\n"
      dice
      running
      Player.pp (List.hd players)
      Format.(pp_print_list
                ~pp_sep:(fun fmt () -> pp_print_string fmt " - ")
                Player.pp)
      (List.tl players)

  (* The player whose current turn it is is the first player in the list of
     players of the game. *)
  let current_player game = List.hd game.players

  (* When a player finishes its turn, the list of players is rotated so that the
     new player is the first in the list. *)
  let next_player game = { game with players = Utils.List.rotate game.players; }

  (* When certain conditions in the game are reached (see below), the dice count
     and running total are reset. *)
  let reset_turn game = { game with running = 0; dice = number_of_dice; }

  (* When the current player decides to bank, it's score is increased by the
     running total. *)
  let bank game =
    { game with
      players =
        Utils.List.map_head (fun p -> Player.bank p game.running) game.players;
    }

  (* `play_turn` plays until the current player finishes its turn. This can
     happen in several ways (see below). *)
  let rec play_turn game =
    (* GAME RULE: The current player rolls all the available dice. *)
    let roll = D6s.roll game.dice in
    match Scoring.choices roll with
    | [] ->
      (* GAME RULE: When there are no parts of the roll that can be used to
         score points, the current player's turn ends, and the next player
         starts with a fresh counter and dice set. *)
      reset_turn game
    | _ :: _ as choices ->
      let player = current_player game in
      let choice = player.strategy.pick ~game ~choices in
      assert (List.mem choice choices); (* Check for cheating *)
      let choice_score = Scoring.score choice in
      let choice_length = Scoring.cardinal choice in
      let new_dice = game.dice - choice_length in
      (* GAME RULE: When a player picks all the available dice to contribute to
         the score, a fresh new set of dice becomes available. *)
      let new_dice = if new_dice = 0 then number_of_dice else new_dice in
      let game =
        { game with running = game.running + choice_score; dice = new_dice; }
      in
      (* The player can then decide to bank the score or not *)
      if player.strategy.bank ~game then
        bank game (* bank and finish turn *)
      else
        play_turn game (* keep playing the turn *)

  (* `play` is the core engine of the game, it calls `play_turn` in order to
     make the game progress through a single turn, and handles the handing over
     from player to next player in between turns. *)
  let rec play game =
    (* 01: If the previous player's run is unfinished, the current player
       chooses whether to reset the dice or continue on the previous player's
       run. *)
    let game =
      if game.running <> 0
      && (current_player game).strategy.keep_run ~game then
        game
      else
        reset_turn game
    in
    (* 02: the current player plays a turn *)
    let game = play_turn game in
    (* 03: if the current player has reach 10000 points then the game ends *)
    if (current_player game).banked = Points.target then
      game (* Game is finished, return the current state *)
    else
      (* 04: otherwise start with the next player. *)
      next_player game |> play

end


(* Part 4: decisions and I/O *)

(* Now that the type `Game.t` is defined, we can implement differnet strategies.
*)
module Strategies : sig

  (* `always_bank_never_keep` is a simple strategy that always banks points
     whenever possible and never keeps the previous run. This is a low-risk
     strategy that favours scoring points often but little by little rather than
     building up big scores occasionally.
  *)
  val always_bank_never_keep: Game.t Strategy.t

  (* `bank_when_one_dice` is a strategy that banks the points when there is only
      one dice left. This is a strategy that has a potential to build up bigger
      score, but is also taking more risks and thus more often ends up losing a
      turn. *)
  val bank_when_one_dice: Game.t Strategy.t

  (* `ask` is not so much a strategy as it is a primitive user-interface over
     the console. It asks the user to make decisions. *)
  val ask: Game.t Strategy.t

end = struct

  (* `with_recognise_win_picker` is a wrapper around a picker function. The
     intended use is for strategies to define their own
     `pick: game:Game.t -> choices:Score.t list -> Score.t` function that picks
     dice out of a roll, and then use `with_recognise_win picker` as their final
     picker function.

     `with_recognise_win_picker pick` is a picker function that acts the same as
     `pick` except when one of the choices allows for an instant win, then it
     picks the winning choice.
  *)
  let with_recognise_win_picker pick ~game ~choices =
    let winning =
      List.fold_left
        (fun winning choice ->
           match winning with
           | Some _ ->
             winning
           | None ->
             let can_get =
               Points.add
                 (List.hd game.Game.players).banked
                 (Scoring.score choice)
             in
             if can_get = Points.target then
               Some choice
             else
               None)
        None
        choices
    in
    match winning with
    | Some winning -> winning
    | None -> pick ~game ~choices

  (* `with_recognise_win_banker` is a wrapper function for the banking decision
     of a player's strategy. *)
  let with_recognise_win_banker bank ~game =
    let open Points in
    if add (List.hd game.Game.players).banked game.running = target then
      true
    else
      bank ~game

  let with_recognise_overflow_banker bank ~game =
    let open Points in
    let current_points = (List.hd game.Game.players).banked in
    if add current_points game.running <= current_points then
      false (* keep playing until you lose the turn (and get 0 points) rather
               than bank points that bring you down. *)
    else
      bank ~game

  (* `with_recognise_overflow_keeper is a wrapper function for the
     keeping-the-run decision of a strategy. It recognises situations where the
     run is disadvantageous (because it brings the player's points down). *)
  let with_recognise_overflow_keeper keep_run ~game =
    let open Points in
    let current_points = (List.hd game.Game.players).banked in
    if add current_points game.running <= current_points then
      false
    else
      keep_run ~game

  let with_basics { Strategy. pick; bank; keep_run } =
    { Strategy.
      pick = with_recognise_win_picker pick;
      bank = with_recognise_overflow_banker @@ with_recognise_win_banker bank;
      keep_run = with_recognise_overflow_keeper keep_run;
    }



  (* `most_points` is a picker function that takes the highest scoring choice
     available. *)
  let most_points ~game:_ ~choices = match choices with
    | [] -> assert false
    | choice :: choices ->
      fst @@
      List.fold_left
        (fun (chosen, score) choice ->
           let competing_score = Scoring.score choice in
           if competing_score > score then
             (choice, competing_score)
           else
             (chosen, score))
        (choice, Scoring.score choice)
        choices

  (* `always_bank_never_keep` and `bank_when_one_dice` are mostly just
     assemblages of the helper functions above. *)
  let always_bank_never_keep =
    with_basics
    { Strategy.
      pick = most_points;
      bank = (fun ~game:_ -> true);
      keep_run = (fun ~game:_ -> false);
    }
  let bank_when_one_dice =
    with_basics
    { Strategy.
      pick = most_points;
      bank = (fun ~game -> game.Game.dice = 1);
      keep_run = (fun ~game -> game.Game.dice > 1);
    }

  (* For the `ask` strategy, we put all the code into a submodule. This is
     mostly for readability: to place all that complexity within one single
     structure. *)
  module Ask = struct

    (* Each function in the `Ask` module implements one of the strategy's
       function as an question-answer. Questions are put forward to the user by
       printing out the state of the game along with a simple menu. This uses
       the `Format.printf` function. Answers are read as a single line. This
       uses the `read_line` function. *)

    let pick ~game ~choices =
      Format.printf "GAME:\n %a\n" Game.pp game ;
      let c = ref 0 in
      Format.printf "CHOICES:\n%a\n"
        (Format.pp_print_list
           ~pp_sep:(fun _ () -> ())
           (fun fmt choice ->
              Format.fprintf fmt "  %d : %a\n"
                !c
                Scoring.pp choice;
              incr c))
        choices;
      Format.printf "What is your choice?\n%!";
      let answer = read_line () in
      try
        List.nth choices (int_of_string answer)
      with
      | Invalid_argument _
      | Failure _
        -> assert false (* TODO: better error management *)

    let bank ~game =
      Format.printf "GAME:\n %a\n" Game.pp game ;
      Format.printf "Do you want to bank your points? [y/n]\n%!";
      let answer = read_line () in
      match String.lowercase_ascii answer with
      | "y" | "ye" | "yes" -> true
      | "n" | "no" -> false
      | _ -> assert false (* TODO: better *)

    let keep_run ~game =
      Format.printf "GAME:\n %a\n" Game.pp game ;
      Format.printf "Do you want to keep the previous player's run? [y/n]\n%!";
      let answer = read_line () in
      match String.lowercase_ascii answer with
      | "y" | "ye" | "yes" -> true
      | "n" | "no" -> false
      | _ -> assert false (* TODO: better *)


    let v = { Strategy. pick; bank; keep_run; }
  end
  let ask = Ask.v (* We export `Ask.v` under a simpler name. *)

end

(* Miscelaneous: we initialise the Pseudo-Random Number Generator *)
let () = Random.self_init ()

(* Conclusion: pluging it all *)

(* We create a game with multiple players. Note that here we put several players
   with the same strategy but different names. This can be used to study the
   win-rate of a certain strategy when following a different strategy: e.g.,
   keeping the run of an `always_bank_never_keep` player is different from
   keeping the run of a `bank_when_one_dice` player. *)
let g = Game.make [
    Player.make "bank_all_1" Strategies.always_bank_never_keep;
    Player.make "bank_all_2" Strategies.always_bank_never_keep;
    Player.make "bank_low_dice_1" Strategies.bank_when_one_dice;
    Player.make "bank_low_dice_2" Strategies.bank_when_one_dice;
    (* Uncommon the following line to put a human player in the loop *)
    (* Player.make "ask" Strategies.ask; *)
  ]

(* play the game *)
let g = Game.play g

(* print the result *)
let () =
  let open Format in
  printf
    "%a"
    (pp_print_list
       ~pp_sep:pp_print_newline
       (fun fmt player ->
          fprintf fmt "%s: %d"
            player.Player.id
            (player.Player.banked :> int)))
    g.Game.players
