#!/usr/bin/env bash
# post-edit.sh — Smart git staging + edit tracking + TS type-check
# Fires: PostToolUse on Edit|Write|MultiEdit

BMAD_DIR=".bmad"
mkdir -p "$BMAD_DIR"

# Parse tool input from stdin
TOOL_INPUT=$(cat 2>/dev/null)

# Extract file path (handles Edit, Write, MultiEdit formats)
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    # PostToolUse wraps: {tool_name, tool_input, tool_response}
    inp = d.get('tool_input', d)
    path = inp.get('file_path') or inp.get('path') or ''
    print(path)
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# ── 1. Auto-stage the file ────────────────────────────────────────────────
git add "$FILE_PATH" 2>/dev/null

# ── 2. Track edit count (Clauditor-style thrash detection) ────────────────
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%s)
echo "{\"file\":\"$FILE_PATH\",\"time\":\"$TIMESTAMP\"}" >> "$BMAD_DIR/edit-log.jsonl" 2>/dev/null

EDIT_COUNT=$(grep -c "\"file\":\"$FILE_PATH\"" "$BMAD_DIR/edit-log.jsonl" 2>/dev/null || echo "0")
if [ "$EDIT_COUNT" -ge 5 ]; then
  echo "⚠️  Edit thrash: $FILE_PATH edited ${EDIT_COUNT}x this session — consider architectural review"
fi

# ── 3. TypeScript type-check on .ts/.tsx saves ───────────────────────────
case "$FILE_PATH" in
  *.ts|*.tsx)
    if [ -f "tsconfig.json" ] && command -v npx >/dev/null 2>&1; then
      TS_ERRORS=$(npx tsc --noEmit 2>&1 | head -10)
      if [ -n "$TS_ERRORS" ]; then
        echo "⚠️  TypeScript errors after edit:"
        echo "$TS_ERRORS"
      fi
    fi
    ;;
esac

exit 0
