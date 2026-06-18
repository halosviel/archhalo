#!/bin/bash

# [CONFIG]
DONE_MESSAGES=(
    "Claude-chan has a message for you"
    "Claude-chan responded"
    "New message from Claude-chan!"
    "Unread message from Claude-chan"
)

ATTENTION_MESSAGES=(
    "Claude-chan needs your attention"
    "Claude-chan needs something from you"
    "Claude-chan needs permissions to do something"
    "Claude-chan is needs your response"
    "Claude-chan has something important!"
)

# -->

type="${1:-stop}"

# Only notify if the user is on a different workspace than Claude
active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null)
claude_ws=""
pid=$$
while [[ -n "$pid" && "$pid" -gt 1 ]]; do
    ws=$(hyprctl clients -j 2>/dev/null | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .workspace.id' 2>/dev/null)
    if [[ -n "$ws" && "$ws" != "null" ]]; then
        claude_ws="$ws"
        break
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
done
[[ -n "$active_ws" && -n "$claude_ws" && "$active_ws" == "$claude_ws" ]] && exit 0

if [[ "$type" == "notification" ]]; then
    msgs=("${ATTENTION_MESSAGES[@]}")
    urgency="normal"
else
    msgs=("${DONE_MESSAGES[@]}")
    urgency="low"
fi

idx=$(( RANDOM % ${#msgs[@]} ))
exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
preview=""
if [[ -n "$session_id" ]]; then
    # Wait for transcript to flush before reading
    [[ "$type" == "stop" ]] && sleep 0.5

    transcript=$(find ~/.claude/projects -name "${session_id}.jsonl" 2>/dev/null | head -1)
    if [[ -n "$transcript" ]]; then
        preview=$(python3 - "$transcript" <<'EOF'
import sys, json
transcript = open(sys.argv[1]).readlines()
for line in reversed(transcript):
    try:
        obj = json.loads(line)
        msg = obj.get('message', {})
        if msg.get('role') == 'assistant':
            for block in msg.get('content', []):
                if block.get('type') == 'text':
                    text = block['text'].strip()
                    if text:
                        print(text[:25] + ('..' if len(text) > 25 else ''))
                        sys.exit(0)
    except Exception:
        pass
EOF
        )
    fi
fi

body="${msgs[$idx]}"
[[ -n "$preview" ]] && body+=$'\n'"\"$preview\""
notify-send -u "$urgency" "Claude Mail$exclamations" "$body"
