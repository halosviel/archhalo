#!/bin/bash

# prevent multiple instances
if pgrep -x slurp > /dev/null; then
  exit 0
fi

SOUND="/home/halosviel/Local/Rice/Sounds/pop-up-blocked.mp3"
OUTPUT="/home/halosviel/Captures/$(date '+%Y-%m-%d_%H-%M-%S').png"

success_icon() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

REGION=$(slurp) && grim -g "$REGION" "$OUTPUT" && {
  paplay --volume=32768 "$SOUND"
  SIZE=$(identify -format "%wx%h" "$OUTPUT" 2>/dev/null)
  FILESIZE=$(stat -c%s "$OUTPUT")
  EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
  if [ "$FILESIZE" -lt 1048576 ]; then
    FILESIZE=$(awk "BEGIN {printf \"%.1fKB\", $FILESIZE/1024}")
  else
    FILESIZE=$(awk "BEGIN {printf \"%.1fMB\", $FILESIZE/1048576}")
  fi
  notify-send "Screenshot saved$EXCLAMATIONS" "󰲎• $SIZE\n• $FILESIZE" -i "$(success_icon)" -t 4000
}
