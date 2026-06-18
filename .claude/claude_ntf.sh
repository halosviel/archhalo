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

# -->

iconHappy() {
  ls /home/halosviel/Local/Rice/Icons/Happy/*.png | shuf -n 1
}

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
print(desc)
" 2>/dev/null)
    body="${ATTENTION_MESSAGES[$idx]} $desc"
    notify-send -u normal "Claude Mail$exclamations" "$body" -i "$(iconHappy)"
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
notify-send -u "$urgency" "Claude Mail$exclamations" "$body" -i "$(iconHappy)"
