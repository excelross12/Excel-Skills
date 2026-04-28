#!/usr/bin/env bash
# error-tracker — runs PostToolUse: Bash
# Logs bash errors to .bmad/improvement.jsonl
# When same error pattern repeats 3+ times → emits self-improvement signal

INPUT=$(cat 2>/dev/null || echo "")

# Extract exit code and output — try jq, fall back to Python
EXIT_CODE=""
STDERR_OUT=""
CMD=""

if command -v python3 >/dev/null 2>&1; then
  PARSED=$(python3 - <<'PYEOF'
import json, sys
try:
    d = json.load(sys.stdin)
    ec = str(d.get('tool_response', {}).get('exit_code', '') or
             d.get('tool_result', {}).get('exit_code', '') or '')
    stderr = str(d.get('tool_response', {}).get('stderr', '') or
                 d.get('tool_result', {}).get('stderr', '') or '')
    cmd = str(d.get('tool_input', {}).get('command', '') or
              d.get('tool_input', {}).get('cmd', '') or '')
    print(f"{ec}|SEP|{stderr[:300]}|SEP|{cmd[:200]}")
except Exception:
    print("||")
PYEOF
  <<< "$INPUT")
  EXIT_CODE=$(echo "$PARSED" | cut -d'|' -f1)
  STDERR_OUT=$(echo "$PARSED" | awk -F'|SEP|' '{print $2}')
  CMD=$(echo "$PARSED" | awk -F'|SEP|' '{print $3}')
elif command -v jq >/dev/null 2>&1; then
  EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // .tool_result.exit_code // ""' 2>/dev/null)
  STDERR_OUT=$(echo "$INPUT" | jq -r '.tool_response.stderr // .tool_result.stderr // ""' 2>/dev/null | head -c 300)
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.cmd // ""' 2>/dev/null | head -c 200)
fi

# Only track genuine failures (non-zero, non-empty exit code)
[ -z "$EXIT_CODE" ] && exit 0
[ "$EXIT_CODE" = "0" ] && exit 0

BMAD_DIR=".bmad"
LOG="$BMAD_DIR/improvement.jsonl"
mkdir -p "$BMAD_DIR"
touch "$LOG"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || python3 -c "from datetime import datetime,timezone; print(datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))" 2>/dev/null || echo "unknown")

# Classify error type from stderr
ERROR_TYPE="unknown"
if echo "$STDERR_OUT" | grep -iE "(TypeError|AttributeError|NameError|ImportError|ModuleNotFound)" > /dev/null 2>&1; then
  ERROR_TYPE="python_error"
elif echo "$STDERR_OUT" | grep -iE "(TS[0-9]{4}|error TS|Type error)" > /dev/null 2>&1; then
  ERROR_TYPE="typescript_error"
elif echo "$STDERR_OUT" | grep -iE "(FAIL|AssertionError|test.*failed|playwright)" > /dev/null 2>&1; then
  ERROR_TYPE="test_failure"
elif echo "$STDERR_OUT" | grep -iE "(ENOENT|permission denied|not found)" > /dev/null 2>&1; then
  ERROR_TYPE="file_error"
elif echo "$STDERR_OUT" | grep -iE "(syntax error|unexpected token|parse error)" > /dev/null 2>&1; then
  ERROR_TYPE="syntax_error"
elif echo "$STDERR_OUT" | grep -iE "(hook|agent|skill)" > /dev/null 2>&1; then
  ERROR_TYPE="bmad_error"
fi

# Build log entry (Python for reliable JSON escaping)
if command -v python3 >/dev/null 2>&1; then
  python3 - "$TIMESTAMP" "$ERROR_TYPE" "$EXIT_CODE" <<PYEOF
import json, sys
entry = {
    "ts": sys.argv[1],
    "type": "error",
    "error_type": sys.argv[2],
    "exit_code": sys.argv[3],
    "stderr": """${STDERR_OUT}""".strip()[:300],
    "cmd": """${CMD}""".strip()[:200],
    "status": "pending"
}
print(json.dumps(entry))
PYEOF
else
  echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"error\",\"error_type\":\"$ERROR_TYPE\",\"exit_code\":\"$EXIT_CODE\",\"status\":\"pending\"}"
fi >> "$LOG"

# Count recent occurrences of this error type (last 50 entries)
if command -v python3 >/dev/null 2>&1; then
  REPEAT_COUNT=$(python3 - "$LOG" "$ERROR_TYPE" <<'PYEOF'
import json, sys
log_file, error_type = sys.argv[1], sys.argv[2]
try:
    lines = open(log_file).readlines()[-50:]
    count = sum(1 for l in lines if json.loads(l).get('error_type') == error_type and json.loads(l).get('status') == 'pending')
    print(count)
except Exception:
    print(0)
PYEOF
  )
else
  REPEAT_COUNT=0
fi

# Threshold: 3 same-type errors → trigger self-improvement signal
if [ "${REPEAT_COUNT:-0}" -ge 3 ]; then
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "  SELF-IMPROVE TRIGGERED" >&2
  echo "  Error type '$ERROR_TYPE' has occurred $REPEAT_COUNT times." >&2
  echo "  → Invoke @self-improver to diagnose and fix." >&2
  echo "  → Or run: /self-improve $ERROR_TYPE" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
fi

exit 0
