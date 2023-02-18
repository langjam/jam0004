{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    flex  #2.6.4
    bison #3.8.2
  ];}
