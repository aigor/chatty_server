#!/bin/bash


file="/dev/stdin"

dune build
_build/default/chatty_server.exe 2 < "$file"
