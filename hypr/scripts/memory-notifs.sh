#!/bin/bash

CHECK_INTERVAL=2

# add or remove thresholds here!!
declare -A TITLES
declare -A MESSAGES
declare -A SOUNDS

TITLES[80]="High memory usage detected"
MESSAGES[80]="RAM usage has just reached %d%%!!"
SOUNDS[80]="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"

TITLES[90]="Running out of memory"
MESSAGES[90]="RAM usage has surpassed %d%%"
SOUNDS[90]="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"

TITLES[95]="Out of Memory"
MESSAGES[95]="CRITICAL: RAM usage has just reached %d%% (start panicking!!)"
SOUNDS[95]="/home/halosviel/Local/Rice/Sounds/error.mp3"

alert_icon() {
  ls /home/halosviel/Local/Rice/Icons/Fail/*.png | shuf -n 1
}

declare -A notified

while true; do
  TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  USED=$(( (TOTAL - AVAILABLE) * 100 / TOTAL ))

  for THRESHOLD in "${!TITLES[@]}"; do
    MSG=$(printf "${MESSAGES[$THRESHOLD]}" "$USED")
    if [ "$USED" -ge "$THRESHOLD" ] && [ "${notified[$THRESHOLD]}" != "true" ]; then
    notify-send \
        -u critical \
        "${TITLES[$THRESHOLD]}" \
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
