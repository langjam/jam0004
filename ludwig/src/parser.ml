
module MenhirBasics = struct
  
  exception Error
  
  let _eRR =
    fun _s ->
      raise Error
  
  type token = 
    | SLASH
    | RPAREN
    | RBRACKET
    | PIPE
    | NOTE of (
# 7 "src/parser.mly"
       (Syntax.note)
# 19 "src/parser.ml"
  )
    | LPAREN
    | LIST
    | LET
    | LBRACKET
    | LAMBDA
    | INT of (
# 6 "src/parser.mly"
       (int)
# 29 "src/parser.ml"
  )
    | IN
    | IDENT of (
# 5 "src/parser.mly"
       (string)
# 35 "src/parser.ml"
  )
    | FAIL
    | EQUALS
    | EOF
    | CONST
    | COMMA
    | COLON
    | ARROW
  
end

include MenhirBasics

# 1 "src/parser.mly"
  
open Syntax

# 53 "src/parser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_main) _menhir_state
    (** State 00.
        Stack shape : .
        Start symbol: main. *)

  | MenhirState04 : (('s, _menhir_box_main) _menhir_cell1_LPAREN, _menhir_box_main) _menhir_state
    (** State 04.
        Stack shape : LPAREN.
        Start symbol: main. *)

  | MenhirState05 : (('s, _menhir_box_main) _menhir_cell1_LIST, _menhir_box_main) _menhir_state
    (** State 05.
        Stack shape : LIST.
        Start symbol: main. *)

  | MenhirState08 : (('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 08.
        Stack shape : LET IDENT.
        Start symbol: main. *)

  | MenhirState09 : (('s, _menhir_box_main) _menhir_cell1_LBRACKET, _menhir_box_main) _menhir_state
    (** State 09.
        Stack shape : LBRACKET.
        Start symbol: main. *)

  | MenhirState12 : (('s, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 12.
        Stack shape : LAMBDA IDENT.
        Start symbol: main. *)

  | MenhirState22 : (('s, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 22.
        Stack shape : CONST IDENT.
        Start symbol: main. *)

  | MenhirState24 : (('s, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_state
    (** State 24.
        Stack shape : expr3.
        Start symbol: main. *)

  | MenhirState25 : ((('s, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON, _menhir_box_main) _menhir_state
    (** State 25.
        Stack shape : expr3 COLON.
        Start symbol: main. *)

  | MenhirState27 : (('s, _menhir_box_main) _menhir_cell1_expr2, _menhir_box_main) _menhir_state
    (** State 27.
        Stack shape : expr2.
        Start symbol: main. *)

  | MenhirState30 : (('s, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_state
    (** State 30.
        Stack shape : expr1.
        Start symbol: main. *)

  | MenhirState33 : ((('s, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 33.
        Stack shape : expr1 expr.
        Start symbol: main. *)

  | MenhirState42 : (('s, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 42.
        Stack shape : expr.
        Start symbol: main. *)

  | MenhirState45 : (('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 45.
        Stack shape : LET IDENT.
        Start symbol: main. *)

  | MenhirState47 : ((('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 47.
        Stack shape : LET IDENT expr.
        Start symbol: main. *)


and ('s, 'r) _menhir_cell1_expr = 
  | MenhirCell1_expr of 's * ('s, 'r) _menhir_state * (
# 31 "src/parser.mly"
      (Syntax.expr)
# 136 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr1 = 
  | MenhirCell1_expr1 of 's * ('s, 'r) _menhir_state * (
# 32 "src/parser.mly"
      (Syntax.expr)
# 143 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr2 = 
  | MenhirCell1_expr2 of 's * ('s, 'r) _menhir_state * (
# 33 "src/parser.mly"
      (Syntax.expr)
# 150 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr3 = 
  | MenhirCell1_expr3 of 's * ('s, 'r) _menhir_state * (
# 34 "src/parser.mly"
      (Syntax.expr)
# 157 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_COLON = 
  | MenhirCell1_COLON of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_CONST = 
  | MenhirCell1_CONST of 's * ('s, 'r) _menhir_state

and 's _menhir_cell0_IDENT = 
  | MenhirCell0_IDENT of 's * (
# 5 "src/parser.mly"
       (string)
# 170 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_LAMBDA = 
  | MenhirCell1_LAMBDA of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_LBRACKET = 
  | MenhirCell1_LBRACKET of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_LET = 
  | MenhirCell1_LET of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_LIST = 
  | MenhirCell1_LIST of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_LPAREN = 
  | MenhirCell1_LPAREN of 's * ('s, 'r) _menhir_state

and _menhir_box_main = 
  | MenhirBox_main of (
# 29 "src/parser.mly"
       (Syntax.expr)
# 192 "src/parser.ml"
) [@@unboxed]

let _menhir_action_01 =
  fun _2 _4 ->
    (
# 45 "src/parser.mly"
                           ( Lambda(_2, _4) )
# 200 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 204 "src/parser.ml"
    ))

let _menhir_action_02 =
  fun _1 ->
    (
# 46 "src/parser.mly"
            ( _1 )
# 212 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 216 "src/parser.ml"
    ))

let _menhir_action_03 =
  fun _1 _3 ->
    (
# 49 "src/parser.mly"
                      ( Choice(_1, _3) )
# 224 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 228 "src/parser.ml"
    ))

let _menhir_action_04 =
  fun _1 ->
    (
# 50 "src/parser.mly"
            ( _1 )
# 236 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 240 "src/parser.ml"
    ))

let _menhir_action_05 =
  fun _1 _3 ->
    (
# 53 "src/parser.mly"
                      ( Cons(_1, _3) )
# 248 "src/parser.ml"
     : (
# 33 "src/parser.mly"
      (Syntax.expr)
# 252 "src/parser.ml"
    ))

let _menhir_action_06 =
  fun _1 ->
    (
# 54 "src/parser.mly"
            ( _1 )
# 260 "src/parser.ml"
     : (
# 33 "src/parser.mly"
      (Syntax.expr)
# 264 "src/parser.ml"
    ))

let _menhir_action_07 =
  fun _1 _2 ->
    (
# 57 "src/parser.mly"
                      ( App(_1, _2) )
# 272 "src/parser.ml"
     : (
# 34 "src/parser.mly"
      (Syntax.expr)
# 276 "src/parser.ml"
    ))

let _menhir_action_08 =
  fun _1 ->
    (
# 58 "src/parser.mly"
                ( _1 )
# 284 "src/parser.ml"
     : (
# 34 "src/parser.mly"
      (Syntax.expr)
# 288 "src/parser.ml"
    ))

let _menhir_action_09 =
  fun _2 ->
    (
# 61 "src/parser.mly"
                                            ( _2 )
# 296 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 300 "src/parser.ml"
    ))

let _menhir_action_10 =
  fun _1 ->
    (
# 62 "src/parser.mly"
                                            ( Var(_1) )
# 308 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 312 "src/parser.ml"
    ))

let _menhir_action_11 =
  fun _2 _4 ->
    (
# 63 "src/parser.mly"
                                            ( Let(_2, _4) )
# 320 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 324 "src/parser.ml"
    ))

let _menhir_action_12 =
  fun _2 _4 _6 ->
    (
# 64 "src/parser.mly"
                                            ( Let(_2, Unify(Var(_2), _4, _6)) )
# 332 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 336 "src/parser.ml"
    ))

let _menhir_action_13 =
  fun _2 _4 ->
    (
# 65 "src/parser.mly"
                                            ( LetConst(_2, _4) )
# 344 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 348 "src/parser.ml"
    ))

let _menhir_action_14 =
  fun _1 _3 _5 ->
    (
# 66 "src/parser.mly"
                                            ( Unify(_1, _3, _5) )
# 356 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 360 "src/parser.ml"
    ))

let _menhir_action_15 =
  fun _2 ->
    (
# 67 "src/parser.mly"
                                            ( List.fold_right (fun x rest -> Cons(x, rest)) _2 EmptyList )
# 368 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 372 "src/parser.ml"
    ))

let _menhir_action_16 =
  fun _2 ->
    (
# 68 "src/parser.mly"
                                            ( Sequentialize(_2) )
# 380 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 384 "src/parser.ml"
    ))

let _menhir_action_17 =
  fun () ->
    (
# 69 "src/parser.mly"
                                            ( Fail )
# 392 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 396 "src/parser.ml"
    ))

let _menhir_action_18 =
  fun _1 ->
    (
# 70 "src/parser.mly"
                                            ( Note(8,  _1,  4) )
# 404 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 408 "src/parser.ml"
    ))

let _menhir_action_19 =
  fun _1 _3 ->
    (
# 71 "src/parser.mly"
                                            ( Note(8,  _1, _3) )
# 416 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 420 "src/parser.ml"
    ))

let _menhir_action_20 =
  fun _1 _3 ->
    (
# 72 "src/parser.mly"
                                            ( Note(_1, _3,  4) )
# 428 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 432 "src/parser.ml"
    ))

let _menhir_action_21 =
  fun _1 _3 _5 ->
    (
# 73 "src/parser.mly"
                                            ( Note(_1, _3, _5) )
# 440 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 444 "src/parser.ml"
    ))

let _menhir_action_22 =
  fun _1 ->
    (
# 42 "src/parser.mly"
               ( _1 )
# 452 "src/parser.ml"
     : (
# 29 "src/parser.mly"
       (Syntax.expr)
# 456 "src/parser.ml"
    ))

let _menhir_action_23 =
  fun () ->
    (
# 78 "src/parser.mly"
      ( [] )
# 464 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 468 "src/parser.ml"
    ))

let _menhir_action_24 =
  fun _1 ->
    (
# 79 "src/parser.mly"
              ( [_1] )
# 476 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 480 "src/parser.ml"
    ))

let _menhir_action_25 =
  fun _1 _3 ->
    (
# 80 "src/parser.mly"
                                                            ( _1 :: _3 )
# 488 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 492 "src/parser.ml"
    ))

let _menhir_print_token : token -> string =
  fun _tok ->
    match _tok with
    | ARROW ->
        "ARROW"
    | COLON ->
        "COLON"
    | COMMA ->
        "COMMA"
    | CONST ->
        "CONST"
    | EOF ->
        "EOF"
    | EQUALS ->
        "EQUALS"
    | FAIL ->
        "FAIL"
    | IDENT _ ->
        "IDENT"
    | IN ->
        "IN"
    | INT _ ->
        "INT"
    | LAMBDA ->
        "LAMBDA"
    | LBRACKET ->
        "LBRACKET"
    | LET ->
        "LET"
    | LIST ->
        "LIST"
    | LPAREN ->
        "LPAREN"
    | NOTE _ ->
        "NOTE"
    | PIPE ->
        "PIPE"
    | RBRACKET ->
        "RBRACKET"
    | RPAREN ->
        "RPAREN"
    | SLASH ->
        "SLASH"

let _menhir_fail : unit -> 'a =
  fun () ->
    Printf.eprintf "Internal failure -- please contact the parser generator's developers.\n%!";
    assert false

include struct
  
  [@@@ocaml.warning "-4-37-39"]
  
  let rec _menhir_run_53 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _v _tok ->
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let _1 = _v in
          let _v = _menhir_action_22 _1 in
          MenhirBox_main _v
      | _ ->
          _eRR ()
  
  let rec _menhir_run_01 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | SLASH ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | INT _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let (_1, _3) = (_v, _v_0) in
              let _v = _menhir_action_19 _1 _3 in
              _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
          | _ ->
              _eRR ())
      | COLON | COMMA | CONST | EOF | EQUALS | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_goto_expr_leaf : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState24 ->
          _menhir_run_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState00 ->
          _menhir_run_23_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState04 ->
          _menhir_run_23_spec_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState05 ->
          _menhir_run_23_spec_05 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState47 ->
          _menhir_run_23_spec_47 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState45 ->
          _menhir_run_23_spec_45 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState08 ->
          _menhir_run_23_spec_08 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState42 ->
          _menhir_run_23_spec_42 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState09 ->
          _menhir_run_23_spec_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState12 ->
          _menhir_run_23_spec_12 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState33 ->
          _menhir_run_23_spec_33 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState30 ->
          _menhir_run_23_spec_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState27 ->
          _menhir_run_23_spec_27 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState25 ->
          _menhir_run_23_spec_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState22 ->
          _menhir_run_23_spec_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
  
  and _menhir_run_36 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr3 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_07 _1 _2 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_24 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | NOTE _v_0 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState24
      | LPAREN ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState24
      | LIST ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState24
      | LET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState24
      | LBRACKET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState24
      | INT _v_1 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState24
      | IDENT _v_2 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v_2 in
          let _v = _menhir_action_10 _1 in
          _menhir_run_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState24
      | COLON ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _menhir_stack = MenhirCell1_COLON (_menhir_stack, MenhirState24) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_5 ->
              _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_5 MenhirState25
          | LPAREN ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState25
          | LIST ->
              _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState25
          | LET ->
              _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState25
          | LBRACKET ->
              _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState25
          | INT _v_6 ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_6 MenhirState25
          | IDENT _v_7 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_7 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_23_spec_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_23_spec_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState25
          | _ ->
              _eRR ())
      | COMMA | EOF | EQUALS | IN | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_06 _1 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LPAREN (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState04
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | LAMBDA ->
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState04
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState04
      | _ ->
          _eRR ()
  
  and _menhir_run_05 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LIST (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState05
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState05
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState05
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState05
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState05
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState05
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_05 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_05 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState05
      | _ ->
          _eRR ()
  
  and _menhir_run_06 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LET (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | IDENT _v ->
          let _menhir_stack = MenhirCell0_IDENT (_menhir_stack, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | IN ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_0 ->
                  _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState08
              | LPAREN ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | LIST ->
                  _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | LET ->
                  _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | LBRACKET ->
                  _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | LAMBDA ->
                  _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | INT _v_1 ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState08
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_23_spec_08 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_23_spec_08 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState08
              | _ ->
                  _eRR ())
          | EQUALS ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_5 ->
                  _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_5 MenhirState45
              | LPAREN ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | LIST ->
                  _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | LET ->
                  _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | LBRACKET ->
                  _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | LAMBDA ->
                  _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | INT _v_6 ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_6 MenhirState45
              | IDENT _v_7 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_7 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_23_spec_45 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_23_spec_45 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState45
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_09 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState09
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | LAMBDA ->
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState09
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
      | RBRACKET ->
          let _v = _menhir_action_23 () in
          _menhir_run_39 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _eRR ()
  
  and _menhir_run_10 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LAMBDA (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | IDENT _v ->
          let _menhir_stack = MenhirCell0_IDENT (_menhir_stack, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | ARROW ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_0 ->
                  _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState12
              | LPAREN ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | LIST ->
                  _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | LET ->
                  _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | LBRACKET ->
                  _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | LAMBDA ->
                  _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | INT _v_1 ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState12
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_23_spec_12 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_23_spec_12 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_13 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | SLASH ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | SLASH ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  (match (_tok : MenhirBasics.token) with
                  | INT _v_1 ->
                      let _tok = _menhir_lexer _menhir_lexbuf in
                      let (_1, _3, _5) = (_v, _v_0, _v_1) in
                      let _v = _menhir_action_21 _1 _3 _5 in
                      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
                  | _ ->
                      _eRR ())
              | COLON | COMMA | CONST | EOF | EQUALS | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
                  let (_1, _3) = (_v, _v_0) in
                  let _v = _menhir_action_20 _1 _3 in
                  _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_12 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState12 _tok
  
  and _menhir_run_20 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_CONST (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | IDENT _v ->
          let _menhir_stack = MenhirCell0_IDENT (_menhir_stack, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | IN ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_0 ->
                  _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState22
              | LPAREN ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | LIST ->
                  _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | LET ->
                  _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | LBRACKET ->
                  _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | LAMBDA ->
                  _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | INT _v_1 ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState22
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_23_spec_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_23_spec_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState22
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_22 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState22 _tok
  
  and _menhir_run_23_spec_09 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState09 _tok
  
  and _menhir_run_39 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_15 _2 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_23_spec_08 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState08 _tok
  
  and _menhir_run_23_spec_45 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState45 _tok
  
  and _menhir_run_23_spec_05 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LIST -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState05 _tok
  
  and _menhir_run_23_spec_04 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState04 _tok
  
  and _menhir_run_23_spec_25 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState25 _tok
  
  and _menhir_goto_expr2 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState05 ->
          _menhir_run_49 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState04 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState47 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState45 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState08 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState42 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState09 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState12 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState22 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState24 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState33 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState30 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState27 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState25 ->
          _menhir_run_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_49 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LIST as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_27 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_LIST (_menhir_stack, _menhir_s) = _menhir_stack in
          let _2 = _v in
          let _v = _menhir_action_16 _2 in
          _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_27 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr2 -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState27
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState27
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState27
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState27
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState27
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState27
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_27 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_27 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState27
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_27 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr2 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState27 _tok
  
  and _menhir_goto_expr1 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState05 ->
          _menhir_run_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState24 ->
          _menhir_run_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState25 ->
          _menhir_run_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState04 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState47 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState45 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState08 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState42 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState09 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState12 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState22 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState33 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState30 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState27 ->
          _menhir_run_29 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_35 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer
      | _ ->
          _eRR ()
  
  and _menhir_run_30 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr1 -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState30
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | LAMBDA ->
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState30
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState30
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_30 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr1 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState30 _tok
  
  and _menhir_run_31 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_02 _1 in
          _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_goto_expr : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState00 ->
          _menhir_run_53 _menhir_stack _v _tok
      | MenhirState04 ->
          _menhir_run_50 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState47 ->
          _menhir_run_48 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState45 ->
          _menhir_run_46 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState08 ->
          _menhir_run_44 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState42 ->
          _menhir_run_41 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState09 ->
          _menhir_run_41 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState12 ->
          _menhir_run_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState22 ->
          _menhir_run_37 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState33 ->
          _menhir_run_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState30 ->
          _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_50 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      match (_tok : MenhirBasics.token) with
      | RPAREN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let MenhirCell1_LPAREN (_menhir_stack, _menhir_s) = _menhir_stack in
          let _2 = _v in
          let _v = _menhir_action_09 _2 in
          _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_48 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _4) = _menhir_stack in
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _6 = _v in
      let _v = _menhir_action_12 _2 _4 _6 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_46 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState47
          | LPAREN ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | LIST ->
              _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | LET ->
              _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | LBRACKET ->
              _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | LAMBDA ->
              _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | INT _v_1 ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState47
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_23_spec_47 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_23_spec_47 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState47
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_47 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState47 _tok
  
  and _menhir_run_44 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_11 _2 _4 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_41 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | COMMA ->
          let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState42
          | LPAREN ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | LIST ->
              _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | LET ->
              _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | LBRACKET ->
              _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | LAMBDA ->
              _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | INT _v_1 ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState42
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_23_spec_42 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_23_spec_42 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState42
          | RBRACKET ->
              let _v = _menhir_action_23 () in
              _menhir_run_43 _menhir_stack _menhir_lexbuf _menhir_lexer _v
          | _ ->
              _eRR ())
      | RBRACKET ->
          let _1 = _v in
          let _v = _menhir_action_24 _1 in
          _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_42 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState42 _tok
  
  and _menhir_run_43 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_expr (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _3 = _v in
      let _v = _menhir_action_25 _1 _3 in
      _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_sep_by_trailing_COMMA_expr_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState42 ->
          _menhir_run_43 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | MenhirState09 ->
          _menhir_run_39 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_38 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LAMBDA (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_01 _2 _4 in
      _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_37 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_CONST (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_13 _2 _4 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_34 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _3) = _menhir_stack in
      let MenhirCell1_expr1 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _5 = _v in
      let _v = _menhir_action_14 _1 _3 _5 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_32 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState33
          | LPAREN ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | LIST ->
              _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | LET ->
              _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | LBRACKET ->
              _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | LAMBDA ->
              _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | INT _v_1 ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState33
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_23_spec_33 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_23_spec_33 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_23_spec_33 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState33 _tok
  
  and _menhir_run_29 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr2 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let MenhirCell1_expr2 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_03 _1 _3 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_28 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_27 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | EQUALS | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_26 : type  ttv_stack. (((ttv_stack, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_27 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | INT _ | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_COLON (_menhir_stack, _) = _menhir_stack in
          let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_05 _1 _3 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_23_spec_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00 _tok
  
  let rec _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LIST ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LET ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LBRACKET ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LAMBDA ->
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | INT _v ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_23_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_23_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | _ ->
          _eRR ()
  
end

let main =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_main v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
