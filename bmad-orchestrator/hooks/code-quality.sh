#!/usr/bin/env bash
# code-quality — runs PostToolUse on Write|Edit|MultiEdit (TS/JS/Next.js focus)
# Exit 2 = blocking. Other exits = informational.

INPUT=$(cat 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
SUCCESS=$(echo "$INPUT" | jq -r '.tool_response.success // false' 2>/dev/null)

# Fallback to env if jq input missing
[ -z "$FILE_PATH" ] && FILE_PATH="$CLAUDE_TOOL_FILE_PATH"

# Skip non-JS/TS or failed ops
if [ "$SUCCESS" != "true" ] && [ -z "$CLAUDE_TOOL_FILE_PATH" ]; then exit 0; fi
[[ ! "$FILE_PATH" =~ \.(js|jsx|ts|tsx)$ ]] && exit 0
[[ "$FILE_PATH" =~ node_modules ]] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

ISSUES=0

# Next.js App Router checks
if [[ "$FILE_PATH" =~ app/.* ]]; then
  if [[ "$FILE_PATH" =~ page\.(js|jsx|ts|tsx)$ ]]; then
    if ! grep -qE "export default (async )?function" "$FILE_PATH" 2>/dev/null; then
      echo "❌ Page must export default function: $FILE_PATH" >&2
      ((ISSUES++))
    fi
  fi
  if [[ "$FILE_PATH" =~ layout\.(js|jsx|ts|tsx)$ ]]; then
    if ! grep -q "children" "$FILE_PATH" 2>/dev/null; then
      echo "❌ Layout must accept children prop: $FILE_PATH" >&2
      ((ISSUES++))
    fi
  fi
  # Server vs Client component sanity
  if grep -q "use client" "$FILE_PATH" 2>/dev/null; then
    if ! grep -qE "(useState|useEffect|onClick|onChange|onSubmit|useRef)" "$FILE_PATH" 2>/dev/null; then
      echo "⚠️ 'use client' with no interactivity — consider Server Component"
    fi
  else
    if grep -qE "(useState|useEffect|onClick|onChange|onSubmit)" "$FILE_PATH" 2>/dev/null; then
      echo "❌ Interactivity in Server Component — add 'use client': $FILE_PATH" >&2
      ((ISSUES++))
    fi
  fi
fi

# Image / Link best practice
if grep -q "<img" "$FILE_PATH" 2>/dev/null && ! grep -q "next/image" "$FILE_PATH" 2>/dev/null; then
  echo "💡 Use next/image for optimization in $FILE_PATH"
fi

# Console.log leaks
if grep -qE "console\.(log|debug)" "$FILE_PATH" 2>/dev/null; then
  echo "⚠️ console.log/debug found — remove before commit: $FILE_PATH"
fi

# Type assertions hiding errors
if grep -qE "(as any\b|: any\b)" "$FILE_PATH" 2>/dev/null; then
  echo "⚠️ 'any' type used — narrow before merge: $FILE_PATH"
fi

# Run tsc + eslint if config present
if [ -f "tsconfig.json" ]; then
  npx --no-install tsc --noEmit 2>&1 | head -20 >&2 || true
fi
if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] || [ -f "eslint.config.js" ]; then
  npx --no-install eslint "$FILE_PATH" 2>&1 | head -20 >&2 || true
fi

[ $ISSUES -gt 0 ] && exit 2
exit 0
