#!/usr/bin/env bash
# session-start.sh — Memory injection, anchor loading, last-session handoff
# Fires: SessionStart lifecycle event

BMAD_DIR=".bmad"
ANCHORS="$BMAD_DIR/anchors.json"
LAST_SESSION="$BMAD_DIR/last-session.md"
STATE="$BMAD_DIR/state.json"

mkdir -p "$BMAD_DIR/anchors-archive"

# ── 1. Last session handoff ────────────────────────────────────────────────
if [ -f "$LAST_SESSION" ]; then
  echo ""
  echo "┌─ LAST SESSION HANDOFF ──────────────────────────────────────────┐"
  head -30 "$LAST_SESSION"
  echo "└─────────────────────────────────────────────────────────────────┘"
fi

# ── 2. Active anchors injection ────────────────────────────────────────────
if [ -f "$ANCHORS" ]; then
  anchor_count=$(python3 -c "
import json, sys
try:
    d = json.load(open('$ANCHORS'))
    print(len(d))
except:
    print(0)
" 2>/dev/null || echo "0")

  if [ "$anchor_count" -gt 0 ]; then
    echo ""
    echo "┌─ ACTIVE ANCHORS ($anchor_count) ─────────────────────────────────────┐"
    python3 -c "
import json
try:
    d = json.load(open('$ANCHORS'))
    items = sorted(d.items(), key=lambda x: x[1].get('last_referenced',''), reverse=True)[:5]
    for k, v in items:
        summary = v.get('summary','')[:55]
        print(f'  §{k:<22} {summary}')
except Exception as e:
    pass
" 2>/dev/null
    echo "└────────────────────────────────────────────────────────────────┘"
  fi

  # Prune anchors exceeding TTL
  python3 -c "
import json, os
from datetime import datetime

try:
    with open('$ANCHORS') as f:
        d = json.load(f)

    archive_dir = '$BMAD_DIR/anchors-archive'
    to_archive = []

    for k, v in d.items():
        ttl = v.get('ttl_sessions', 10)
        last_ref = v.get('last_referenced', '')
        # Simple prune: if ttl_sessions is 0, archive
        if ttl <= 0:
            to_archive.append(k)

    for k in to_archive:
        anchor_data = d.pop(k)
        archive_path = os.path.join(archive_dir, f'§{k}_ARCHIVED.json')
        with open(archive_path, 'w') as f:
            json.dump(anchor_data, f, indent=2)

    if len(d) > 10:
        # Archive oldest by last_referenced
        sorted_items = sorted(d.items(), key=lambda x: x[1].get('last_referenced',''))
        excess = len(d) - 10
        for k, v in sorted_items[:excess]:
            to_archive.append(k)
            archive_path = os.path.join(archive_dir, f'§{k}_ARCHIVED.json')
            with open(archive_path, 'w') as f:
                json.dump(v, f, indent=2)
            del d[k]

    with open('$ANCHORS', 'w') as f:
        json.dump(d, f, indent=2)
except:
    pass
" 2>/dev/null
fi

# ── 3. BMAD phase state ────────────────────────────────────────────────────
if [ -f "$STATE" ]; then
  python3 -c "
import json
try:
    d = json.load(open('$STATE'))
    phase = d.get('phase','')
    story = d.get('current_story','')
    agent = d.get('active_agent','')
    if phase:
        print(f'  BMAD Phase: {phase} | Agent: {agent} | Story: {story}')
except:
    pass
" 2>/dev/null
fi

# ── 4. Recent errors warning ───────────────────────────────────────────────
if [ -f "$BMAD_DIR/improvement.jsonl" ]; then
  error_count=$(wc -l < "$BMAD_DIR/improvement.jsonl" 2>/dev/null || echo "0")
  if [ "$error_count" -ge 3 ]; then
    echo "  ⚠️  $error_count errors in log — run @self-improver to diagnose"
  fi
fi

exit 0
