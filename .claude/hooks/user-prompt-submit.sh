#!/usr/bin/env bash
# user-prompt-submit.sh — Memory recall injection + skill activation hints
# Fires: UserPromptSubmit lifecycle event

BMAD_DIR=".bmad"
ANCHORS="$BMAD_DIR/anchors.json"

# Parse prompt from stdin
TOOL_INPUT=$(cat 2>/dev/null)
PROMPT=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('prompt', '')[:300])
except:
    print('')
" 2>/dev/null)

# ── 1. Inject active anchor count into context ────────────────────────────
if [ -f "$ANCHORS" ]; then
  python3 -c "
import json
try:
    d = json.load(open('$ANCHORS'))
    count = len(d)
    if count > 0:
        keys = list(d.keys())[:3]
        key_str = ' §'.join(keys)
        print(f'[Memory: {count} anchors — §{key_str}]')
except:
    pass
" 2>/dev/null
fi

# ── 2. Detect continuation prompts ───────────────────────────────────────
LAST_SESSION="$BMAD_DIR/last-session.md"
CONTINUATION_WORDS="continue|resume|pick up|where we left|carry on|keep going"
if echo "$PROMPT" | grep -qiE "$CONTINUATION_WORDS"; then
  if [ -f "$LAST_SESSION" ]; then
    echo ""
    echo "📎 Continuation detected — loading last session handoff:"
    head -20 "$LAST_SESSION"
    echo ""
  fi
fi

# ── 3. Skill routing hints based on prompt keywords ───────────────────────
python3 -c "
import sys, re
prompt = '''$PROMPT'''.lower()

hints = []

if any(w in prompt for w in ['bug','error','not working','broken','failing','crash','exception']):
    hints.append('🔧 @debugger — systematic root-cause analysis')

if any(w in prompt for w in ['commit','push','branch','merge','pr','pull request']):
    hints.append('📦 git-flow skill — conventional commits + branch hygiene')

if any(w in prompt for w in ['test','playwright','e2e','spec','coverage']):
    hints.append('🧪 webapp-testing-suite — Playwright TDD-E2E workflow')
    hints.append('🎭 playwright-best-practices — activity-based reference')

if any(w in prompt for w in ['ui','component','design','layout','style','css','tailwind']):
    hints.append('🎨 frontend-design-pro — 5-state components + WCAG AA')

if any(w in prompt for w in ['api','endpoint','database','migration','auth','backend']):
    hints.append('⚙️ backend-engineering — contract-first + 4-layer security')

if any(w in prompt for w in ['memory','anchor','session','context','handoff']):
    hints.append('🧠 agent-memory — anchor system + TTL management')

if any(w in prompt for w in ['organize','brainstorm','approach','ideas','options','how should']):
    hints.append('💡 brainstorm-deep — 7+ options + structured recommendation')

if hints:
    print('')
    print('Skills that may help:')
    for h in hints[:3]:
        print(f'  {h}')
" 2>/dev/null

exit 0
