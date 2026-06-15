#!/bin/bash

# toggles obs' record/stop recording functions
# -> obs must be open!!

STATUS=$(obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording status 2>/dev/null)

success_icon() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

if echo "$STATUS" | grep -qi "Active: true"; then
    obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording stop
    sleep 1  # wait for file to be written
    RECORDING=$(ls -t /home/halosviel/Captures/*.mp4 2>/dev/null | head -1)
    EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))

    DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$RECORDING" 2>/dev/null | awk '{m=int($1/60); s=int($1%60); printf "%dm %ds", m, s}')
    FILESIZE=$(stat -c%s "$RECORDING")
    if [ "$FILESIZE" -lt 1048576 ]; then
      FILESIZE=$(awk "BEGIN {printf \"%.1fKB\", $FILESIZE/1024}")
    else
      FILESIZE=$(awk "BEGIN {printf \"%.1fMB\", $FILESIZE/1048576}")
    fi

    paplay --volume=32768 /home/halosviel/Local/Rice/Sounds/ding.mp3 &
    notify-send "Recording saved$EXCLAMATIONS" "󰔛 $DURATION\n $FILESIZE" -t 4000 -i "$(success_icon)"
else
    obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording start
fi
