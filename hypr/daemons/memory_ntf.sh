#!/bin/bash

CHECK_INTERVAL=2

# add or remove thresholds here!!
declare -A TITLES
declare -A MESSAGES
declare -A SOUNDS

TITLES[90]="High memory usage"
MESSAGES[90]="%d%% of ram being used"
SOUNDS[90]="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"

TITLES[98]="High memory usage"
MESSAGES[98]="%d%% of ram being used\nSystem may shut down soon!"
SOUNDS[98]="/home/halosviel/Local/Rice/Sounds/error.mp3"

alert_icon() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

declare -A notified

while true; do
  TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  USED=$(( (TOTAL - AVAILABLE) * 100 / TOTAL )) 

  for THRESHOLD in "${!TITLES[@]}"; do
    EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
    MSG=$(printf "${MESSAGES[$THRESHOLD]}" "$USED")

    if [ "$USED" -ge "$THRESHOLD" ] && [ "${notified[$THRESHOLD]}" != "true" ]; then
    	notify-send \
        "${TITLES[$THRESHOLD]}$EXCLAMATIONS" \
        "$MSG" \
        -t 7000 \
        -i "$(alert_icon)"

    	paplay --volume=32768 "${SOUNDS[$THRESHOLD]}" &

    	notified[$THRESHOLD]="true"
    elif [ "$USED" -lt "$THRESHOLD" ]; then
      notified[$THRESHOLD]="false"
    fi 
  done

  sleep $CHECK_INTERVAL
done
