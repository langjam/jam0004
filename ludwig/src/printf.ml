(* We need this module stub so that ReScript accepts the Menhir generated parser.
   Menhir only uses eprintf in case of a critical internal bug in the parser and it never uses any formatting options, 
   so we should be fine if we just replace it by print_string. *)

let eprintf message = print_string message