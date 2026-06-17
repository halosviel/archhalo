#!/bin/bash

# [CONFIG]
PING_HOST="1.1.1.1"
DISCONNECTED_SOUND="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"
CONNECTED_SOUND="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"
NTF_LIFETIME=5000

# -->

happy_icon() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

sad_icon() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

check_internet() {
  ping -c 1 -W 2 "$PING_HOST" &> /dev/null
}

# -->

if check_internet; then
  was_online=true
else
  was_online=false
fi

# react to every networkmanager event, then verify with a real ping
nmcli monitor | while read -r _; do
  if check_internet; then
    if [ "$was_online" = false ]; then
      EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Internet restored$EXCLAMATIONS" "Connection is back!" -t $NTF_LIFETIME -i "$(happy_icon)"
      paplay --volume=32768 "$CONNECTED_SOUND" &
      was_online=true
    fi
  else
    if [ "$was_online" = true ]; then
      EXCLAMATIONS=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
      notify-send "Internet lost$EXCLAMATIONS" "The connection seems to have dropped..." -t $NTF_LIFETIME -i "$(sad_icon)"
      paplay --volume=32768 "$DISCONNECTED_SOUND" &
      was_online=false
    fi
  fi
done
