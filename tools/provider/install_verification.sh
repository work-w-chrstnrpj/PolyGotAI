#!/usr/bin/env bash
# Switches on online feedback for THIS machine's builds only.
# Writes application/SpeechCoachAI/Resources/ProviderVerification.json (git-ignored, so the workspace id never reaches the public repository).
# You attest to two facts by passing the flags; the app does not check them for you.
#
#   tools/provider/install_verification.sh --workspace <id> --permission-checked --quota-checked [--days 90]
#
# --permission-checked : your Alibaba Cloud account allows this key to call the Singapore workspace directly.
# --quota-checked      : you checked the free quota / spending limit in the console, so a request cannot run up an unexpected bill.
# Remove the file (or let it expire) to switch online feedback off again.
set -euo pipefail
workspace=""; permission=false; quota=false; days=90
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) workspace="$2"; shift 2 ;;
    --permission-checked) permission=true; shift ;;
    --quota-checked) quota=true; shift ;;
    --days) days="$2"; shift 2 ;;
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
python3 - "$out" "$workspace" "$until" <<'PY'
import json, sys, datetime
out, workspace, until = sys.argv[1:4]
doc = {
  "workspace": workspace.strip().lower(),
  "asrModel": "qwen3-asr-flash",
  "coachingModel": "qwen-flash",
  "validUntil": until,
  "directNativePermissionVerified": True,
  "quotaProtectionVerified": True,
  "retentionDisclosure": "Your text or recording is sent to your Alibaba Cloud account with your key. Alibaba's own data terms apply to what they keep.",
  "evidenceReference": "Owner attestation on " + datetime.date.today().isoformat() + " via tools/provider/install_verification.sh",
}
open(out, "w").write(json.dumps(doc, indent=2) + "\n")
print("wrote", out, "valid until", until)
PY
