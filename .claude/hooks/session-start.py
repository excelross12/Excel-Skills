#!/usr/bin/env python3
"""session-start.py — Memory injection, anchor loading, last-session handoff.
Fires: SessionStart lifecycle event
"""
import json
import os
import sys
from pathlib import Path

BMAD_DIR = Path(".bmad")
ANCHORS = BMAD_DIR / "anchors.json"
LAST_SESSION = BMAD_DIR / "last-session.md"
STATE = BMAD_DIR / "state.json"
ARCHIVE_DIR = BMAD_DIR / "anchors-archive"
IMPROVEMENT = BMAD_DIR / "improvement.jsonl"

BMAD_DIR.mkdir(exist_ok=True)
ARCHIVE_DIR.mkdir(exist_ok=True)


def load_json(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


# ── 1. Last session handoff ───────────────────────────────────────────────
if LAST_SESSION.exists():
    lines = LAST_SESSION.read_text(encoding="utf-8").splitlines()[:30]
    print()
    print("┌─ LAST SESSION HANDOFF ──────────────────────────────────────────┐")
    for line in lines:
        print(line)
    print("└─────────────────────────────────────────────────────────────────┘")

# ── 2. Active anchors injection ───────────────────────────────────────────
anchors = load_json(ANCHORS) if ANCHORS.exists() else None
if anchors:
    count = len(anchors)
    print()
    print(f"┌─ ACTIVE ANCHORS ({count}) ─────────────────────────────────────┐")
    sorted_anchors = sorted(
        anchors.items(),
        key=lambda x: x[1].get("last_referenced", ""),
        reverse=True
    )[:5]
    for k, v in sorted_anchors:
        summary = v.get("summary", "")[:55]
        print(f"  §{k:<22} {summary}")
    print("└────────────────────────────────────────────────────────────────┘")

    # Prune anchors exceeding TTL or over limit of 10
    to_archive = [k for k, v in anchors.items() if v.get("ttl_sessions", 10) <= 0]
    for k in to_archive:
        data = anchors.pop(k)
        archive_path = ARCHIVE_DIR / f"§{k}_ARCHIVED.json"
        archive_path.write_text(json.dumps(data, indent=2), encoding="utf-8")

    if len(anchors) > 10:
        by_age = sorted(anchors.items(), key=lambda x: x[1].get("last_referenced", ""))
        excess = len(anchors) - 10
        for k, v in by_age[:excess]:
            archive_path = ARCHIVE_DIR / f"§{k}_ARCHIVED.json"
            archive_path.write_text(json.dumps(v, indent=2), encoding="utf-8")
            del anchors[k]

    ANCHORS.write_text(json.dumps(anchors, indent=2), encoding="utf-8")

# ── 3. BMAD phase state ───────────────────────────────────────────────────
state = load_json(STATE) if STATE.exists() else None
if state and state.get("phase"):
    phase = state.get("phase", "")
    agent = state.get("active_agent", "")
    story = state.get("current_story", "")
    print(f"  BMAD Phase: {phase} | Agent: {agent} | Story: {story}")

# ── 4. Recent errors warning ──────────────────────────────────────────────
if IMPROVEMENT.exists():
    error_count = len(IMPROVEMENT.read_text(encoding="utf-8").splitlines())
    if error_count >= 3:
        print(f"  ⚠️  {error_count} errors in log — run @self-improver to diagnose")

sys.exit(0)
