
# parsetab.py
# This file is automatically generated. Do not edit.
# pylint: disable=W,C,R
_tabversion = '3.10'

_lr_method = 'LALR'

_lr_signature = 'COLON DIVIDE FLOAT INT MINUS MULTIPLY PLUS POWER VAR\n    calc : expression\n         | empty\n    \n    expression : INT\n               | FLOAT\n    \n    empty : \n    '
    
_lr_action_items = {'INT':([0,],[4,]),'FLOAT':([0,],[5,]),'$end':([0,1,2,3,4,5,],[-5,0,-1,-2,-3,-4,]),}

_lr_action = {}
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
      if not _x in _lr_action:  _lr_action[_x] = {}
      _lr_action[_x][_k] = _y
del _lr_action_items

_lr_goto_items = {'calc':([0,],[1,]),'expression':([0,],[2,]),'empty':([0,],[3,]),}

_lr_goto = {}
for _k, _v in _lr_goto_items.items():
   for _x, _y in zip(_v[0], _v[1]):
       if not _x in _lr_goto: _lr_goto[_x] = {}
       _lr_goto[_x][_k] = _y
del _lr_goto_items
_lr_productions = [
  ("S' -> calc","S'",1,None,None,None),
  ('calc -> expression','calc',1,'p_calc','tap.py',53),
  ('calc -> empty','calc',1,'p_calc','tap.py',54),
  ('expression -> INT','expression',1,'p_expression','tap.py',59),
  ('expression -> FLOAT','expression',1,'p_expression','tap.py',60),
  ('empty -> <empty>','empty',0,'p_empty','tap.py',66),
]