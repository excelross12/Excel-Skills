#!/usr/bin/env bash
# agent-router — runs on UserPromptSubmit
# Detects intent in user message; suggests routing to bmad-orchestrator agent
# This hook does NOT modify the prompt; it only emits a routing hint to stderr.

INPUT=$(cat)

# Extract .prompt from JSON — try jq, fall back to Python
PROMPT=""
if command -v jq >/dev/null 2>&1; then
  PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  PROMPT=$(python3 -c "
import json, sys
try:
    print(json.loads(sys.stdin.read()).get('prompt', ''))
except Exception:
    print('')
" <<< "$INPUT" 2>/dev/null)
elif command -v python >/dev/null 2>&1; then
  PROMPT=$(python -c "
import json, sys
try:
    print(json.loads(sys.stdin.read()).get('prompt', ''))
except Exception:
    print('')
" <<< "$INPUT" 2>/dev/null)
fi

# Skip if empty or already starts with / (slash command — handled directly)
[ -z "$PROMPT" ] && exit 0
[[ "$PROMPT" =~ ^/ ]] && exit 0

# Detect intent signals (first match wins)
ROUTE=""

if echo "$PROMPT" | grep -iE "(not working|broken|error|exception|fails|crash|bug|traceback|stacktrace|undefined|null pointer)" > /dev/null; then
  ROUTE="debugger"
elif echo "$PROMPT" | grep -iE "(review|check my code|PR review|before merge|blast radius|side effects)" > /dev/null; then
  ROUTE="code-reviewer"
elif echo "$PROMPT" | grep -iE "(secure|auth|authorization|OWASP|injection|XSS|vulnerability|token|permission)" > /dev/null; then
  ROUTE="security-auditor"
elif echo "$PROMPT" | grep -iE "(deploy|CI|CD|pipeline|docker|kubernetes|infra|terraform|container)" > /dev/null; then
  ROUTE="devops-engineer"
elif echo "$PROMPT" | grep -iE "(test|coverage|playwright|e2e|unit test)" > /dev/null; then
  ROUTE="test-engineer"
elif echo "$PROMPT" | grep -iE "(refactor|clean up|tech debt|simplify|reorganize)" > /dev/null; then
  ROUTE="bmad-orchestrator"
elif echo "$PROMPT" | grep -iE "(build|create|implement|add feature|new component|new function)" > /dev/null; then
  ROUTE="bmad-orchestrator"
elif echo "$PROMPT" | grep -iE "(and also|plus I need|help me with my project|what should I|vague)" > /dev/null; then
  ROUTE="task-decomposer"
elif echo "$PROMPT" | grep -iE "(slow|laggy|timeout|performance|optimize|N\+1|memory leak|bundle size)" > /dev/null; then
  ROUTE="bmad-orchestrator"
elif echo "$PROMPT" | grep -iE "(clean up files|organize|sort files|find duplicates|downloads)" > /dev/null; then
  ROUTE="file-organizer"
fi

if [ -n "$ROUTE" ]; then
  echo "Suggested routing: @$ROUTE (BMAD intent-detected)" >&2
fi

exit 0
