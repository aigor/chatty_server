#!/bin/bash

while true
do
  # on MacOS the following may be used: random_int=$(jot -r 1 1 32)
  random_int=$(awk -v min=1 -v max=32 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
  generated_data="$(date '+%Y-%m-%d %H:%M:%S') $(openssl rand -base64 $random_int)"
  echo $generated_data
  sleep 0.100
done