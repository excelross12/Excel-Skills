#!/usr/bin/env bash
# session-boot — runs on SessionStart
# Initializes BMAD state, restores anchors, prints session header
# No jq dependency: uses Python (always available with Claude Code) as fallback

set -e

BMAD_DIR=".bmad"
mkdir -p "$BMAD_DIR"

# Init state.json if missing
if [ ! -f "$BMAD_DIR/state.json" ]; then
  cat > "$BMAD_DIR/state.json" <<'EOF'
{
  "phase": "READY",
  "active_agent": null,
  "current_story": null,
  "queue": [],
  "blocked_by": null,
  "history": []
}
EOF
fi

# Init anchors.json if missing
if [ ! -f "$BMAD_DIR/anchors.json" ]; then
  echo '{}' > "$BMAD_DIR/anchors.json"
fi

# Init history log
touch "$BMAD_DIR/history.jsonl"

# Detect active IDE
IDE="claude-code"
[ -d ".cursor" ] && IDE="cursor"
[ -d ".kiro" ] && IDE="kiro"
[ -f "GEMINI.md" ] && IDE="antigravity"
[ -f ".windsurfrules" ] && IDE="windsurf"

# --- JSON reading: try jq, fall back to Python, fall back to defaults ---

_json_get() {
  local file="$1" key="$2" default="$3"
  if command -v jq >/dev/null 2>&1; then
    jq -r "${key} // \"${default}\"" "$file" 2>/dev/null || echo "$default"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json, sys
try:
    d = json.load(open('$file'))
    keys = '$key'.lstrip('.').split('.')
    for k in keys:
        d = d.get(k) if isinstance(d, dict) else None
    print(d if d is not None else '$default')
except Exception:
    print('$default')
" 2>/dev/null
  elif command -v python >/dev/null 2>&1; then
    python -c "
import json, sys
try:
    d = json.load(open('$file'))
    keys = '$key'.lstrip('.').split('.')
    for k in keys:
        d = d.get(k) if isinstance(d, dict) else None
    print(d if d is not None else '$default')
except Exception:
    print('$default')
" 2>/dev/null
  else
    echo "$default"
  fi
}

_anchor_count() {
  local file="$1"
  if command -v jq >/dev/null 2>&1; then
    jq 'keys | length' "$file" 2>/dev/null || echo "0"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import json; print(len(json.load(open('$file'))))" 2>/dev/null || echo "0"
  elif command -v python >/dev/null 2>&1; then
    python -c "import json; print(len(json.load(open('$file'))))" 2>/dev/null || echo "0"
  else
    echo "?"
  fi
}

_anchor_top3() {
  local file="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" <<'PYEOF'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
    items = list(data.items())
    # Sort by updated desc, then created desc
    def sort_key(item):
        v = item[1] if isinstance(item[1], dict) else {}
        return v.get('updated', v.get('created', ''))
    items.sort(key=sort_key, reverse=True)
    for name, val in items[:3]:
        summary = val.get('summary', '(no summary)') if isinstance(val, dict) else str(val)
        print(f"  §{name}: {summary[:72]}")
except Exception:
    pass
PYEOF
  elif command -v python >/dev/null 2>&1; then
    python - "$file" <<'PYEOF'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
    items = list(data.items())
    def sort_key(item):
        v = item[1] if isinstance(item[1], dict) else {}
        return v.get('updated', v.get('created', ''))
    items.sort(key=sort_key, reverse=True)
    for name, val in items[:3]:
        summary = val.get('summary', '(no summary)') if isinstance(val, dict) else str(val)
        print("  SS{}: {}".format(name, summary[:72]))
except Exception:
    pass
PYEOF
  fi
}

STATE_PHASE=$(_json_get "$BMAD_DIR/state.json" ".phase" "READY")
STATE_AGENT=$(_json_get "$BMAD_DIR/state.json" ".active_agent" "none")
STATE_STORY=$(_json_get "$BMAD_DIR/state.json" ".current_story" "none")
ANCHOR_COUNT=$(_anchor_count "$BMAD_DIR/anchors.json")

# Print boot block to stderr (visible in session but doesn't block)
{
  echo "╔══════════════════════════════════════════════╗"
  echo "║  BMAD SESSION BOOT                           ║"
  printf "║  IDE:      %-34s║\n" "$IDE"
  printf "║  Phase:    %-34s║\n" "$STATE_PHASE"
  printf "║  Active:   %-34s║\n" "$STATE_AGENT"
  printf "║  Story:    %-34s║\n" "$STATE_STORY"
  printf "║  Anchors:  %-34s║\n" "$ANCHOR_COUNT loaded"
  echo "╠══════════════════════════════════════════════╣"
  echo "║  Recent Anchors:                             ║"
  ANCHOR_TOP=$(_anchor_top3 "$BMAD_DIR/anchors.json")
  if [ -n "$ANCHOR_TOP" ]; then
    echo "$ANCHOR_TOP"
  else
    echo "  (none yet)"
  fi
  echo "╚══════════════════════════════════════════════╝"
} >&2

exit 0
