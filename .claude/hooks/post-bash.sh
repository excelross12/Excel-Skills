#!/usr/bin/env bash
# post-bash.sh — Error tracking, loop detection, token waste warning
# Fires: PostToolUse on Bash

BMAD_DIR=".bmad"
mkdir -p "$BMAD_DIR"

# Parse tool input from stdin
TOOL_INPUT=$(cat 2>/dev/null)

EXIT_CODE=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    # PostToolUse: {tool_name, tool_input, tool_response}
    resp = d.get('tool_response', {})
    # Exit code may be in tool_response or nested
    print(resp.get('exit_code', d.get('exit_code', 0)))
except:
    print(0)
" 2>/dev/null)

COMMAND=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    inp = d.get('tool_input', d)
    cmd = inp.get('command', '')
    print(cmd[:120])
except:
    print('')
" 2>/dev/null)

# ── 1. Log errors to improvement.jsonl ────────────────────────────────────
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%s)
  CMD_JSON=$(echo "$COMMAND" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo "\"$COMMAND\"")
  echo "{\"cmd\":$CMD_JSON,\"exit\":$EXIT_CODE,\"time\":\"$TIMESTAMP\"}" >> "$BMAD_DIR/improvement.jsonl" 2>/dev/null

  # Warn at 3+ errors — suggest self-improver
  ERROR_COUNT=$(wc -l < "$BMAD_DIR/improvement.jsonl" 2>/dev/null || echo "0")
  if [ "$ERROR_COUNT" -ge 3 ] && [ "$((ERROR_COUNT % 3))" -eq 0 ]; then
    echo "⚠️  $ERROR_COUNT bash errors logged this session — consider: @self-improver diagnose"
  fi
fi

# ── 2. Clauditor-style token waste detection ──────────────────────────────
# Track tool call count as a proxy for session length
TOOL_LOG="$BMAD_DIR/.tool-count"
CALL_NUM=$(cat "$TOOL_LOG" 2>/dev/null || echo "0")
CALL_NUM=$((CALL_NUM + 1))
echo "$CALL_NUM" > "$TOOL_LOG"

if [ "$CALL_NUM" -eq 20 ]; then
  echo "💡 20 tool calls in session — consider /save-session if context is getting heavy"
fi
if [ "$CALL_NUM" -eq 50 ]; then
  echo "⚠️  50 tool calls — high context load. Run @agent-memory to save anchors before compaction"
fi

# ── 3. Keep edit log lean ─────────────────────────────────────────────────
if [ -f "$BMAD_DIR/edit-log.jsonl" ]; then
  LINE_COUNT=$(wc -l < "$BMAD_DIR/edit-log.jsonl" 2>/dev/null || echo "0")
  if [ "$LINE_COUNT" -gt 200 ]; then
    tail -100 "$BMAD_DIR/edit-log.jsonl" > "$BMAD_DIR/edit-log.jsonl.tmp" 2>/dev/null && \
      mv "$BMAD_DIR/edit-log.jsonl.tmp" "$BMAD_DIR/edit-log.jsonl" 2>/dev/null
  fi
fi

exit 0
