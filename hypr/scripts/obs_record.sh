#!/bin/bash

# [CONFIG]
NTF_DONE_LIFETIME=3000
NTF_DONE_SOUND="/home/halosviel/Local/Rice/Sounds/pop-up-blocked.mp3"

NTF_FAIL_LIFETIME=6000
NTF_FAIL_SOUND="/home/halosviel/Local/Rice/Sounds/error.mp3"

SAVE_TIMEOUT=5000
SAVE_YIELD_INTERVAL=0.1

# -->

iconHappy() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

iconSad() {
  ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1
}

obsStatus=$(obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording status 2>/dev/null)
if echo "$obsStatus" | grep -qi "Active: true"; then
	# save recording
  obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording stop
  sleep 1  # wait for file to be written

  recording=$(ls -t /home/halosviel/Captures/*.mp4 2>/dev/null | head -1)
	exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))

	last_size=0
	start_time=$(date +%s%3N)

	# timeout loop
	while true; do
    size=$(stat -c%s "$recording" 2>/dev/null || echo 0)

    if [ "$size" -gt 0 ] && [ "$size" -eq "$last_size" ]; then
      break
    fi

    now=$(date +%s%3N)
		if (( now - start_time >= SAVE_TIMEOUT )); then
			paplay --volume=32768 $NTF_FAIL_SOUND &
			notify-send "Recording failed to save$exclamations" "Execution timed out" -i "$(iconSad)" -t $NTF_FAIL_LIFETIME
			exit 1
    fi

    last_size=$size
    sleep $SAVE_YIELD_INTERVAL
	done

	paplay --volume=32768 $NTF_DONE_SOUND &
  
	# calculate file duration
	fileDuration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$recording" 2>/dev/null)
	fileDuration=$(awk '{
    m = int($1 / 60)
    s = int($1 % 60)
    printf "%dm %ds", m, s
	}' <<< "$fileDuration")

	# calculate file size
	bytes=$(stat -c%s "$recording")
	if (( bytes < 1024 )); then
    fileSize="${bytes} B"
	elif (( bytes < 1048576 )); then
    fileSize=$(awk "BEGIN {printf \"%.1f KB\", $bytes/1024}")
	elif (( bytes < 1073741824 )); then
    fileSize=$(awk "BEGIN {printf \"%.1f MB\", $bytes/1048576}")
	else
    fileSize=$(awk "BEGIN {printf \"%.1f GB\", $bytes/1073741824}")
	fi

  notify-send "Recording saved$exclamations" "󰔛 $fileDuration\n $fileSize" -i "$(iconHappy)" -t $NTF_DONE_LIFETIME
else
	# start recording
  obs-cmd --websocket obsws://localhost:4455/slg20Z55ZmFTHX8G recording start
fi
