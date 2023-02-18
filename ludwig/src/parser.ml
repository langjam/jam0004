
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
    | DURATION of (
# 8 "src/parser.mly"
       (Syntax.duration)
# 42 "src/parser.ml"
  )
    | COMMA
    | COLON
    | ARROW
  
end

include MenhirBasics

# 1 "src/parser.mly"
  
open Syntax

# 56 "src/parser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_expr) _menhir_state
    (** State 00.
        Stack shape : .
        Start symbol: expr. *)

  | MenhirState02 : (('s, _menhir_box_expr) _menhir_cell1_LPAREN, _menhir_box_expr) _menhir_state
    (** State 02.
        Stack shape : LPAREN.
        Start symbol: expr. *)

  | MenhirState03 : (('s, _menhir_box_expr) _menhir_cell1_LIST, _menhir_box_expr) _menhir_state
    (** State 03.
        Stack shape : LIST.
        Start symbol: expr. *)

  | MenhirState06 : (('s, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_expr) _menhir_state
    (** State 06.
        Stack shape : LET IDENT.
        Start symbol: expr. *)

  | MenhirState07 : (('s, _menhir_box_expr) _menhir_cell1_LBRACKET, _menhir_box_expr) _menhir_state
    (** State 07.
        Stack shape : LBRACKET.
        Start symbol: expr. *)

  | MenhirState10 : (('s, _menhir_box_expr) _menhir_cell1_LAMBDA _menhir_cell0_IDENT, _menhir_box_expr) _menhir_state
    (** State 10.
        Stack shape : LAMBDA IDENT.
        Start symbol: expr. *)

  | MenhirState14 : (('s, _menhir_box_expr) _menhir_cell1_expr3, _menhir_box_expr) _menhir_state
    (** State 14.
        Stack shape : expr3.
        Start symbol: expr. *)

  | MenhirState15 : ((('s, _menhir_box_expr) _menhir_cell1_expr3, _menhir_box_expr) _menhir_cell1_COLON, _menhir_box_expr) _menhir_state
    (** State 15.
        Stack shape : expr3 COLON.
        Start symbol: expr. *)

  | MenhirState17 : (('s, _menhir_box_expr) _menhir_cell1_expr2, _menhir_box_expr) _menhir_state
    (** State 17.
        Stack shape : expr2.
        Start symbol: expr. *)

  | MenhirState20 : (('s, _menhir_box_expr) _menhir_cell1_expr1, _menhir_box_expr) _menhir_state
    (** State 20.
        Stack shape : expr1.
        Start symbol: expr. *)

  | MenhirState23 : ((('s, _menhir_box_expr) _menhir_cell1_expr1, _menhir_box_expr) _menhir_cell1_expr, _menhir_box_expr) _menhir_state
    (** State 23.
        Stack shape : expr1 expr.
        Start symbol: expr. *)

  | MenhirState31 : (('s, _menhir_box_expr) _menhir_cell1_expr, _menhir_box_expr) _menhir_state
    (** State 31.
        Stack shape : expr.
        Start symbol: expr. *)

  | MenhirState34 : (('s, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_expr) _menhir_state
    (** State 34.
        Stack shape : LET IDENT.
        Start symbol: expr. *)

  | MenhirState36 : ((('s, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_expr) _menhir_cell1_expr, _menhir_box_expr) _menhir_state
    (** State 36.
        Stack shape : LET IDENT expr.
        Start symbol: expr. *)


and ('s, 'r) _menhir_cell1_expr = 
  | MenhirCell1_expr of 's * ('s, 'r) _menhir_state * (
# 27 "src/parser.mly"
       (Syntax.expr)
# 134 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr1 = 
  | MenhirCell1_expr1 of 's * ('s, 'r) _menhir_state * (
# 29 "src/parser.mly"
      (Syntax.expr)
# 141 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr2 = 
  | MenhirCell1_expr2 of 's * ('s, 'r) _menhir_state * (
# 30 "src/parser.mly"
      (Syntax.expr)
# 148 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr3 = 
  | MenhirCell1_expr3 of 's * ('s, 'r) _menhir_state * (
# 31 "src/parser.mly"
      (Syntax.expr)
# 155 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_COLON = 
  | MenhirCell1_COLON of 's * ('s, 'r) _menhir_state

and 's _menhir_cell0_IDENT = 
  | MenhirCell0_IDENT of 's * (
# 5 "src/parser.mly"
       (string)
# 165 "src/parser.ml"
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

and _menhir_box_expr = 
  | MenhirBox_expr of (
# 27 "src/parser.mly"
       (Syntax.expr)
# 187 "src/parser.ml"
) [@@unboxed]

let _menhir_action_01 =
  fun _2 _4 ->
    (
# 39 "src/parser.mly"
                            ( Lambda(_2, _4) )
# 195 "src/parser.ml"
     : (
# 27 "src/parser.mly"
       (Syntax.expr)
# 199 "src/parser.ml"
    ))

let _menhir_action_02 =
  fun _1 ->
    (
# 40 "src/parser.mly"
            ( _1 )
# 207 "src/parser.ml"
     : (
# 27 "src/parser.mly"
       (Syntax.expr)
# 211 "src/parser.ml"
    ))

let _menhir_action_03 =
  fun _1 _3 ->
    (
# 43 "src/parser.mly"
                      ( Choice(_1, _3) )
# 219 "src/parser.ml"
     : (
# 29 "src/parser.mly"
      (Syntax.expr)
# 223 "src/parser.ml"
    ))

let _menhir_action_04 =
  fun _1 ->
    (
# 44 "src/parser.mly"
            ( _1 )
# 231 "src/parser.ml"
     : (
# 29 "src/parser.mly"
      (Syntax.expr)
# 235 "src/parser.ml"
    ))

let _menhir_action_05 =
  fun _1 _3 ->
    (
# 47 "src/parser.mly"
                      ( Cons(_1, _3) )
# 243 "src/parser.ml"
     : (
# 30 "src/parser.mly"
      (Syntax.expr)
# 247 "src/parser.ml"
    ))

let _menhir_action_06 =
  fun _1 ->
    (
# 48 "src/parser.mly"
            ( _1 )
# 255 "src/parser.ml"
     : (
# 30 "src/parser.mly"
      (Syntax.expr)
# 259 "src/parser.ml"
    ))

let _menhir_action_07 =
  fun _1 _2 ->
    (
# 51 "src/parser.mly"
                      ( App(_1, _2) )
# 267 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 271 "src/parser.ml"
    ))

let _menhir_action_08 =
  fun _1 ->
    (
# 52 "src/parser.mly"
                ( _1 )
# 279 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 283 "src/parser.ml"
    ))

let _menhir_action_09 =
  fun _2 ->
    (
# 55 "src/parser.mly"
                                            ( _2 )
# 291 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 295 "src/parser.ml"
    ))

let _menhir_action_10 =
  fun _1 ->
    (
# 56 "src/parser.mly"
                                            ( Var(_1, None) )
# 303 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 307 "src/parser.ml"
    ))

let _menhir_action_11 =
  fun _2 _4 ->
    (
# 57 "src/parser.mly"
                                            ( Let(_2, _4) )
# 315 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 319 "src/parser.ml"
    ))

let _menhir_action_12 =
  fun _2 _4 _6 ->
    (
# 58 "src/parser.mly"
                                            ( Let(_2, Unify(Var(_2, None), _4, _6)) )
# 327 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 331 "src/parser.ml"
    ))

let _menhir_action_13 =
  fun _1 _3 _5 ->
    (
# 59 "src/parser.mly"
                                            ( Unify(_1, _3, _5) )
# 339 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 343 "src/parser.ml"
    ))

let _menhir_action_14 =
  fun _2 ->
    (
# 60 "src/parser.mly"
                                            ( List.fold_right (fun x rest -> Cons(x, rest)) _2 EmptyList )
# 351 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 355 "src/parser.ml"
    ))

let _menhir_action_15 =
  fun _2 ->
    (
# 61 "src/parser.mly"
                                            ( Sequentialize(_2) )
# 363 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 367 "src/parser.ml"
    ))

let _menhir_action_16 =
  fun () ->
    (
# 62 "src/parser.mly"
                                            ( Fail )
# 375 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 379 "src/parser.ml"
    ))

let _menhir_action_17 =
  fun _1 ->
    (
# 63 "src/parser.mly"
                                            ( Note(_1) )
# 387 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 391 "src/parser.ml"
    ))

let _menhir_action_18 =
  fun () ->
    (
# 69 "src/parser.mly"
      ( [] )
# 399 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr list)
# 403 "src/parser.ml"
    ))

let _menhir_action_19 =
  fun _1 ->
    (
# 70 "src/parser.mly"
              ( [_1] )
# 411 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr list)
# 415 "src/parser.ml"
    ))

let _menhir_action_20 =
  fun _1 _3 ->
    (
# 71 "src/parser.mly"
                                                            ( _1 :: _3 )
# 423 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr list)
# 427 "src/parser.ml"
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
    | DURATION _ ->
        "DURATION"
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
  
  let rec _menhir_run_41_spec_00 : type  ttv_stack. ttv_stack -> _ -> _menhir_box_expr =
    fun _menhir_stack _v ->
      MenhirBox_expr _v
  
  let rec _menhir_run_13_spec_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00 _tok
  
  and _menhir_run_14 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | NOTE _v_0 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v_0 in
          let _v = _menhir_action_17 _1 in
          _menhir_run_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState14
      | LIST ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState14
      | LET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState14
      | LBRACKET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState14
      | IDENT _v_2 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v_2 in
          let _v = _menhir_action_10 _1 in
          _menhir_run_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | COLON ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _menhir_stack = MenhirCell1_COLON (_menhir_stack, MenhirState14) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_5 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_5 in
              let _v = _menhir_action_17 _1 in
              _menhir_run_13_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
          | IDENT _v_7 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_7 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_13_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_16 () in
              _menhir_run_13_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | _ ->
              _eRR ())
      | COMMA | EQUALS | IN | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_06 _1 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_26 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr3 -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_07 _1 _2 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_02 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LPAREN (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | LAMBDA ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_13_spec_02 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState02 _tok
  
  and _menhir_run_03 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LIST (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState03
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState03
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState03
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState03
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_13_spec_03 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LIST -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState03 _tok
  
  and _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
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
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_0 in
                  let _v = _menhir_action_17 _1 in
                  _menhir_run_13_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | LAMBDA ->
                  _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_13_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_16 () in
                  _menhir_run_13_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | _ ->
                  _eRR ())
          | EQUALS ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_5 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_5 in
                  let _v = _menhir_action_17 _1 in
                  _menhir_run_13_spec_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState34
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState34
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState34
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState34
              | LAMBDA ->
                  _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState34
              | IDENT _v_7 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_7 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_13_spec_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_16 () in
                  _menhir_run_13_spec_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_13_spec_06 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState06 _tok
  
  and _menhir_run_07 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | LAMBDA ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | RBRACKET ->
          let _v = _menhir_action_18 () in
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _eRR ()
  
  and _menhir_run_13_spec_07 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState07 _tok
  
  and _menhir_run_08 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
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
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_0 in
                  let _v = _menhir_action_17 _1 in
                  _menhir_run_13_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_13_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_16 () in
                  _menhir_run_13_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_13_spec_10 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LAMBDA _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState10 _tok
  
  and _menhir_run_28 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_14 _2 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_expr_leaf : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState14 ->
          _menhir_run_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState00 ->
          _menhir_run_13_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState02 ->
          _menhir_run_13_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState03 ->
          _menhir_run_13_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState36 ->
          _menhir_run_13_spec_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState34 ->
          _menhir_run_13_spec_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState06 ->
          _menhir_run_13_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState31 ->
          _menhir_run_13_spec_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState07 ->
          _menhir_run_13_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState23 ->
          _menhir_run_13_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState20 ->
          _menhir_run_13_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState17 ->
          _menhir_run_13_spec_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState15 ->
          _menhir_run_13_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState10 ->
          _menhir_run_13_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
  
  and _menhir_run_13_spec_36 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState36 _tok
  
  and _menhir_run_13_spec_34 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState34 _tok
  
  and _menhir_run_13_spec_31 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState31 _tok
  
  and _menhir_run_13_spec_23 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_expr1, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState23 _tok
  
  and _menhir_run_13_spec_20 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr1 -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState20 _tok
  
  and _menhir_run_13_spec_17 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr2 -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState17 _tok
  
  and _menhir_run_13_spec_15 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_expr3, _menhir_box_expr) _menhir_cell1_COLON -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState15 _tok
  
  and _menhir_goto_expr2 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState03 ->
          _menhir_run_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState02 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState36 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState34 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState31 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState10 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState14 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState23 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState20 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState17 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState15 ->
          _menhir_run_16 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_38 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_LIST as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_LIST (_menhir_stack, _menhir_s) = _menhir_stack in
          let _2 = _v in
          let _v = _menhir_action_15 _2 in
          _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_17 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr2 -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | _ ->
          _eRR ()
  
  and _menhir_goto_expr1 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState10 ->
          _menhir_run_27 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState03 ->
          _menhir_run_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState14 ->
          _menhir_run_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState15 ->
          _menhir_run_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState02 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState36 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState34 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState31 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState23 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState20 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState17 ->
          _menhir_run_19 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_27 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_LAMBDA _menhir_cell0_IDENT as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
          let MenhirCell1_LAMBDA (_menhir_stack, _menhir_s) = _menhir_stack in
          let _4 = _v in
          let _v = _menhir_action_01 _2 _4 in
          _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_20 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr1 -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LAMBDA ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | _ ->
          _eRR ()
  
  and _menhir_goto_expr : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState00 ->
          _menhir_run_41_spec_00 _menhir_stack _v
      | MenhirState02 ->
          _menhir_run_39 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState36 ->
          _menhir_run_37 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState34 ->
          _menhir_run_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_33 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState31 ->
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState23 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState20 ->
          _menhir_run_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_39 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_expr =
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
  
  and _menhir_run_37 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _4) = _menhir_stack in
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _6 = _v in
      let _v = _menhir_action_12 _2 _4 _6 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_35 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_17 _1 in
              _menhir_run_13_spec_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState36
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState36
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState36
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState36
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState36
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_13_spec_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_16 () in
              _menhir_run_13_spec_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_33 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_11 _2 _4 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_30 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | COMMA ->
          let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_17 _1 in
              _menhir_run_13_spec_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState31
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState31
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState31
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState31
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState31
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_13_spec_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_16 () in
              _menhir_run_13_spec_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | RBRACKET ->
              let _v = _menhir_action_18 () in
              _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v
          | _ ->
              _eRR ())
      | RBRACKET ->
          let _1 = _v in
          let _v = _menhir_action_19 _1 in
          _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_32 : type  ttv_stack. (ttv_stack, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_expr (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _3 = _v in
      let _v = _menhir_action_20 _1 _3 in
      _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_sep_by_trailing_COMMA_expr_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState31 ->
          _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | MenhirState07 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_24 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_expr1, _menhir_box_expr) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _3) = _menhir_stack in
      let MenhirCell1_expr1 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _5 = _v in
      let _v = _menhir_action_13 _1 _3 _5 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_22 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_expr1 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_17 _1 in
              _menhir_run_13_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_13_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_16 () in
              _menhir_run_13_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_25 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | _ ->
          _eRR ()
  
  and _menhir_run_21 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_02 _1 in
          _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_19 : type  ttv_stack. ((ttv_stack, _menhir_box_expr) _menhir_cell1_expr2 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let MenhirCell1_expr2 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_03 _1 _3 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_18 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | EQUALS | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_16 : type  ttv_stack. (((ttv_stack, _menhir_box_expr) _menhir_cell1_expr3, _menhir_box_expr) _menhir_cell1_COLON as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_expr) _menhir_state -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_COLON (_menhir_stack, _) = _menhir_stack in
          let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_05 _1 _3 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  let rec _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_expr =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_17 _1 in
          _menhir_run_13_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LAMBDA ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_13_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_16 () in
          _menhir_run_13_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | _ ->
          _eRR ()
  
end

let expr =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_expr v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
