#!/usr/bin/env python3
"""One manual check that your Alibaba Cloud key and workspace answer the way the app expects. NOT run by tests or by the app.

Run it yourself (it makes ONE paid-quota request with synthetic text and prints no key and no reply text):

    DASHSCOPE_API_KEY=sk-... python3 tools/provider/live_check.py --workspace <your-workspace-id>

It sends a tiny chat-completions request to qwen-flash in JSON mode and checks the reply envelope the app parses.
"""
import argparse, json, os, sys, urllib.error, urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("--workspace", required=True)
args = parser.parse_args()
key = os.environ.get("DASHSCOPE_API_KEY", "")
if not key:
    sys.exit("Set DASHSCOPE_API_KEY in the environment (it is never printed).")
url = f"https://{args.workspace.strip().lower()}.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1/chat/completions"
body = {"model": "qwen-flash", "stream": False, "enable_thinking": False, "response_format": {"type": "json_object"},
        "messages": [{"role": "system", "content": "Return only a JSON object with the keys ok (true) and word (the learner word)."},
                     {"role": "user", "content": json.dumps({"learnerText": "practice"})}]}
request = urllib.request.Request(url, data=json.dumps(body).encode(), method="POST",
                                 headers={"Content-Type": "application/json", "Authorization": "Bearer " + key})
try:
    with urllib.request.urlopen(request, timeout=45) as response:
        status, payload = response.status, json.load(response)
except urllib.error.HTTPError as error:
    sys.exit(f"HTTP {error.code}: 401/403 = wrong key or region, 402/429 = quota or rate limit.")
except Exception as error:  # noqa: BLE001
    sys.exit(f"Request failed: {type(error).__name__}")
choice = (payload.get("choices") or [{}])[0]
checks = {
    "status 200": status == 200,
    "model is qwen-flash": payload.get("model") == "qwen-flash",
    "one choice, index 0": len(payload.get("choices", [])) == 1 and choice.get("index") == 0,
    "finish_reason stop": choice.get("finish_reason") == "stop",
    "assistant message": (choice.get("message") or {}).get("role") == "assistant",
}
try:
    json.loads((choice.get("message") or {}).get("content", ""))
    checks["content is JSON"] = True
except ValueError:
    checks["content is JSON"] = False
for name, ok in checks.items():
    print(("PASS " if ok else "FAIL ") + name)
sys.exit(0 if all(checks.values()) else 1)
