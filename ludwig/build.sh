#!/usr/bin/env bash
set -e

ocamllex src/lexer.mll

# We cannot use --infer unfortunately, since menhir cannot import ReScript modules
# and parser.mly depends on syntax.res
menhir src/parser.mly

npx rescript build

npx webpack
