#!/bin/bash

WS="obsws://localhost:4455/slg20Z55ZmFTHX8G"
TIMEOUT=3000  # ms!!
ELAPSED=0
SLEEP_MS=200

get_clip() {
  obs-cmd --websocket "$WS" replay last-replay 2>/dev/null | grep "Last replay path:" | sed 's/Last replay path: //'
}

success_icon() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

fail_icon() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

PREV=$(get_clip)
obs-cmd --websocket "$WS" trigger-hotkey ReplayBuffer.Save
EXCLAMATIONS="!"

# wait until last-replay path changes to a new file
CLIP="$PREV"
while [ "$CLIP" = "$PREV" ] && [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  sleep 0.2
  ELAPSED=$((ELAPSED + SLEEP_MS))
  CLIP=$(get_clip)
  EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
done

# timed out or no new clip
if [ "$CLIP" = "$PREV" ] || [ -z "$CLIP" ]; then
  paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/error.mp3 &
  notify-send "Clip failed to save$EXCLAMATIONS" "Execution timed out" -t 4000 -i "$(fail_icon)"
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
  notify-send "Clip failed to save$EXCLAMATIONS" "File not found" -t 4000 -i "$(fail_icon)"
  exit 1
fi
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$CLIP" 2>/dev/null | awk '{m=int($1/60); s=int($1%60); printf "%dm %ds", m, s}')
RESOLUTION=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$CLIP" 2>/dev/null | tr ',' 'x')
FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$CLIP" 2>/dev/null | awk -F'/' '{printf "%.0f", $1/$2}')
FILESIZE=$(stat -c%s "$CLIP")
if [ "$FILESIZE" -lt 1048576 ]; then
  FILESIZE=$(awk "BEGIN {printf \"%.1fKB\", $FILESIZE/1024}")
else
  FILESIZE=$(awk "BEGIN {printf \"%.1fMB\", $FILESIZE/1048576}")
fi

paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/ding.mp3 &
notify-send "Clip saved$EXCLAMATIONS" "󰔛 $DURATION\n $FILESIZE" -t 4000 -i "$(success_icon)"
