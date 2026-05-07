#!/usr/bin/env python3
"""post-bash.py — Error tracking, loop detection, token waste warning.
Fires: PostToolUse on Bash
"""
import json
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

# Extract exit code — Claude Code PostToolUse schema
tool_response = data.get("tool_response", {})
exit_code = (
    tool_response.get("exit_code")
    or data.get("exit_code")
    or 0
)
if isinstance(exit_code, str):
    try:
        exit_code = int(exit_code)
    except ValueError:
        exit_code = 0

# Extract command
tool_input = data.get("tool_input", data)
command = str(tool_input.get("command", ""))[:120]

# ── 1. Log errors to improvement.jsonl ───────────────────────────────────
improvement = BMAD_DIR / "improvement.jsonl"

if exit_code and exit_code != 0:
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    entry = json.dumps({"cmd": command, "exit": exit_code, "time": timestamp})

    with improvement.open("a", encoding="utf-8") as f:
        f.write(entry + "\n")

    # Warn at multiples of 3
    try:
        error_count = len(improvement.read_text(encoding="utf-8").splitlines())
        if error_count >= 3 and error_count % 3 == 0:
            print(f"⚠️  {error_count} bash errors logged this session — consider: @self-improver diagnose")
    except Exception:
        pass

# ── 2. Token waste detection (tool call counter) ──────────────────────────
tool_log = BMAD_DIR / ".tool-count"
try:
    call_num = int(tool_log.read_text(encoding="utf-8").strip())
except Exception:
    call_num = 0

call_num += 1
tool_log.write_text(str(call_num), encoding="utf-8")

if call_num == 20:
    print("💡 20 tool calls in session — consider /save-session if context is getting heavy")
elif call_num == 50:
    print("⚠️  50 tool calls — high context load. Run @agent-memory to save anchors before compaction")

# ── 3. Keep edit log lean ─────────────────────────────────────────────────
edit_log = BMAD_DIR / "edit-log.jsonl"
if edit_log.exists():
    try:
        lines = edit_log.read_text(encoding="utf-8").splitlines()
        if len(lines) > 200:
            edit_log.write_text("\n".join(lines[-100:]) + "\n", encoding="utf-8")
    except Exception:
        pass

sys.exit(0)
