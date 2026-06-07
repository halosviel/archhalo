#!/bin/bash
obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G trigger-hotkey ReplayBuffer.Save
ICON=$(ls /home/halosviel/Local/Rice/Icons/Success/*.png | shuf -n 1)
notify-send "OBS" "Clip saved! (last 2 minutes)" -t 3000 -i "$ICON"
