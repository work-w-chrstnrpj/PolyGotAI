# SC-T012 local credentials checkpoint — 2026-10-21

Status: **in_progress**. Local credential handling is implemented and verified. Authorized live requests, account/terms/quota/retention prerequisites, locked-access verification and remaining dependency acceptance are open. No provider request, provider account change or real key entry occurred.

## Implementation

`Infrastructure/Credentials/ProviderCredentialStore.swift` stores generic-password credentials with WhenUnlockedThisDeviceOnly and synchronization false, scoped by fixed application service and Singapore/workspace account. Workspace is a validated DNS label; the endpoint is constructed from a fixed documented HTTPS suffix/path, never an arbitrary URL. Existing credentials are updated in place; failed input/scope validation preserves the old value. Workspace changes require explicit local removal. Keychain attribute queries supply saved-state UI without loading key bytes. Generic errors contain no key/SDK payload. No learner database/files/export changes store secrets.

`Features/Settings/ProviderSettingsView.swift` provides SecureField, local add/replace/remove confirmation, clears unsaved keys on background/leaving, and distinguishes saved from verified. Billing/local-removal/privacy disclosures are native text. There is no connection-check/upload action while live prerequisites remain unresolved. The screen adapts T10 settings using native Form/system states and existing Kit colors; no new art/Figma writes. [Physical screenshot](provider-settings-phone.png) visually inspected; broader native accessibility remains separate.

## Actual verification

- Owner iPhone 15 Plus, iOS 27.0.1: **PASS**, `application/.build/provider-credential-device.xcresult`. Hosted test run: 30 functions, 5 suites including parameterized hostile-input cases. Provider lifecycle exercises unique test service and synthetic key values only: add/query/replace/remove, accessibility/nonsync attributes, invalid replacement preservation, workspace-switch rejection and idempotent deletion. UI test confirms masked key field, workspace field and no live connection button. [Summary](iphone-summary.json).
- Signed iPhone simulator: **PASS**, `application/.build/provider-credential-simulator-signed.xcresult`, three provider test functions including 11 workspace rejection cases. [Summary](signed-simulator-summary.json).
- Initial unsigned simulator run failed Keychain access with the sanitized unavailable error. The same test passed with simulator ad-hoc signing (`CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-`). No production protection policy was weakened to make the test pass. `tools/native/verify.sh` now uses these simulator signing settings. The full script retains the known unresolved iPad contrast finding; it is not claimed fully green.
- New credential UI does not offer any HTTP transport. No URLSession/provider request was made. No real credentials were read or logged. Keychain fixtures use distinct random test services, not the production credential service.

## Before live calls

Verify account-applicable International/Singapore direct-native/BYOK permission, actual workspace/model access, effective Free Quota Only protection plus allowance/expiry, current processing/retention disclosure, and explicit per-stage learner submission. No user key is needed until those gates and the request implementation are ready. Do not infer provider validity, quota or connectivity from a saved-key indicator.

SC-T010 retains an unidentified iPad Today contrast audit finding and manual accessibility scope; SC-T011 retains physical iPad, route/lock/cap and remaining RF acceptance. Their open status is not waived by local credential preparation.
