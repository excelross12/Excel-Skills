#!/usr/bin/env bash
# pre-compact.sh — Save full session state before context compaction
# Fires: PreCompact lifecycle event (PERFECT moment to capture state)

BMAD_DIR=".bmad"
LAST_SESSION="$BMAD_DIR/last-session.md"

mkdir -p "$BMAD_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")

# Capture git context
GIT_LOG=$(git log --oneline -5 2>/dev/null || echo "No commits")
GIT_STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
GIT_MODIFIED=$(git diff --name-only 2>/dev/null || echo "")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Capture active anchors
ANCHORS_SUMMARY=""
if [ -f "$BMAD_DIR/anchors.json" ]; then
  ANCHORS_SUMMARY=$(python3 -c "
import json
try:
    d = json.load(open('$BMAD_DIR/anchors.json'))
    items = sorted(d.items(), key=lambda x: x[1].get('last_referenced',''), reverse=True)[:5]
    for k, v in items:
        print(f'  §{k}: {v.get(\"summary\",\"\")}')
except:
    pass
" 2>/dev/null)
fi

# Capture BMAD state
BMAD_STATE=""
if [ -f "$BMAD_DIR/state.json" ]; then
  BMAD_STATE=$(python3 -c "
import json
try:
    d = json.load(open('$BMAD_DIR/state.json'))
    print(f'Phase: {d.get(\"phase\",\"?\")} | Agent: {d.get(\"active_agent\",\"?\")} | Story: {d.get(\"current_story\",\"?\")}')
except:
    pass
" 2>/dev/null)
fi

# Capture recent errors
RECENT_ERRORS=""
if [ -f "$BMAD_DIR/improvement.jsonl" ]; then
  RECENT_ERRORS=$(tail -3 "$BMAD_DIR/improvement.jsonl" 2>/dev/null)
fi

cat > "$LAST_SESSION" << EOF
# Session Handoff — $TIMESTAMP

## Git State
Branch: $GIT_BRANCH

Recent commits:
$GIT_LOG

Staged files:
${GIT_STAGED:-none}

Modified (unstaged):
${GIT_MODIFIED:-none}

## BMAD State
${BMAD_STATE:-Not initialized}

## Active Anchors (top 5)
${ANCHORS_SUMMARY:-No anchors}

## Recent Errors
${RECENT_ERRORS:-None}

## Resume Instructions
1. Read this handoff block
2. Run \`git status\` to see current state
3. Check .bmad/state.json for phase/story
4. Check .bmad/anchors.json for active context
5. Continue from where the session left off
EOF

echo "✓ Session state saved to $LAST_SESSION (pre-compaction)"
exit 0
