#!/bin/bash

# qbit_seanime.sh
# Binds qBittorrent's lifetime to Seanime: qbit runs ONLY while Seanime is open.
# Starts qbittorrent-nox (headless) when Seanime appears, and gracefully stops
# it (SIGTERM -> clean session save) once Seanime has been gone a few seconds.
# So qbit never lingers in the background and never auto-starts at login.
# (Pair with `systemctl --user disable qbittorrent-nox` so nothing else starts it.)

# [CONFIG]
CHECK_INTERVAL=3
QBIT_BIN="/usr/bin/qbittorrent-nox"
GONE_GRACE=2            # Seanime must be absent this many checks before stopping qbit
# Match the real Seanime binaries only -- NOT this script's own name (which
# contains "seanime"), so we never see ourselves as a running Seanime.
SEANIME_RE="seanime-denshi|seanime-server"

# -->

seanime_running() { pgrep -f "$SEANIME_RE" >/dev/null; }
qbit_pid()        { pgrep -x qbittorrent-nox; }

# -->

gone=0

while true; do
  if seanime_running; then
    gone=0
    if [ -z "$(qbit_pid)" ]; then
      setsid "$QBIT_BIN" >/dev/null 2>&1 &
    fi
  else
    gone=$((gone + 1))
    pid=$(qbit_pid)
    if [ "$gone" -ge "$GONE_GRACE" ] && [ -n "$pid" ]; then
      kill -TERM $pid          # graceful: qbit saves its session and exits
    fi
  fi
  sleep "$CHECK_INTERVAL"
done
