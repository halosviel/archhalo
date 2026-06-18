#!/bin/bash

# [CONFIG]
DONE_MESSAGES=(
    "Claude-chan has a message for you:"
    "Claude-chan responded:"
    "New message from Claude-chan:"
    "Unread message from Claude-chan:"
)

ATTENTION_MESSAGES=(
    "Claude-chan needs to"
    "Claude-chan wants to"
    "Claude-chan is trying to"
)

SOUND="/home/halosviel/Local/Rice/Sounds/information-bar.mp3"

# -->

iconClaude() {
  ls /home/halosviel/Local/Rice/Icons/Claude/*.png | shuf -n 1
}

# -->

type="${1:-stop}"


if [[ "$type" == "permission" ]]; then
    input=$(cat)
    idx=$(( RANDOM % ${#ATTENTION_MESSAGES[@]} ))
    exclamations=$(printf '%.0s!' $(seq 1 $((RANDOM % 3 + 1))))
    desc=$(echo "$input" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
tool = data.get('tool_name', '')
inp = data.get('tool_input', {})
if tool == 'Bash':
    cmd = inp.get('command', '').strip().split('\n')[0]
    if 'git push' in cmd:      desc = 'push to GitHub'
    elif 'git commit' in cmd:  desc = 'create a commit'
    elif cmd.startswith('rm'): desc = 'delete files'
    else:
        desc = inp.get('description', '').strip()
        if not desc:
            desc = 'run: ' + cmd[:35]
elif tool in ('Write', 'Edit'):
    name = inp.get('file_path', '?').split('/')[-1]
    desc = ('write to ' if tool == 'Write' else 'edit ') + name
else:
    desc = 'use ' + tool
print(desc[0].lower() + desc[1:] if desc else desc)
" 2>/dev/null)
    body="${ATTENTION_MESSAGES[$idx]} $desc"
		paplay --volume=32768 "$SOUND" &
    notify-send -u normal "Claude Mail$exclamations" "$body" -i "$(iconClaude)"
    exit 0
fi

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
import sys, json, re
def strip_md(text):
    text = re.sub(r'\*\*(.+?)\*\*', r'\1', text)
    text = re.sub(r'\*(.+?)\*', r'\1', text)
    text = re.sub(r'__(.+?)__', r'\1', text)
    text = re.sub(r'_(.+?)_', r'\1', text)
    text = re.sub(r'`(.+?)`', r'\1', text)
    text = re.sub(r'\[(.+?)\]\(.+?\)', r'\1', text)
    text = re.sub(r'^#{1,6}\s+', '', text, flags=re.MULTILINE)
    return text
transcript = open(sys.argv[1]).readlines()
for line in reversed(transcript):
    try:
        obj = json.loads(line)
        msg = obj.get('message', {})
        if msg.get('role') == 'assistant':
            for block in msg.get('content', []):
                if block.get('type') == 'text':
                    text = strip_md(block['text']).strip()
                    if text:
                        first = text.split('\n')[0].rstrip()
                        if len(first) > 25:
                            end = 25 + re.search(r'\S*', first[25:]).end()
                            print(first[:end].rstrip() + '..')
                        else:
                            print(first + ('..' if '\n' in text else ''))
                        sys.exit(0)
    except Exception:
        pass
EOF
        )
    fi
fi

body="${msgs[$idx]}"
[[ -n "$preview" ]] && body+=$'\n'"\"$preview\""
paplay --volume=32768 "$SOUND" &
notify-send -u "$urgency" "Claude Mail$exclamations" "$body" -i "$(iconClaude)"
