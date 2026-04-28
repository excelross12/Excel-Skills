#!/usr/bin/env bash
# smart-formatting — runs PostToolUse on Edit|MultiEdit|Write
# Formats by file type; never blocks (always exit 0)

FILE="$CLAUDE_TOOL_FILE_PATH"
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx|*.json|*.css|*.html|*.md|*.yml|*.yaml)
    npx --no-install prettier --write "$FILE" 2>/dev/null || true
    ;;
  *.py)
    black "$FILE" 2>/dev/null || ruff format "$FILE" 2>/dev/null || true
    ;;
  *.go)
    gofmt -w "$FILE" 2>/dev/null || true
    ;;
  *.rs)
    rustfmt "$FILE" 2>/dev/null || true
    ;;
  *.java|*.kt)
    google-java-format -i "$FILE" 2>/dev/null || ktlint -F "$FILE" 2>/dev/null || true
    ;;
  *.swift)
    swiftformat "$FILE" 2>/dev/null || true
    ;;
  *.dart)
    dart format "$FILE" 2>/dev/null || true
    ;;
  *.php)
    php-cs-fixer fix "$FILE" 2>/dev/null || true
    ;;
  *.sh)
    shfmt -w "$FILE" 2>/dev/null || true
    ;;
esac

exit 0
