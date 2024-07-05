#!/bin/bash

# TODO: Reove this script

PIPE=/tmp/chatty_server_input_stream
dune build
_build/default/chatty_server.exe 2 < $PIPE
