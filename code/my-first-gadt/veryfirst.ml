(* Types for the properties you want to track *)
type empty = Empty
type nonempty = NonEmpty

(* Type definition *)
type _ int_list =
   | Nil : empty int_list
   | Cons : int * _ int_list -> nonempty int_list

(* Some values (type annotations can be omitted) *)
let nil : empty int_list = Nil
let onetwo : nonempty int_list = Cons (1, Cons (2, Nil))

(* Simple specialised function *)
let hd
: nonempty int_list -> int
= fun (Cons (x, _)) -> x

(* Simple generic function.
   The `type e.` part is necessary in the `ml` file.
   The type in the `mli` file is just `'e int_list -> bool`. *)
let is_empty
: type e. e int_list -> bool
= function
   | Nil -> true
   | Cons _ -> false

(* Recursive generic function.
   Same remarks as `is_empty` apply here too. *)
let rec iter
: type e. (int -> unit) -> e int_list -> unit
= fun f l ->
   match l with
   | Nil -> ()
   | Cons (x, xs) -> f x; iter f xs

(* Left as an exercise: make this tail-recursive *)
let rec length
: type e. e int_list -> int
= function
   | Nil -> 0
   | Cons (_, l) -> 1 + length l

(* constructors *)
let rec of_hd_and_list
: int -> int list -> nonempty int_list
= fun x xs ->
   match xs with
   | [] -> Cons (x, Nil)
   | y::ys ->
      let xs = of_hd_and_list y ys in
      Cons (x, xs)

let of_list
: int list -> nonempty int_list option
= function
   | [] -> None
   | hd :: tl -> Some (of_hd_and_list hd tl)

let () = iter print_int (of_hd_and_list 0 [1;2;3;4])

(* Existential constructor to wrap `int_list`s with. *)
type any_int_list = Any : _ int_list -> any_int_list

let kvs = [
   ("a", Any Nil);
   ("b", Any (Cons (0, Nil)));
   ("c", Any (Cons (1, Cons (4, Nil))));
]

(* Generic function over any `int_list`. *)
let iter_any f xs =
   match xs with
   | Any Nil -> ()
   | Any (Cons _ as xs) -> iter f xs

let () = iter_any print_int (List.assoc "c" kvs)
