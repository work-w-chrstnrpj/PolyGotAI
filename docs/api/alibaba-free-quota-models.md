# Alibaba Cloud model priorities

The [model catalog](alibaba-free-quota-models.json) provides suggested model IDs and order for the Singapore region. Check model access, the available allowance and Stop-on-Exhaust (Free Only) in your [Model Studio console](https://modelstudio.console.alibabacloud.com/ap-southeast-1/costing-balance/free-quota) before installing the local verification file. Allowance, expiry and enabled models depend on the account.

## Suggested priority by job

Try the first model; on `AllocationQuota.FreeTierOnly` move to the next. Edit the lists in the JSON file to change the order.

- **text-chat-json:** `qwen-flash` → `qwen3.5-flash` → `qwen3.6-flash` → `qwen3.7-flash` → `qwen3.8-flash` → `qwen-flash-2025-07-28` → `qwen-plus` → `qwen3.5-plus` → `qwen3.6-plus` → `qwen3.7-plus` → `qwen-plus-latest` → `qwen-max` → `qwen3.7-max`
- **speech-to-text-short:** `qwen3-asr-flash` → `qwen-audio-3.0-asr-flash` → `qwen-audio-3.1-asr-flash` → `fun-asr-flash-2026-06-15`
- **speech-to-text-realtime:** `qwen3-asr-flash-realtime` → `qwen-audio-3.1-asr-flash-streaming` → `qwen-audio-3.0-asr-flash-streaming` → `fun-asr-realtime`
- **text-to-speech:** `qwen3-tts-flash` → `qwen-audio-3.0-tts-flash` → `qwen-audio-3.1-tts-flash` → `cosyvoice-v3-flash` → `cosyvoice-v3-plus`
- **translation:** `qwen-mt-flash` → `qwen-mt-lite` → `qwen-mt-plus`
- **embedding:** `text-embedding-v4` → `text-embedding-v3` → `qwen3.7-text-embedding`
