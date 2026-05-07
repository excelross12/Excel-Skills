#!/usr/bin/env python3
"""user-prompt-submit.py — Memory recall injection + skill activation hints.
Fires: UserPromptSubmit lifecycle event
"""
import json
import sys
from pathlib import Path

BMAD_DIR = Path(".bmad")
ANCHORS = BMAD_DIR / "anchors.json"
LAST_SESSION = BMAD_DIR / "last-session.md"

# Read input from stdin
try:
    raw = sys.stdin.read()
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    data = {}

prompt = data.get("prompt", "").lower()[:300]

# ── 1. Inject active anchor count ────────────────────────────────────────
if ANCHORS.exists():
    try:
        anchors = json.loads(ANCHORS.read_text(encoding="utf-8"))
        count = len(anchors)
        if count > 0:
            keys = list(anchors.keys())[:3]
            key_str = " §".join(keys)
            print(f"[Memory: {count} anchors — §{key_str}]")
    except Exception:
        pass

# ── 2. Detect continuation prompts ───────────────────────────────────────
continuation_words = ["continue", "resume", "pick up", "where we left", "carry on", "keep going"]
if any(w in prompt for w in continuation_words) and LAST_SESSION.exists():
    lines = LAST_SESSION.read_text(encoding="utf-8").splitlines()[:20]
    print()
    print("📎 Continuation detected — loading last session handoff:")
    print("\n".join(lines))
    print()

# ── 3. Skill routing hints ────────────────────────────────────────────────
hints = []

if any(w in prompt for w in ["bug", "error", "not working", "broken", "failing", "crash", "exception"]):
    hints.append("🔧 @debugger — systematic root-cause analysis")

if any(w in prompt for w in ["commit", "push", "branch", "merge", "pr", "pull request"]):
    hints.append("📦 git-flow skill — conventional commits + branch hygiene")

if any(w in prompt for w in ["test", "playwright", "e2e", "spec", "coverage", "flaky"]):
    hints.append("🧪 webapp-testing-suite — Playwright TDD-E2E workflow")
    hints.append("🎭 playwright-best-practices — activity-based reference")

if any(w in prompt for w in ["ui", "component", "design", "layout", "style", "css", "tailwind"]):
    hints.append("🎨 frontend-design-pro — 5-state components + WCAG AA")

if any(w in prompt for w in ["api", "endpoint", "database", "migration", "auth", "backend"]):
    hints.append("⚙️ backend-engineering — contract-first + 4-layer security")

if any(w in prompt for w in ["memory", "anchor", "session", "context", "handoff", "save"]):
    hints.append("🧠 agent-memory — anchor system + TTL management")

if any(w in prompt for w in ["brainstorm", "approach", "ideas", "options", "how should", "what could"]):
    hints.append("💡 brainstorm-deep — 7+ options + structured recommendation")

if any(w in prompt for w in ["summarize", "compress", "tl;dr", "too long", "distill"]):
    hints.append("📄 distillator — token-efficient summaries")

if hints:
    print()
    print("Skills that may help:")
    for h in hints[:3]:
        print(f"  {h}")

sys.exit(0)
