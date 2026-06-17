#!/bin/bash

# [CONFIG]
CHECK_INTERVAL=2
TEMP_PATH="/sys/class/hwmon/hwmon1/temp1_input"
SOUND="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"
NTF_LIFETIME=5000

THRESHOLDS=(70 80 90)

# -->

iconSad() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

# -->

declare -A notified

while true; do
  rawTemperature=$(cat "$TEMP_PATH")
  newTemperature=$((rawTemperature / 1000))

	exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))

  for threshold in "${THRESHOLDS[@]}"; do
    if [ "$newTemperature" -ge "$threshold" ] && [ "${notified[$threshold]}" != "true" ]; then
      notify-send "High CPU temperature$exclamations" "CPU is at ${newTemperature}°C" -t $NTF_LIFETIME -i "$(iconSad)"
      paplay --volume=32768 "$SOUND" &

      notified[$threshold]="true"
    elif [ "$newTemperature" -lt "$threshold" ]; then
      notified[$threshold]="false"
    fi
  done

  sleep $CHECK_INTERVAL
done
