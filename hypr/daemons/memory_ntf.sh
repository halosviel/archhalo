#!/bin/bash

# [CONFIG]
CHECK_INTERVAL=2
NTF_LIFETIME=5000

# add or remove thresholds here!!
declare -A TITLES
declare -A MESSAGES
declare -A SOUNDS

TITLES[95]="High memory usage"
MESSAGES[95]="%d%% of ram being used. Close some apps!"
SOUNDS[95]="/home/halosviel/Local/Rice/Sounds/exclamation.mp3"

TITLES[99]="High memory usage"
MESSAGES[99]="%d%% of ram being used.\nits lowk over bro 🥀"
SOUNDS[99]="/home/halosviel/Local/Rice/Sounds/error.mp3"

# -->

iconSad() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

# -->

declare -A notified

while true; do
  totalMemory=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  availableMemory=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  usedMemory=$(( (totalMemory - availableMemory) * 100 / totalMemory )) 

  for threshold in "${!TITLES[@]}"; do
    exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
    MSG=$(printf "${MESSAGES[$threshold]}" "$usedMemory")

    if [ "$usedMemory" -ge "$threshold" ] && [ "${notified[$threshold]}" != "true" ]; then
    	notify-send \
        "${TITLES[$threshold]}$exclamations" \
        "$MSG" \
        -t $NTF_LIFETIME \
        -i "$(iconSad)"

    	paplay --volume=32768 "${SOUNDS[$threshold]}" &

    	notified[$threshold]="true"
    elif [ "$usedMemory" -lt "$threshold" ]; then
      notified[$threshold]="false"
    fi 
  done

  sleep $CHECK_INTERVAL
done
