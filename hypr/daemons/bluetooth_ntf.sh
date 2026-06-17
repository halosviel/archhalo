#!/bin/bash

# [CONFIG]
SOUND="/home/halosviel/Local/Rice/Sounds/notify.mp3"
SOUND_DELAY = 1

# -->

happy_icon() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

sad_icon() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

device_name() {
  local mac="$1"
  bluetoothctl info "$mac" | grep "Name:" | cut -d ' ' -f2-
}

# -->

stdbuf -oL bluetoothctl | while read -r line; do
  case "$line" in
    *"Connected: yes"*)
      MAC=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
      NAME=$(device_name "$MAC")
      EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Bluetooth connected$EXCLAMATIONS" "${NAME:-$MAC}" -t 7000 -i "$(happy_icon)"
			sleep $SOUND_DELAY
      paplay --volume=32768 "$SOUND" &
      ;;
    *"Connected: no"*)
      MAC=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
      NAME=$(device_name "$MAC")
      EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Bluetooth disconnected$EXCLAMATIONS" "${NAME:-$MAC}" -t 7000 -i "$(sad_icon)"
			sleep $SOUND_DELAY
      paplay --volume=32768 "$SOUND" &
      ;;
  esac
done
