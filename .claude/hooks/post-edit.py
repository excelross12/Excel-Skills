#!/usr/bin/env python3
"""post-edit.py — Smart git staging + edit tracking + TS type-check.
Fires: PostToolUse on Edit|Write|MultiEdit
"""
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

BMAD_DIR = Path(".bmad")
BMAD_DIR.mkdir(exist_ok=True)

# Read tool input from stdin
try:
    raw = sys.stdin.read()
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    data = {}

# Extract file path from PostToolUse payload
tool_input = data.get("tool_input", data)
file_path_str = (
    tool_input.get("file_path")
    or tool_input.get("path")
    or ""
)

if not file_path_str:
    sys.exit(0)

file_path = Path(file_path_str)
if not file_path.exists():
    sys.exit(0)


def run(cmd, timeout=10):
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=timeout
        )
        return result.stdout.strip(), result.returncode
    except Exception:
        return "", 1


# ── 1. Auto-stage the file ────────────────────────────────────────────────
run(f'git add "{file_path_str}"')

# ── 2. Track edit count (thrash detection) ───────────────────────────────
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
edit_log = BMAD_DIR / "edit-log.jsonl"

with edit_log.open("a", encoding="utf-8") as f:
    f.write(json.dumps({"file": file_path_str, "time": timestamp}) + "\n")

# Count edits to this file this session
try:
    lines = edit_log.read_text(encoding="utf-8").splitlines()
    edit_count = sum(1 for line in lines if f'"file":"{file_path_str}"' in line)
    if edit_count >= 5:
        print(f"⚠️  Edit thrash: {file_path_str} edited {edit_count}x this session — consider architectural review")
except Exception:
    pass

# Keep edit log lean
try:
    lines = edit_log.read_text(encoding="utf-8").splitlines()
    if len(lines) > 200:
        edit_log.write_text("\n".join(lines[-100:]) + "\n", encoding="utf-8")
except Exception:
    pass

# ── 3. TypeScript type-check on .ts/.tsx saves ───────────────────────────
suffix = file_path.suffix.lower()
if suffix in (".ts", ".tsx"):
    tsconfig = Path("tsconfig.json")
    # Search parent dirs for tsconfig
    for parent in [Path("."), Path("src").parent, file_path.parent]:
        if (parent / "tsconfig.json").exists():
            tsconfig = parent / "tsconfig.json"
            break

    if tsconfig.exists():
        ts_out, ts_code = run("npx tsc --noEmit 2>&1", timeout=30)
        if ts_code != 0 and ts_out:
            lines = ts_out.splitlines()[:10]
            print("⚠️  TypeScript errors after edit:")
            print("\n".join(lines))

sys.exit(0)
