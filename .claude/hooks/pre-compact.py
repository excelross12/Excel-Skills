#!/usr/bin/env python3
"""pre-compact.py — Save full session state before context compaction.
Fires: PreCompact lifecycle event (PERFECT moment to capture state)
"""
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

BMAD_DIR = Path(".bmad")
LAST_SESSION = BMAD_DIR / "last-session.md"
BMAD_DIR.mkdir(exist_ok=True)


def run(cmd):
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=5
        )
        return result.stdout.strip() or ""
    except Exception:
        return ""


timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

git_branch = run("git branch --show-current") or "unknown"
git_log = run("git log --oneline -5") or "No commits"
git_staged = run("git diff --cached --name-only") or "none"
git_modified = run("git diff --name-only") or "none"

# Active anchors
anchors_summary = "No anchors"
anchors_path = BMAD_DIR / "anchors.json"
if anchors_path.exists():
    try:
        anchors = json.loads(anchors_path.read_text(encoding="utf-8"))
        items = sorted(anchors.items(), key=lambda x: x[1].get("last_referenced", ""), reverse=True)[:5]
        anchors_summary = "\n".join(f"  §{k}: {v.get('summary','')}" for k, v in items) or "No anchors"
    except Exception:
        pass

# BMAD state
bmad_state = "Not initialized"
state_path = BMAD_DIR / "state.json"
if state_path.exists():
    try:
        s = json.loads(state_path.read_text(encoding="utf-8"))
        bmad_state = f"Phase: {s.get('phase','?')} | Agent: {s.get('active_agent','?')} | Story: {s.get('current_story','?')}"
    except Exception:
        pass

# Recent errors
recent_errors = "None"
improvement_path = BMAD_DIR / "improvement.jsonl"
if improvement_path.exists():
    lines = improvement_path.read_text(encoding="utf-8").splitlines()
    recent_errors = "\n".join(lines[-3:]) or "None"

content = f"""# Session Handoff — {timestamp}

## Git State
Branch: {git_branch}

Recent commits:
{git_log}

Staged files:
{git_staged}

Modified (unstaged):
{git_modified}

## BMAD State
{bmad_state}

## Active Anchors (top 5)
{anchors_summary}

## Recent Errors
{recent_errors}

## Resume Instructions
1. Read this handoff block
2. Run `git status` to see current state
3. Check .bmad/state.json for phase/story
4. Check .bmad/anchors.json for active context
5. Continue from where the session left off
"""

LAST_SESSION.write_text(content, encoding="utf-8")
print(f"✓ Session state saved to {LAST_SESSION} (pre-compaction)")
sys.exit(0)
