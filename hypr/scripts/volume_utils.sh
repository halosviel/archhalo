#!/bin/bash

# [CONFIG]
MAX_VOLUME=100
STEP=5

# -->

case "$1" in
    up)
        currentVolume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
        newVolume=$(( currentVolume + STEP ))

        if [ "$newVolume" -gt "$MAX_VOLUME" ]; then
            newVolume=$MAX_VOLUME
        fi

        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${newVolume}%"
        ;;

    down)
        currentVolume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
        newVolume=$(( currentVolume - STEP ))

        if [ "$newVolume" -lt 0 ]; then
            newVolume=0
        fi

        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${newVolume}%"
        ;;

    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac
