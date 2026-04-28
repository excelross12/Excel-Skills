#!/usr/bin/env bash
# smart-commit — runs PostToolUse on Edit|Write
# Auto-STAGES changes only. Never auto-commits (prevents git log spam).
# To commit: run /commit in the IDE or `git commit` manually.
# Full commit with conventional message fires from git-flow skill on explicit request.

FILE="$CLAUDE_TOOL_FILE_PATH"
[ -z "$FILE" ] && exit 0

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Stage only — no commit
git add "$FILE" 2>/dev/null || exit 0

exit 0
