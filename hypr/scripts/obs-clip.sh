#!/bin/bash

WS="obsws://localhost:4455/slg20Z55ZmFTHX8G"
TIMEOUT=30000  # ms!!
ELAPSED=0
SLEEP_MS=200

get_clip() {
  obs-cmd --websocket "$WS" replay last-replay 2>/dev/null | grep "Last replay path:" | sed 's/Last replay path: //'
}

success_icon() {
  ls /home/halosviel/Local/Rice/Icons/Success/*.png | shuf -n 1
}

fail_icon() {
  ls /home/halosviel/Local/Rice/Icons/Fail/*.png | shuf -n 1
}

PREV=$(get_clip)
obs-cmd --websocket "$WS" trigger-hotkey ReplayBuffer.Save

# wait until last-replay path changes to a new file
CLIP="$PREV"
while [ "$CLIP" = "$PREV" ] && [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  sleep 0.2
  ELAPSED=$((ELAPSED + SLEEP_MS))
  CLIP=$(get_clip)
done

# timed out or no new clip
if [ "$CLIP" = "$PREV" ] || [ -z "$CLIP" ]; then
  paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/error.mp3 &
  notify-send "OBS" "Clip did not save: failed or timed out!!" -t 3000 -i "$(fail_icon)"
  exit 1
fi

# wait until file is done being written
ELAPSED=0
while { [ ! -f "$CLIP" ] || [ "$(lsof "$CLIP" 2>/dev/null)" ]; } && [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  sleep 0.2
  ELAPSED=$((ELAPSED + SLEEP_MS))
done

if [ ! -f "$CLIP" ]; then
  paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/error.mp3 &
  notify-send "OBS" "Clip did not save: file not found!!" -t 3000 -i "$(fail_icon)"
  exit 1
fi

DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$CLIP" 2>/dev/null | awk '{printf "%d:%02d", $1/60, $1%60}')

paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/ding.mp3 &
notify-send "OBS" "Clip saved!! ($DURATION)" -t 3000 -i "$(success_icon)"
