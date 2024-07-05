#!/bin/bash


PIPE=/tmp/chatty_server_input_stream
dune build
_build/default/chatty_server.exe 27 < $PIPE
