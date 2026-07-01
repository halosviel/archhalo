#!/bin/bash

# [CONFIG]
CHECK_INTERVAL=5
NTF_LIFETIME=800000
MISS_GRACE=2            # a seeder must be missing this many polls before "left"
SEANIME_DB="$HOME/.config/Seanime/seanime.db"
START_SOUND="/home/halosviel/Local/Rice/Sounds/notify.mp3"
STOP_SOUND="/home/halosviel/Local/Rice/Sounds/information-bar.mp3"

# -->

happy_icon() {
	ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1;
}

sad_icon() {
	ls /home/halosviel/Local/Rice/Icons/Sad/*.png   | shuf -n 1;
}

active_seeders() {
  python3 - <<'PY' 2>/dev/null || echo DOWN
import os, sys, json, sqlite3, urllib.request, urllib.parse, http.cookiejar

db = os.path.expanduser("~/.config/Seanime/seanime.db")
def setting(col):
    try:
        con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
        row = con.execute("SELECT %s FROM settings LIMIT 1" % col).fetchone()
        con.close()
        return (row[0] if row else "") or ""
    except Exception:
        return ""

host = setting("qbittorrent_host") or "127.0.0.1"
port = setting("qbittorrent_port") or "8081"
qb   = "http://%s:%s" % (host, port)

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
def api(path, data=None):
    req = urllib.request.Request(qb + path, data=data, headers={"Referer": qb})
    return opener.open(req, timeout=5)

try:
    api("/api/v2/auth/login", urllib.parse.urlencode(
        {"username": setting("qbittorrent_username"),
         "password": setting("qbittorrent_password")}).encode()).read()
    torrents = json.load(api("/api/v2/torrents/info"))
except Exception:
    print("DOWN"); sys.exit(0)

out = []
for t in torrents:
    h, name = t.get("hash", ""), (t.get("name") or "?")
    try:
        peers = json.load(api("/api/v2/sync/torrentPeers?hash=%s&rid=0" % h)).get("peers", {})
    except Exception:
        continue
    for pid, p in peers.items():
        if "U" in (p.get("flags", "") or "").split() or (p.get("up_speed") or 0) > 0:
            ip      = p.get("ip", "?")
            client  = (p.get("client") or "?").strip() or "?"
            country = (p.get("country") or p.get("country_code") or "").strip()
            key     = h[:12] + "|" + pid
            out.append("\t".join([key, ip, client, country, name]))
if out:
    print("\n".join(out))
PY
}

# seeder joined
notify_start() {
  local ip client country name loc body
  IFS=$'\t' read -r ip client country name <<< "$1"

  loc=""; [ -n "$country" ] && loc="$country"
  name=${name:0:70}
	exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
  body=$(printf 'A seeder has joined%s\n󱧑 ip: %s\n %s\n󰷝 %s' "$exclamations" "$ip" "$loc" "$name")

  if [ "${DRY_RUN:-0}" = "1" ]; then
		echo "START :: $body"; return;
	fi

  notify-send "Seanime" "$body" -t "$NTF_LIFETIME" -i "$(happy_icon)"
  paplay --volume=32768 "$START_SOUND" &
}

# seeder left
notify_stop() {
  local ip client country name body
  IFS=$'\t' read -r ip client country name <<< "$1"

  name=${name:0:70}
	exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
  body=$(printf 'Seeder left%s\n󱧑 ip: %s\n󰷝 %s' "$exclamations" "$ip" "$name")

  if [ "${DRY_RUN:-0}" = "1" ]; then
		echo "STOP  :: $body"; return;
	fi

  notify-send "Seanime" "$body" -t "$NTF_LIFETIME" -i "$(sad_icon)"
  paplay --volume=32768 "$STOP_SOUND" &
}

declare -A seen
declare -A miss
first=1

process() {
  local lines=("$@") ln key rest
  # WebUI unreachable (e.g. Seanime/qbit closed) -> forget everyone, no noise.
  if [ "${lines[0]:-}" = "DOWN" ]; then
    seen=(); miss=(); return
  fi

  local -A cur=()
  for ln in "${lines[@]}"; do
    [ -z "$ln" ] && continue
    key=${ln%%$'\t'*}; rest=${ln#*$'\t'}
    cur[$key]=$rest
  done

  # Arrivals (and refresh of the known ones).
  for key in "${!cur[@]}"; do
    if [ -z "${seen[$key]+x}" ] && [ "$first" -eq 0 ]; then
      notify_start "${cur[$key]}"
    fi
    seen[$key]=${cur[$key]}
    miss[$key]=0
  done

  # Departures, with a grace period so a momentary blip doesn't flap.
  for key in "${!seen[@]}"; do
    if [ -z "${cur[$key]+x}" ]; then
      miss[$key]=$(( ${miss[$key]:-0} + 1 ))
      if [ "${miss[$key]}" -ge "$MISS_GRACE" ]; then
        [ "$first" -eq 0 ] && notify_stop "${seen[$key]}"
        unset 'seen[$key]' 'miss[$key]'
      fi
    fi
  done
}

main() {
  local lines
  while true; do
    mapfile -t lines < <(active_seeders)
    process "${lines[@]}"
    first=0                # after the first poll, pre-existing seeders are baselined
    sleep "$CHECK_INTERVAL"
  done
}

# --probe: print current seeders once (debug). Otherwise run, unless sourced for tests.
if [ "${1:-}" = "--probe" ]; then active_seeders; exit 0; fi
[ "${SEEDING_TEST:-0}" = "1" ] || main
