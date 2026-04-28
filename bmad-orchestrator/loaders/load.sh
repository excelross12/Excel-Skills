#!/usr/bin/env bash
# load.sh — One-click loader for macOS / Linux
# Usage:
#   ./load.sh                          # interactive
#   ./load.sh --ide cursor             # direct
#   ./load.sh --auto                   # auto-detect
#   ./load.sh --list                   # list IDEs
#   ./load.sh --add-ide <name>         # scaffold new IDE template
#   ./load.sh --target <path>          # target project dir

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOADER_PY="$SCRIPT_DIR/load.py"

if [ ! -f "$LOADER_PY" ]; then
  echo "❌ load.py not found at $LOADER_PY" >&2
  exit 1
fi

PY_CMD=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then
    PY_CMD="$cand"
    break
  fi
done

if [ -z "$PY_CMD" ]; then
  echo "❌ Python not found. Install Python 3.10+ and re-run." >&2
  exit 1
fi

exec "$PY_CMD" "$LOADER_PY" "$@"
