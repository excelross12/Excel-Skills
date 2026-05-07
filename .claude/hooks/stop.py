#!/usr/bin/env python3
"""stop.py — Loop detection + session summary on Claude stop.
Fires: Stop lifecycle event
"""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

BMAD_DIR = Path(".bmad")
BMAD_DIR.mkdir(exist_ok=True)

LOOP_FILE = BMAD_DIR / ".loop-detect"
TOOL_LOG = BMAD_DIR / ".tool-count"

# Read tool input from stdin
try:
    raw = sys.stdin.read()
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    data = {}

# ── 1. Loop detection ─────────────────────────────────────────────────────
tool_name = data.get("tool_name", "")
tool_input = str(data.get("tool_input", {}))[:50]
combined = tool_name + tool_input
tool_hash = hashlib.md5(combined.encode()).hexdigest()[:8]

if tool_hash:
    with LOOP_FILE.open("a", encoding="utf-8") as f:
        f.write(tool_hash + "\n")

    try:
        lines = LOOP_FILE.read_text(encoding="utf-8").splitlines()
        last3 = lines[-3:]
        if len(last3) == 3 and len(set(last3)) == 1:
            print()
            print("🔄 LOOP DETECTED: Same action repeated 3+ times.")
            print("   Stop, reassess, and try a different approach.")
            print("   If stuck: invoke @debugger or @architect-review")

        # Keep loop file lean
        if len(lines) > 20:
            LOOP_FILE.write_text("\n".join(lines[-20:]) + "\n", encoding="utf-8")
    except Exception:
        pass

# ── 2. Session progress summary ───────────────────────────────────────────
try:
    call_num = int(TOOL_LOG.read_text(encoding="utf-8").strip())
except Exception:
    call_num = 0

if call_num >= 10:
    def run(cmd):
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
            return r.stdout.strip()
        except Exception:
            return ""

    staged = len([l for l in run("git diff --cached --name-only").splitlines() if l])
    modified = len([l for l in run("git diff --name-only").splitlines() if l])
    print()
    print(f"── Session: {call_num} tool calls | Staged: {staged} files | Modified: {modified} files ──")

sys.exit(0)
