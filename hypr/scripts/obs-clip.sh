#!/bin/bash

# get previous clip path before saving
PREV=$(obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G replay last-replay | grep "Last replay path:" | sed 's/Last replay path: //')

obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G trigger-hotkey ReplayBuffer.Save

# wait until last-replay path changes to a new file
CLIP="$PREV"
while [ "$CLIP" = "$PREV" ]; do
  sleep 0.2
  CLIP=$(obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G replay last-replay | grep "Last replay path:" | sed 's/Last replay path: //')
done

# wait until file is done being written
while [ ! -f "$CLIP" ] || [ "$(lsof "$CLIP" 2>/dev/null)" ]; do
  sleep 0.2
done

DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$CLIP" 2>/dev/null | awk '{printf "%d:%02d", $1/60, $1%60}')

ICON=$(ls /home/halosviel/Local/Rice/Icons/Success/*.png | shuf -n 1)
notify-send "OBS" "Clip saved! ($DURATION)" -t 3000 -i "$ICON"
