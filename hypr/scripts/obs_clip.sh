#!/bin/bash

# [CONFIG]
WEB_SOCKET="obsws://localhost:4455/slg20Z55ZmFTHX8G"

NTF_DONE_LIFETIME=3000
NTF_DONE_SOUND="/home/halosviel/Local/Rice/Sounds/ding.mp3"

NTF_FAIL_LIFETIME=6000
NTF_FAIL_SOUND="/home/halosviel/Local/Rice/Sounds/error.mp3"

YIELD_INTERVAL=100
YIELD_TIMEOUT=15000

# -->

iconHappy() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

iconSad() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

getClip() {
  obs-cmd --websocket "$WEB_SOCKET" replay last-replay 2>/dev/null | grep "Last replay path:" | sed 's/Last replay path: //'
}

# -->

obs-cmd --websocket "$WEB_SOCKET" replay save
exclamations="!"

previousClip=$(getClip)
elapsed=0

# wait until last replay path changes to a new file
clip="$previousClip"
while [ "$clip" = "$previousClip" ] && [ "$elapsed" -lt "$YIELD_TIMEOUT" ]; do
	sleep "$(awk "BEGIN {print $YIELD_INTERVAL/1000}")"
  elapsed=$((elapsed + YIELD_INTERVAL))
  clip=$(getClip)
  exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
done

# timed out or no new clip
if [ "$clip" = "$previousClip" ] || [ -z "$clip" ]; then
  paplay --volume=32768 $NTF_FAIL_SOUND &
  notify-send "Clip failed to save$exclamations" "Execution timed out" -i "$(iconSad)" -t $NTF_FAIL_LIFETIME
	exit 1
fi

# wait until file is done being written
elapsed=0
while { [ ! -f "$clip" ] || lsof "$clip" >/dev/null 2>&1; } && [ "$elapsed" -lt "$YIELD_TIMEOUT" ]; do
	sleep "$(awk "BEGIN {print $YIELD_INTERVAL/1000}")"
  elapsed=$((elapsed + YIELD_INTERVAL))
done

# file not found
if [ ! -f "$clip" ]; then
  paplay --volume=32768 $NTF_FAIL_SOUND &
  notify-send "Clip failed to save$exclamations" "File not found" -t $NTF_FAIL_LIFETIME -i "$(iconSad)"
  exit 1
fi

# rename file
newName="$(dirname "$clip")/clip_$(date +%-I%P_m%M_s%S).mp4"
mv "$clip" "$newName"
clip="$newName"

# get notification params
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$clip" 2>/dev/null | awk '{m=int($1/60); s=int($1%60); printf "%dm %ds", m, s}')
fileSize=$(stat -c%s "$clip")
if [ "$fileSize" -lt 1048576 ]; then
  fileSize=$(awk "BEGIN {printf \"%.1fKB\", $fileSize/1024}")
else
  fileSize=$(awk "BEGIN {printf \"%.1fMB\", $fileSize/1048576}")
fi

# play sound
paplay --volume=32768 $NTF_DONE_SOUND &

# second notification
notify-send "Clip saved$exclamations" "󰔛 $duration\n $fileSize" -i "$(iconHappy)" -t $NTF_DONE_LIFETIME
