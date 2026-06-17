#!/bin/bash

# [CONFIG]
NTF_LIFETIME=3000
NTF_DONE_SOUND="/home/halosviel/Local/Rice/Sounds/pop-up-blocked.mp3"
SAVE_LOCATION="/home/halosviel/Captures/$(date '+screenshot_%-I%P_m%M-s%S').png"

# -->

# prevent multiple instances
if pgrep -x slurp > /dev/null; then
  exit 0
fi

iconHappy() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

# -->

exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))

REGION=$(slurp) && grim -g "$REGION" "$SAVE_LOCATION" && wl-copy < "$SAVE_LOCATION" && {
	# play sound immediately for feedback
  paplay --volume=32768 "$NTF_DONE_SOUND"

	fileDimensions=$(identify -format "%wx%h" "$SAVE_LOCATION" 2>/dev/null)
	fileSize=$(stat -c%s "$SAVE_LOCATION")

  if [ "$fileSize" -lt 1048576 ]; then
    fileSize=$(awk "BEGIN {printf \"%.1fKB\", $fileSize/1024}")
  else
    fileSize=$(awk "BEGIN {printf \"%.1fMB\", $fileSize/1048576}")
  fi

  notify-send "Screenshot saved$exclamations" "󰲎 $fileDimensions\n $fileSize" -i "$(iconHappy)" -t $NTF_LIFETIME
}
