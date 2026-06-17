#!/bin/bash

# [CONFIG]
CHECK_INTERVAL=2
NTF_LIFETIME=5000

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
