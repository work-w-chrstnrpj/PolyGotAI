#!/usr/bin/env bash
# Prints the next release version (without the leading "v").
#
# Usage: next-version.sh <from-ref> <to-ref>
#   from-ref  main before the merge (commits already released)
#   to-ref    development head that was merged
#
# Rules:
#   - No earlier v* tag: use MARKETING_VERSION from the Xcode project.
#   - Otherwise bump the latest tag from the merged commit subjects:
#     breaking change (type!: or "BREAKING CHANGE") -> major (minor while 0.x),
#     feat -> minor, anything else -> patch.
#   - If MARKETING_VERSION was raised above that result by hand, it wins.
set -euo pipefail

from_ref="$1"
to_ref="$2"
pbxproj="application/SpeechCoachAI.xcodeproj/project.pbxproj"

marketing="$(grep -o 'MARKETING_VERSION = [0-9][0-9.]*' "$pbxproj" | head -1 | awk '{print $3}')"
marketing="${marketing:-0.1.0}"
latest_tag="$(git tag -l 'v[0-9]*' --sort=-v:refname | head -1)"

if [[ -z "$latest_tag" ]]; then
  echo "$marketing"
  exit 0
fi

IFS=. read -r major minor patch <<<"${latest_tag#v}"
patch="${patch:-0}"

log="$(git log --no-merges --format='%s%n%b' "$from_ref..$to_ref")"
if grep -Eq '^[a-zA-Z]+(\([^)]*\))?!:|BREAKING CHANGE' <<<"$log"; then
  if [[ "$major" == 0 ]]; then minor=$((minor + 1)); patch=0
  else major=$((major + 1)); minor=0; patch=0; fi
elif grep -Eq '^feat(\([^)]*\))?:' <<<"$log"; then
  minor=$((minor + 1)); patch=0
else
  patch=$((patch + 1))
fi
bumped="$major.$minor.$patch"

highest="$(printf '%s\n%s\n' "$bumped" "$marketing" | sort -V | tail -1)"
echo "$highest"
