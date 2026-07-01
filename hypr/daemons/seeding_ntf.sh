#!/bin/bash

# seeding_ntf.sh
# Notifies (via mako) when someone STARTS or STOPS downloading from you --
# i.e. active leechers pulling data from your qBittorrent seeds. Polls the
# qBittorrent WebUI API and watches the count of peers we're uploading to.
# The WebUI credentials are read from Seanime's settings DB at runtime, so no
# password is ever stored in this file (it lives in a public config repo).

# [CONFIG]
CHECK_INTERVAL=5
NTF_LIFETIME=8000
SEANIME_DB="$HOME/.config/Seanime/seanime.db"
START_SOUND="/home/halosviel/Local/Rice/Sounds/notify.mp3"
STOP_SOUND="/home/halosviel/Local/Rice/Sounds/information-bar.mp3"
COOKIE="/tmp/seeding_ntf.cookie"

# -->

happy_icon() { ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1; }
sad_icon()   { ls /home/halosviel/Local/Rice/Icons/Sad/*.png   | shuf -n 1; }

excl() { printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))); }

human_speed() {
  local b=${1:-0}
  if   [ "$b" -ge 1048576 ]; then awk "BEGIN{printf \"%.1f MB/s\", $b/1048576}"
  elif [ "$b" -ge 1024 ];    then awk "BEGIN{printf \"%.0f KB/s\", $b/1024}"
  else echo "${b} B/s"; fi
}

# Pull qBittorrent WebUI host/port/creds straight from Seanime (read-only), so
# the secret never has to live in this script.
load_creds() {
  QB_HOST=$(sqlite3 -readonly "$SEANIME_DB" "SELECT qbittorrent_host FROM settings LIMIT 1;" 2>/dev/null)
  QB_PORT=$(sqlite3 -readonly "$SEANIME_DB" "SELECT qbittorrent_port FROM settings LIMIT 1;" 2>/dev/null)
  QB_USER=$(sqlite3 -readonly "$SEANIME_DB" "SELECT qbittorrent_username FROM settings LIMIT 1;" 2>/dev/null)
  QB_PASS=$(sqlite3 -readonly "$SEANIME_DB" "SELECT qbittorrent_password FROM settings LIMIT 1;" 2>/dev/null)
  [ -z "$QB_HOST" ] && QB_HOST="127.0.0.1"
  [ -z "$QB_PORT" ] && QB_PORT="8081"
  QB="http://$QB_HOST:$QB_PORT"
}

# Log in to the WebUI, saving the session cookie. Non-zero if qbit is down.
qb_login() {
  local code
  code=$(curl -s -m 5 -o /dev/null -w '%{http_code}' -c "$COOKIE" \
    --data-urlencode "username=$QB_USER" --data-urlencode "password=$QB_PASS" \
    "$QB/api/v2/auth/login" 2>/dev/null)
  [ "$code" = "200" ] || [ "$code" = "204" ]
}

# Echo the number of peers currently downloading FROM us (up_speed > 0) across
# all torrents, or "DOWN" when the WebUI can't be reached / auth is lost.
count_leechers() {
  local hashes n total=0
  hashes=$(curl -s -m 5 -b "$COOKIE" "$QB/api/v2/torrents/info" 2>/dev/null \
    | python3 -c 'import sys,json;[print(t["hash"]) for t in json.load(sys.stdin)]' 2>/dev/null)

  # No/!JSON answer -> session may have expired; re-login once and retry.
  if [ -z "$hashes" ]; then
    qb_login || { echo DOWN; return; }
    hashes=$(curl -s -m 5 -b "$COOKIE" "$QB/api/v2/torrents/info" 2>/dev/null \
      | python3 -c 'import sys,json;[print(t["hash"]) for t in json.load(sys.stdin)]' 2>/dev/null)
    [ -z "$hashes" ] && { curl -s -m 3 -o /dev/null "$QB" || { echo DOWN; return; }; echo 0; return; }
  fi

  for h in $hashes; do
    n=$(curl -s -m 5 -b "$COOKIE" "$QB/api/v2/sync/torrentPeers?hash=$h&rid=0" 2>/dev/null \
      | python3 -c 'import sys,json;d=json.load(sys.stdin);print(sum(1 for p in d.get("peers",{}).values() if p.get("up_speed",0)>0))' 2>/dev/null)
    total=$(( total + ${n:-0} ))
  done
  echo "$total"
}

# Current total upload speed (bytes/s), for the notification body.
up_speed() {
  curl -s -m 5 -b "$COOKIE" "$QB/api/v2/transfer/info" 2>/dev/null \
    | python3 -c 'import sys,json;print(json.load(sys.stdin).get("up_info_speed",0))' 2>/dev/null
}

# -->

load_creds
qb_login

# Silent baseline: don't fire for peers that were already leeching at startup;
# only react to changes from here on (same as the other _ntf daemons).
prev=$(count_leechers)
[ "$prev" = "DOWN" ] && prev=0

while true; do
  sleep "$CHECK_INTERVAL"
  now=$(count_leechers)

  # qbit went away (e.g. Seanime closed) -> reset quietly, no notification.
  if [ "$now" = "DOWN" ]; then
    prev=0
    continue
  fi

  if [ "$prev" -eq 0 ] && [ "$now" -gt 0 ]; then
    peers=$now; [ "$peers" -eq 1 ] && who="someone" || who="$peers people"
    notify-send "Someone's leeching from you$(excl)" \
      "$who pulling your anime 📥  (↑ $(human_speed "$(up_speed)"))" \
      -t "$NTF_LIFETIME" -i "$(happy_icon)"
    paplay --volume=32768 "$START_SOUND" &
  elif [ "$prev" -gt 0 ] && [ "$now" -eq 0 ]; then
    notify-send "Seeding went quiet" \
      "nobody's downloading from you right now 🥀" \
      -t "$NTF_LIFETIME" -i "$(sad_icon)"
    paplay --volume=32768 "$STOP_SOUND" &
  fi

  prev=$now
done
