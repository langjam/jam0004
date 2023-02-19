
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
    | DURATION of (
# 8 "src/parser.mly"
       (Syntax.duration)
# 43 "src/parser.ml"
  )
    | CONST
    | COMMA
    | COLON
    | ARROW
  
end

include MenhirBasics

# 1 "src/parser.mly"
  
open Syntax

# 58 "src/parser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_main) _menhir_state
    (** State 00.
        Stack shape : .
        Start symbol: main. *)

  | MenhirState02 : (('s, _menhir_box_main) _menhir_cell1_LPAREN, _menhir_box_main) _menhir_state
    (** State 02.
        Stack shape : LPAREN.
        Start symbol: main. *)

  | MenhirState03 : (('s, _menhir_box_main) _menhir_cell1_LIST, _menhir_box_main) _menhir_state
    (** State 03.
        Stack shape : LIST.
        Start symbol: main. *)

  | MenhirState06 : (('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 06.
        Stack shape : LET IDENT.
        Start symbol: main. *)

  | MenhirState07 : (('s, _menhir_box_main) _menhir_cell1_LBRACKET, _menhir_box_main) _menhir_state
    (** State 07.
        Stack shape : LBRACKET.
        Start symbol: main. *)

  | MenhirState10 : (('s, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 10.
        Stack shape : LAMBDA IDENT.
        Start symbol: main. *)

  | MenhirState15 : (('s, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 15.
        Stack shape : CONST IDENT.
        Start symbol: main. *)

  | MenhirState17 : (('s, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_state
    (** State 17.
        Stack shape : expr3.
        Start symbol: main. *)

  | MenhirState18 : ((('s, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON, _menhir_box_main) _menhir_state
    (** State 18.
        Stack shape : expr3 COLON.
        Start symbol: main. *)

  | MenhirState20 : (('s, _menhir_box_main) _menhir_cell1_expr2, _menhir_box_main) _menhir_state
    (** State 20.
        Stack shape : expr2.
        Start symbol: main. *)

  | MenhirState23 : (('s, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_state
    (** State 23.
        Stack shape : expr1.
        Start symbol: main. *)

  | MenhirState26 : ((('s, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 26.
        Stack shape : expr1 expr.
        Start symbol: main. *)

  | MenhirState35 : (('s, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 35.
        Stack shape : expr.
        Start symbol: main. *)

  | MenhirState38 : (('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_state
    (** State 38.
        Stack shape : LET IDENT.
        Start symbol: main. *)

  | MenhirState40 : ((('s, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr, _menhir_box_main) _menhir_state
    (** State 40.
        Stack shape : LET IDENT expr.
        Start symbol: main. *)


and ('s, 'r) _menhir_cell1_expr = 
  | MenhirCell1_expr of 's * ('s, 'r) _menhir_state * (
# 31 "src/parser.mly"
      (Syntax.expr)
# 141 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr1 = 
  | MenhirCell1_expr1 of 's * ('s, 'r) _menhir_state * (
# 32 "src/parser.mly"
      (Syntax.expr)
# 148 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr2 = 
  | MenhirCell1_expr2 of 's * ('s, 'r) _menhir_state * (
# 33 "src/parser.mly"
      (Syntax.expr)
# 155 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_expr3 = 
  | MenhirCell1_expr3 of 's * ('s, 'r) _menhir_state * (
# 34 "src/parser.mly"
      (Syntax.expr)
# 162 "src/parser.ml"
)

and ('s, 'r) _menhir_cell1_COLON = 
  | MenhirCell1_COLON of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_CONST = 
  | MenhirCell1_CONST of 's * ('s, 'r) _menhir_state

and 's _menhir_cell0_IDENT = 
  | MenhirCell0_IDENT of 's * (
# 5 "src/parser.mly"
       (string)
# 175 "src/parser.ml"
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
# 197 "src/parser.ml"
) [@@unboxed]

let _menhir_action_01 =
  fun _2 _4 ->
    (
# 45 "src/parser.mly"
                           ( Lambda(_2, _4) )
# 205 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 209 "src/parser.ml"
    ))

let _menhir_action_02 =
  fun _1 ->
    (
# 46 "src/parser.mly"
            ( _1 )
# 217 "src/parser.ml"
     : (
# 31 "src/parser.mly"
      (Syntax.expr)
# 221 "src/parser.ml"
    ))

let _menhir_action_03 =
  fun _1 _3 ->
    (
# 49 "src/parser.mly"
                      ( Choice(_1, _3) )
# 229 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 233 "src/parser.ml"
    ))

let _menhir_action_04 =
  fun _1 ->
    (
# 50 "src/parser.mly"
            ( _1 )
# 241 "src/parser.ml"
     : (
# 32 "src/parser.mly"
      (Syntax.expr)
# 245 "src/parser.ml"
    ))

let _menhir_action_05 =
  fun _1 _3 ->
    (
# 53 "src/parser.mly"
                      ( Cons(_1, _3) )
# 253 "src/parser.ml"
     : (
# 33 "src/parser.mly"
      (Syntax.expr)
# 257 "src/parser.ml"
    ))

let _menhir_action_06 =
  fun _1 ->
    (
# 54 "src/parser.mly"
            ( _1 )
# 265 "src/parser.ml"
     : (
# 33 "src/parser.mly"
      (Syntax.expr)
# 269 "src/parser.ml"
    ))

let _menhir_action_07 =
  fun _1 _2 ->
    (
# 57 "src/parser.mly"
                      ( App(_1, _2) )
# 277 "src/parser.ml"
     : (
# 34 "src/parser.mly"
      (Syntax.expr)
# 281 "src/parser.ml"
    ))

let _menhir_action_08 =
  fun _1 ->
    (
# 58 "src/parser.mly"
                ( _1 )
# 289 "src/parser.ml"
     : (
# 34 "src/parser.mly"
      (Syntax.expr)
# 293 "src/parser.ml"
    ))

let _menhir_action_09 =
  fun _2 ->
    (
# 61 "src/parser.mly"
                                            ( _2 )
# 301 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 305 "src/parser.ml"
    ))

let _menhir_action_10 =
  fun _1 ->
    (
# 62 "src/parser.mly"
                                            ( Var(_1) )
# 313 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 317 "src/parser.ml"
    ))

let _menhir_action_11 =
  fun _2 _4 ->
    (
# 63 "src/parser.mly"
                                            ( Let(_2, _4) )
# 325 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 329 "src/parser.ml"
    ))

let _menhir_action_12 =
  fun _2 _4 _6 ->
    (
# 64 "src/parser.mly"
                                            ( Let(_2, Unify(Var(_2), _4, _6)) )
# 337 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 341 "src/parser.ml"
    ))

let _menhir_action_13 =
  fun _2 _4 ->
    (
# 65 "src/parser.mly"
                                            ( LetConst(_2, _4) )
# 349 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 353 "src/parser.ml"
    ))

let _menhir_action_14 =
  fun _1 _3 _5 ->
    (
# 66 "src/parser.mly"
                                            ( Unify(_1, _3, _5) )
# 361 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 365 "src/parser.ml"
    ))

let _menhir_action_15 =
  fun _2 ->
    (
# 67 "src/parser.mly"
                                            ( List.fold_right (fun x rest -> Cons(x, rest)) _2 EmptyList )
# 373 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 377 "src/parser.ml"
    ))

let _menhir_action_16 =
  fun _2 ->
    (
# 68 "src/parser.mly"
                                            ( Sequentialize(_2) )
# 385 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 389 "src/parser.ml"
    ))

let _menhir_action_17 =
  fun () ->
    (
# 69 "src/parser.mly"
                                            ( Fail )
# 397 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 401 "src/parser.ml"
    ))

let _menhir_action_18 =
  fun _1 ->
    (
# 70 "src/parser.mly"
                                            ( Note(_1) )
# 409 "src/parser.ml"
     : (
# 35 "src/parser.mly"
      (Syntax.expr)
# 413 "src/parser.ml"
    ))

let _menhir_action_19 =
  fun _1 ->
    (
# 42 "src/parser.mly"
               ( _1 )
# 421 "src/parser.ml"
     : (
# 29 "src/parser.mly"
       (Syntax.expr)
# 425 "src/parser.ml"
    ))

let _menhir_action_20 =
  fun () ->
    (
# 76 "src/parser.mly"
      ( [] )
# 433 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 437 "src/parser.ml"
    ))

let _menhir_action_21 =
  fun _1 ->
    (
# 77 "src/parser.mly"
              ( [_1] )
# 445 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 449 "src/parser.ml"
    ))

let _menhir_action_22 =
  fun _1 _3 ->
    (
# 78 "src/parser.mly"
                                                            ( _1 :: _3 )
# 457 "src/parser.ml"
     : (
# 38 "src/parser.mly"
      (Syntax.expr list)
# 461 "src/parser.ml"
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
    | DURATION _ ->
        "DURATION"
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
  
  let rec _menhir_run_46 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _v _tok ->
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let _1 = _v in
          let _v = _menhir_action_19 _1 in
          MenhirBox_main _v
      | _ ->
          _eRR ()
  
  let rec _menhir_run_16_spec_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00 _tok
  
  and _menhir_run_17 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | NOTE _v_0 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v_0 in
          let _v = _menhir_action_18 _1 in
          _menhir_run_29 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LIST ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | LBRACKET ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | IDENT _v_2 ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v_2 in
          let _v = _menhir_action_10 _1 in
          _menhir_run_29 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_29 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState17
      | COLON ->
          let _menhir_stack = MenhirCell1_expr3 (_menhir_stack, _menhir_s, _v) in
          let _menhir_stack = MenhirCell1_COLON (_menhir_stack, MenhirState17) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_5 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_5 in
              let _v = _menhir_action_18 _1 in
              _menhir_run_16_spec_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState18
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState18
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState18
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState18
          | IDENT _v_7 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_7 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_16_spec_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_16_spec_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState18
          | _ ->
              _eRR ())
      | COMMA | EOF | EQUALS | IN | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_06 _1 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_29 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr3 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_07 _1 _2 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_02 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LPAREN (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
          _menhir_run_16_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_02 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState02 _tok
  
  and _menhir_run_03 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LIST (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
          _menhir_run_16_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState03
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_03 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LIST -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState03 _tok
  
  and _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
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
                  let _v = _menhir_action_18 _1 in
                  _menhir_run_16_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
                  _menhir_run_16_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_16_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState06
              | _ ->
                  _eRR ())
          | EQUALS ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | NOTE _v_5 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_5 in
                  let _v = _menhir_action_18 _1 in
                  _menhir_run_16_spec_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | LAMBDA ->
                  _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | IDENT _v_7 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_7 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_16_spec_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_16_spec_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState38
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_06 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState06 _tok
  
  and _menhir_run_07 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
          _menhir_run_16_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState07
      | RBRACKET ->
          let _v = _menhir_action_20 () in
          _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_07 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState07 _tok
  
  and _menhir_run_08 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
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
                  let _v = _menhir_action_18 _1 in
                  _menhir_run_16_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | LAMBDA ->
                  _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_16_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_16_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState10
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_10 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState10 _tok
  
  and _menhir_run_13 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
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
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_0 in
                  let _v = _menhir_action_18 _1 in
                  _menhir_run_16_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | LPAREN ->
                  _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | LIST ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | LET ->
                  _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | LBRACKET ->
                  _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | LAMBDA ->
                  _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | IDENT _v_2 ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _1 = _v_2 in
                  let _v = _menhir_action_10 _1 in
                  _menhir_run_16_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | FAIL ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  let _v = _menhir_action_17 () in
                  _menhir_run_16_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
              | CONST ->
                  _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState15
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_16_spec_15 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState15 _tok
  
  and _menhir_run_32 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LBRACKET -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let MenhirCell1_LBRACKET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_15 _2 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_expr_leaf : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState17 ->
          _menhir_run_29 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState00 ->
          _menhir_run_16_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState02 ->
          _menhir_run_16_spec_02 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState03 ->
          _menhir_run_16_spec_03 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState40 ->
          _menhir_run_16_spec_40 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState38 ->
          _menhir_run_16_spec_38 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState06 ->
          _menhir_run_16_spec_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState35 ->
          _menhir_run_16_spec_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState07 ->
          _menhir_run_16_spec_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState10 ->
          _menhir_run_16_spec_10 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState26 ->
          _menhir_run_16_spec_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState23 ->
          _menhir_run_16_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState20 ->
          _menhir_run_16_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState18 ->
          _menhir_run_16_spec_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState15 ->
          _menhir_run_16_spec_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
  
  and _menhir_run_16_spec_40 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState40 _tok
  
  and _menhir_run_16_spec_38 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState38 _tok
  
  and _menhir_run_16_spec_35 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState35 _tok
  
  and _menhir_run_16_spec_26 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState26 _tok
  
  and _menhir_run_16_spec_23 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr1 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState23 _tok
  
  and _menhir_run_16_spec_20 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr2 -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState20 _tok
  
  and _menhir_run_16_spec_18 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let _1 = _v in
      let _v = _menhir_action_08 _1 in
      _menhir_run_17 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState18 _tok
  
  and _menhir_goto_expr2 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState03 ->
          _menhir_run_42 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState02 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState40 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState38 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState35 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState10 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState15 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState17 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState26 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState23 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState20 ->
          _menhir_run_21 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState18 ->
          _menhir_run_19 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_42 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LIST as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_LIST (_menhir_stack, _menhir_s) = _menhir_stack in
          let _2 = _v in
          let _v = _menhir_action_16 _2 in
          _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_20 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr2 -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | LPAREN ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LIST ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LET ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | LBRACKET ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_16_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState20
      | _ ->
          _eRR ()
  
  and _menhir_goto_expr1 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState03 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState17 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState18 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState00 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState02 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState40 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState38 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState35 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState10 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState15 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState26 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState23 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState20 ->
          _menhir_run_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_28 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          _menhir_run_23 _menhir_stack _menhir_lexbuf _menhir_lexer
      | _ ->
          _eRR ()
  
  and _menhir_run_23 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr1 -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
      | IDENT _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_10 _1 in
          _menhir_run_16_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState23
      | _ ->
          _eRR ()
  
  and _menhir_run_24 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_23 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_02 _1 in
          _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_goto_expr : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState00 ->
          _menhir_run_46 _menhir_stack _v _tok
      | MenhirState02 ->
          _menhir_run_43 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState40 ->
          _menhir_run_41 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState38 ->
          _menhir_run_39 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState06 ->
          _menhir_run_37 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState35 ->
          _menhir_run_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState07 ->
          _menhir_run_34 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState10 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState15 ->
          _menhir_run_30 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState26 ->
          _menhir_run_27 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState23 ->
          _menhir_run_25 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_43 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LPAREN -> _ -> _ -> _ -> _ -> _menhir_box_main =
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
  
  and _menhir_run_41 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _4) = _menhir_stack in
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _6 = _v in
      let _v = _menhir_action_12 _2 _4 _6 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_39 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_18 _1 in
              _menhir_run_16_spec_40 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_16_spec_40 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_16_spec_40 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState40
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_37 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LET _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LET (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_11 _2 _4 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_34 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | COMMA ->
          let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_18 _1 in
              _menhir_run_16_spec_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_16_spec_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_16_spec_35 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState35
          | RBRACKET ->
              let _v = _menhir_action_20 () in
              _menhir_run_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v
          | _ ->
              _eRR ())
      | RBRACKET ->
          let _1 = _v in
          let _v = _menhir_action_21 _1 in
          _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_36 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_expr (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _3 = _v in
      let _v = _menhir_action_22 _1 _3 in
      _menhir_goto_sep_by_trailing_COMMA_expr_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_sep_by_trailing_COMMA_expr_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState35 ->
          _menhir_run_36 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | MenhirState07 ->
          _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_31 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_LAMBDA _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_LAMBDA (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_01 _2 _4 in
      _menhir_goto_expr _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_30 : type  ttv_stack. (ttv_stack, _menhir_box_main) _menhir_cell1_CONST _menhir_cell0_IDENT -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell0_IDENT (_menhir_stack, _2) = _menhir_stack in
      let MenhirCell1_CONST (_menhir_stack, _menhir_s) = _menhir_stack in
      let _4 = _v in
      let _v = _menhir_action_13 _2 _4 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_27 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1, _menhir_box_main) _menhir_cell1_expr -> _ -> _ -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_expr (_menhir_stack, _, _3) = _menhir_stack in
      let MenhirCell1_expr1 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let _5 = _v in
      let _v = _menhir_action_14 _1 _3 _5 in
      _menhir_goto_expr_leaf _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_25 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr1 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_expr (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | IN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | NOTE _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_0 in
              let _v = _menhir_action_18 _1 in
              _menhir_run_16_spec_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | LPAREN ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | LIST ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | LET ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | LBRACKET ->
              _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | LAMBDA ->
              _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | IDENT _v_2 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _1 = _v_2 in
              let _v = _menhir_action_10 _1 in
              _menhir_run_16_spec_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | FAIL ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let _v = _menhir_action_17 () in
              _menhir_run_16_spec_26 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
          | CONST ->
              _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState26
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_22 : type  ttv_stack. ((ttv_stack, _menhir_box_main) _menhir_cell1_expr2 as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | EQUALS ->
          let _menhir_stack = MenhirCell1_expr1 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_23 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | PIPE | RBRACKET | RPAREN ->
          let MenhirCell1_expr2 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_03 _1 _3 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_21 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | COLON | COMMA | CONST | EOF | EQUALS | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_19 : type  ttv_stack. (((ttv_stack, _menhir_box_main) _menhir_cell1_expr3, _menhir_box_main) _menhir_cell1_COLON as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_main) _menhir_state -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | PIPE ->
          let _menhir_stack = MenhirCell1_expr2 (_menhir_stack, _menhir_s, _v) in
          _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUALS ->
          let _1 = _v in
          let _v = _menhir_action_04 _1 in
          _menhir_goto_expr1 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | COLON | COMMA | CONST | EOF | FAIL | IDENT _ | IN | LBRACKET | LET | LIST | LPAREN | NOTE _ | RBRACKET | RPAREN ->
          let MenhirCell1_COLON (_menhir_stack, _) = _menhir_stack in
          let MenhirCell1_expr3 (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_05 _1 _3 in
          _menhir_goto_expr2 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  let rec _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_main =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | NOTE _v ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _1 = _v in
          let _v = _menhir_action_18 _1 in
          _menhir_run_16_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
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
          _menhir_run_16_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | FAIL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let _v = _menhir_action_17 () in
          _menhir_run_16_spec_00 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | CONST ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | _ ->
          _eRR ()
  
end

let main =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_main v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
