#!/bin/bash

THRESHOLD=90
CHECK_INTERVAL=2

notified=false

while true; do
  TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  USED=$(( (TOTAL - AVAILABLE) * 100 / TOTAL ))

  if [ "$USED" -ge "$THRESHOLD" ] && [ "$notified" = false ]; then
    notify-send -u critical "⚠️ CRITICAL :: RUNNING OUT OF MEMORY" "RAM usage is at ${USED}%!!" -t 5000
    notified=true
  elif [ "$USED" -lt "$THRESHOLD" ]; then
    notified=false
  fi

  sleep $CHECK_INTERVAL
done
