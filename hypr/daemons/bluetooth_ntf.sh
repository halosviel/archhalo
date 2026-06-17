#!/bin/bash

# [CONFIG]
SOUND="/home/halosviel/Local/Rice/Sounds/notify.mp3"
SOUND_DELAY=1

NTF_LIFETIME=4000

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
			# get device info
      deviceMacAddress=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
      deviceName=$(device_name "$deviceMacAddress")

			# send notification
      exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Bluetooth connected$exclamations" "${deviceName:-$deviceMacAddress}" -t $NTF_LIFETIME -i "$(happy_icon)"

			# play sound (delayed)
			sleep $SOUND_DELAY
      paplay --volume=32768 "$SOUND" &
      ;;
    *"Connected: no"*)
			# get device info
      deviceMacAddress=$(echo "$line" | grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}')
      deviceName=$(device_name "$deviceMacAddress")

			# send notification
      exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Bluetooth disconnected$exclamations" "${deviceName:-$deviceMacAddress}" -t $NTF_LIFETIME -i "$(sad_icon)"

			# play sound (delayed)
			sleep $SOUND_DELAY
      paplay --volume=32768 "$SOUND" &
      ;;
  esac
done
