module NEIntList
: sig
   type t = private int list
   val of_list : int list -> t option
   val hd : t -> int
end
= struct
   type t = int list
   let of_list = function
      | [] -> None
      | (_ :: _) as xs -> Some xs
   let hd = function
      | [] -> assert false
      | hd :: _ -> hd
end

let () =
   let xs = match NEIntList.of_list [0;1;2;3;4] with
     | None -> assert false (* list literal is non-empty *)
     | Some nel -> nel
   in
   List.iter print_int (xs :> int list);
   print_int (NEIntList.hd xs)
