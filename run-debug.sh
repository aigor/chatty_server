#!/bin/bash

file="/dev/stdin"
child_processes_amount=200

dune build
export OCAMLRUNPARAM=b; dune exec -- ./_build/default/chatty_server.bc $child_processes_amount < "$file"
echo "Application terminated with the following status code: $?"
