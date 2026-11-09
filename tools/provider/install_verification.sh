#!/usr/bin/env bash
# Switches on online feedback for THIS machine's builds only.
# Writes application/SpeechCoachAI/Resources/ProviderVerification.json (git-ignored, so the workspace id never reaches the public repository).
# You attest to two facts by passing the flags; the app does not check them for you.
#
#   tools/provider/install_verification.sh --workspace <id> --permission-checked --quota-checked [--days 90]
#       [--coaching-models qwen-flash,qwen3.5-flash,...] [--asr-models qwen3-asr-flash,...]
#
# The model lists are tried in order; a model moves the request on only when its free quota runs out (ADR-0013).
# Without the flags they come from the "priority" lists in docs/api/alibaba-free-quota-models.json.
#
# --permission-checked : your Alibaba Cloud account allows this key to call the Singapore workspace directly.
# --quota-checked      : you turned on Stop-on-Exhaust (Free Only) for every listed model, so a request cannot run up a bill.
# Remove the file (or let it expire) to switch online feedback off again.
set -euo pipefail
workspace=""; permission=false; quota=false; days=90; coaching=""; asr=""
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) workspace="$2"; shift 2 ;;
    --permission-checked) permission=true; shift ;;
    --quota-checked) quota=true; shift ;;
    --days) days="$2"; shift 2 ;;
    --coaching-models) coaching="$2"; shift 2 ;;
    --asr-models) asr="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done
[ -n "$workspace" ] || { echo "--workspace is required" >&2; exit 2; }
$permission && $quota || { echo "Pass both --permission-checked and --quota-checked after checking them yourself." >&2; exit 2; }
root="$(cd "$(dirname "$0")/../.." && pwd)"
out="$root/application/SpeechCoachAI/Resources/ProviderVerification.json"
until="$(python3 - "$days" <<'PY'
import sys, datetime
print((datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=int(sys.argv[1]))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
)"
python3 - "$out" "$workspace" "$until" "$coaching" "$asr" "$root/docs/api/alibaba-free-quota-models.json" <<'PY'
import json, re, sys, datetime
out, workspace, until, coaching, asr, catalog = sys.argv[1:7]
priority = json.load(open(catalog))["priority"]
def models(given, job):
    names = [m.strip().lower() for m in given.split(",") if m.strip()] if given else priority[job]
    bad = [m for m in names if not re.fullmatch(r"[a-z0-9][a-z0-9._-]{0,63}", m)]
    if not names or bad or len(set(names)) != len(names) or len(names) > 32:
        sys.exit(f"Invalid {job} model list: {names}")
    return names
doc = {
  "workspace": workspace.strip().lower(),
  "asrModels": models(asr, "speech-to-text-short"),
  "coachingModels": models(coaching, "text-chat-json"),
  "validUntil": until,
  "directNativePermissionVerified": True,
  "quotaProtectionVerified": True,
  "retentionDisclosure": "Your text or recording is sent to your Alibaba Cloud account with your key. Alibaba's own data terms apply to what they keep.",
  "evidenceReference": "Owner attestation on " + datetime.date.today().isoformat() + " via tools/provider/install_verification.sh",
}
open(out, "w").write(json.dumps(doc, indent=2) + "\n")
print("wrote", out, "valid until", until)
print("coaching:", " > ".join(doc["coachingModels"]))
print("speech-to-text:", " > ".join(doc["asrModels"]))
PY
