#!/usr/bin/env bash
# Prints Markdown release notes for the commits in <from-ref>..<to-ref>,
# grouped by Conventional Commit type.
#
# Usage: release-notes.sh <from-ref> <to-ref> <new-tag> [previous-tag]
#   An empty from-ref lists the whole history (first release).
# Optional env: REPO (owner/name) for links, PR_NUMBER, PR_TITLE, PR_BODY.
set -euo pipefail

from_ref="$1"
to_ref="$2"
new_tag="$3"
prev_tag="${4:-}"
repo="${REPO:-}"

breaking="" feat="" fix="" perf="" refactor="" docs="" test="" chore="" other=""

# One record per commit: sha, subject, body, separated by unit/record separators.
while IFS=$'\x1f' read -r -d $'\x1e' sha subject body; do
  sha="${sha#$'\n'}"
  short="${sha:0:7}"
  if [[ -n "$repo" ]]; then ref="[\`$short\`](https://github.com/$repo/commit/$sha)"; else ref="\`$short\`"; fi

  type="" scope="" bang="" text="$subject"
  if [[ "$subject" =~ ^([a-zA-Z]+)(\(([^\)]*)\))?(!)?:[[:space:]]*(.*)$ ]]; then
    type="$(tr '[:upper:]' '[:lower:]' <<<"${BASH_REMATCH[1]}")"
    case "$type" in
      feat|fix|perf|refactor|style|docs|test|chore|ci|build)
        scope="${BASH_REMATCH[3]}"
        bang="${BASH_REMATCH[4]}"
        text="${BASH_REMATCH[5]}"
        ;;
      *) type="" ;;
    esac
  fi
  text="$(tr '[:lower:]' '[:upper:]' <<<"${text:0:1}")${text:1}"
  [[ -n "$scope" ]] && text="**$scope:** $text"
  line="- $text ($ref)"$'\n'

  if [[ -n "$bang" || "$body" == *"BREAKING CHANGE"* ]]; then breaking+="$line"; fi
  case "$type" in
    feat) feat+="$line" ;;
    fix) fix+="$line" ;;
    perf) perf+="$line" ;;
    refactor|style) refactor+="$line" ;;
    docs) docs+="$line" ;;
    test) test+="$line" ;;
    chore|ci|build) chore+="$line" ;;
    *) other+="$line" ;;
  esac
done < <(git log --no-merges --reverse --format='%H%x1f%s%x1f%b%x1e' "${from_ref:+$from_ref..}$to_ref")

section() { [[ -n "$2" ]] && printf '### %s\n\n%s\n' "$1" "$2"; return 0; }

if [[ -n "${PR_TITLE:-}" ]]; then
  printf '%s' "${PR_TITLE}"
  [[ -n "${PR_NUMBER:-}" ]] && printf ' (#%s)' "$PR_NUMBER"
  printf '\n\n'
fi
if [[ -n "${PR_BODY:-}" ]]; then
  printf '%s\n\n' "$PR_BODY"
fi

section "⚠️ Breaking changes" "$breaking"
section "✨ Features" "$feat"
section "🐛 Fixes" "$fix"
section "⚡ Performance" "$perf"
section "♻️ Refactoring" "$refactor"
section "📝 Documentation" "$docs"
section "🧪 Tests" "$test"
section "🔧 Maintenance" "$chore"
section "📦 Other changes" "$other"

if [[ -z "$breaking$feat$fix$perf$refactor$docs$test$chore$other" ]]; then
  printf '_No new commits since the previous release._\n\n'
fi

if [[ -n "$repo" ]]; then
  if [[ -n "$prev_tag" ]]; then
    printf '**Full changelog:** https://github.com/%s/compare/%s...%s\n' "$repo" "$prev_tag" "$new_tag"
  else
    printf '**Full changelog:** https://github.com/%s/commits/%s\n' "$repo" "$new_tag"
  fi
fi
