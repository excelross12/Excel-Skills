#!/usr/bin/env bash
# stop.sh — Loop detection + session summary on Claude stop
# Fires: Stop lifecycle event

BMAD_DIR=".bmad"
mkdir -p "$BMAD_DIR"

LOOP_FILE="$BMAD_DIR/.loop-detect"
TOOL_LOG="$BMAD_DIR/.tool-count"

# ── 1. Loop detection ─────────────────────────────────────────────────────
# Hash recent tool usage pattern (passed via env or input)
TOOL_INPUT=$(cat 2>/dev/null)

TOOL_HASH=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys, hashlib
try:
    d = json.load(sys.stdin)
    tool = d.get('tool_name','')
    inp = str(d.get('tool_input',{}))
    combined = tool + inp[:50]
    print(hashlib.md5(combined.encode()).hexdigest()[:8])
except:
    import random
    print(str(random.randint(1000,9999)))
" 2>/dev/null)

if [ -n "$TOOL_HASH" ]; then
  echo "$TOOL_HASH" >> "$LOOP_FILE" 2>/dev/null

  # Check last 3 entries for identical hash
  if [ -f "$LOOP_FILE" ]; then
    LAST3_UNIQUE=$(tail -3 "$LOOP_FILE" 2>/dev/null | sort -u | wc -l | tr -d ' ')
    if [ "$LAST3_UNIQUE" = "1" ]; then
      echo ""
      echo "🔄 LOOP DETECTED: Same action repeated 3+ times."
      echo "   Stop, reassess, and try a different approach."
      echo "   If stuck: invoke @debugger or @architect-review"
    fi
  fi

  # Keep loop file lean
  if [ -f "$LOOP_FILE" ]; then
    tail -20 "$LOOP_FILE" > "$LOOP_FILE.tmp" 2>/dev/null && \
      mv "$LOOP_FILE.tmp" "$LOOP_FILE" 2>/dev/null
  fi
fi

# ── 2. Session progress summary ───────────────────────────────────────────
CALL_NUM=$(cat "$TOOL_LOG" 2>/dev/null || echo "0")
if [ "$CALL_NUM" -ge 10 ]; then
  STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  echo ""
  echo "── Session: ${CALL_NUM} tool calls | Staged: ${STAGED} files | Modified: ${MODIFIED} files ──"
fi

# ── 3. Reset tool count on stop (new turn) ────────────────────────────────
# Keep running total but note the turn boundary
if [ -f "$TOOL_LOG" ]; then
  echo "$CALL_NUM" > "$TOOL_LOG"
fi

exit 0
