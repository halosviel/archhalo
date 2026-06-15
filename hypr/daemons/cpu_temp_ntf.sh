#!/bin/bash

CHECK_INTERVAL=2
TEMP_PATH="/sys/class/hwmon/hwmon1/temp1_input"
SOUND="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"

THRESHOLDS=(70 80 90)

alert_icon() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

declare -A notified

while true; do
  RAW=$(cat "$TEMP_PATH")
  TEMP=$((RAW / 1000))

  for THRESHOLD in "${THRESHOLDS[@]}"; do
    EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
    if [ "$TEMP" -ge "$THRESHOLD" ] && [ "${notified[$THRESHOLD]}" != "true" ]; then
      notify-send "High CPU temperature$EXCLAMATIONS" "CPU is at ${TEMP}°C" -t 7000 -i "$(alert_icon)"
      paplay --volume=32768 "$SOUND" &
      notified[$THRESHOLD]="true"
    elif [ "$TEMP" -lt "$THRESHOLD" ]; then
      notified[$THRESHOLD]="false"
    fi
  done

  sleep $CHECK_INTERVAL
done
