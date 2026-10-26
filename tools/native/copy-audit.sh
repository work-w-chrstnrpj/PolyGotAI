#!/bin/bash
# Fails when app screen text explains what the app can't do (AGENTS.md UI rules).
# Scans string literals in app Swift files; comments, DEBUG fixtures and tests are skipped.
set -euo pipefail

project_root="$(cd "$(dirname "$0")/../.." && pwd)"
app="$project_root/application/SpeechCoachAI"

# Real one-sentence error messages may say "unavailable"; these phrases are never allowed on screen.
banned=(
    "not available"
    "not scored"
    "not assessed"
    "not a level"
    "English level"
    "English-level"
    "level placement"
    "coming later"
    "coming soon"
    "not an improvement"
    "is not speech"
    "not a score"
    "not yet supported"
    "Lesson unavailable"
    "Progress is unavailable"
)

pattern=$(IFS='|'; echo "${banned[*]}")
hits=$(
    find "$app" -name '*.swift' ! -name 'Round4FixtureView.swift' -print0 |
    xargs -0 grep -n -i -E "\"[^\"]*($pattern)[^\"]*\"" |
    grep -v -E '^[^:]+:[0-9]+:[[:space:]]*//' |
    grep -v -E 'accessibilityIdentifier\("[^"]*"\)$' |
    grep -v -E '(Error|Refusal|case |enum |rawValue|forKey|identifier|\.unavailable)[^"]*"[^"]*"[^"]*$' |
    grep -v -i 'copy-audit: allow' || true
)

if [[ -n "$hits" ]]; then
    echo "Copy audit failed: screen text explains what the app can't do." >&2
    echo "$hits" | sed "s|$project_root/||" >&2
    echo "Hide the feature instead, or mark a non-screen string with '// copy-audit: allow'." >&2
    exit 1
fi
echo "Copy audit passed."
