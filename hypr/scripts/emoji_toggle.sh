#!/bin/bash

pid=$(hyprctl clients -j | jq -r '.[] | select(.class == "it.mijorus.smile") | .pid')

if [ -n "$pid" ]; then
  kill "$pid"
else
  smile &
fi
