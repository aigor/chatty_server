#!/bin/bash

PIPE=/tmp/chatty_server_input_stream

#SENDER
INDEX=1
while true ; do 
  MESSAGE="Message $INDEX"
  echo "Sending '$MESSAGE' to '$PIPE'"
  echo $MESSAGE > $PIPE
  INDEX=$((INDEX+1)) 
  sleep 1
done

echo "Sending finished"