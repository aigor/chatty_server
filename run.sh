#!/bin/bash

file="/dev/stdin"
child_processes_amount=200

dune build
_build/default/chatty_server.exe $child_processes_amount < "$file"
echo "Application terminated with the following status code: $?"
