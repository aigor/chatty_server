#!/bin/bash

WAIT_PERIOD=30
PIPE=/tmp/chatty_server_input_stream

if [[ -p $pipe ]]
then
  mkfifo $PIPE
else
  echo "FIFO '$PIPE' already exist, reusing it"
fi

echo "Listening for the stream '$PIPE' for the $WAIT_PERIOD seconds"

while true
do
    if read line; then
        echo "Received: $line"
    fi
done < "$PIPE"

rm -f $PIPE