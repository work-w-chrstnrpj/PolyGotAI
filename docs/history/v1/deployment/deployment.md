# Deployment and Operations

> Status: IN_PROGRESS
> SC-T008 unsigned simulator bootstrap exists; no signed artifact, backend, CI/CD pipeline or production environment exists.

## Targets and candidate delivery

Native iPhone/iPad and iOS/iPadOS 17+ are confirmed. Signing team, bundle ID and distribution remain undecided. Local Xcode/device delivery followed by TestFlight is a candidate, not an approved or configured release path. BYOK provider and native-client compatibility require verification; select runtime/host only if a capability actually needs service infrastructure.

## Required decisions and operational readiness

| Area | Required before delivery |
| --- | --- |
| App | Selected stack, OS/device support, signing, bundle identity, repeatable build/archive commands |
| Online AI | Provider contract, protected credentials, auth/quotas, cost limits, timeout/retry and retention |
| Content | Versioned curriculum packaging, editorial approval and compatibility |
| Data | Local protection, optional audio retention, deletion/export and migration/backup strategy |
| Quality | Automated checks plus owner device, audio and accessibility acceptance |
| Distribution | Beta audience, privacy disclosures, store requirements and release/rollback plan |

Learner-supplied provider secrets belong in Apple Keychain, never ordinary settings, learner databases, exports or logs. Never bundle developer-owned provider credentials. No backend key custody is approved. No environment-variable names are selected. Monitoring should minimize sensitive payloads; measure failures, latency and cost without storing private speech content in logs.

## Candidate smoke checks

Launch on both device classes; complete offline lesson/vocabulary review; record and replay; request online feedback; simulate connectivity/provider failure; reopen without losing permitted local progress; verify baseline retention preference and duplicate-reward prevention.

## Recovery and rollback requirements

Before first release, document known-good artifact recovery, data-compatible rollback, migration recovery without an automatic learner-data backup and service shutdown behavior. Do not prescribe reinstalling or deleting learner data as recovery. No current deployment, rollback or migration commands can be executed.

Realtime transport operations, synchronization and multi-language distribution are deferred.

## BYOK operational boundary

No developer-funded AI account or hosted broker is assumed. Configure real-provider checks through secure app settings, never pasted keys in docs or terminal commands. Verify provider compatibility, capability discovery, key deletion and nonsecret failure diagnostics. If service infrastructure becomes necessary, its operating costs and key-handling policy require explicit scope decisions. BYOK does not settle App Store distribution, app pricing or third-party content licenses.

## Development trial operating plan

Qwen/Alibaba Cloud Model Studio is the first development evaluation ecosystem. Follow the [trial checklist](../development-plan/approved-recommendations.md#qwen-development-evaluation) to verify account-specific model/region allowance, units/expiry and provider Free Quota Only protection before calls. Do not assume one-million tokens applies to every speech model or covers storage services. Trial availability is not a production cost guarantee; no accounts/keys/models have been configured.

## First-slice decisions and environment — 2026-10-21

Selected native Swift/SwiftUI with minimum iOS/iPadOS 17; local-only SwiftData/AVFAudio/URLSession/Keychain. No backend, sync or backup service. All learner data requests exclusion from Apple device backups; manual exports are explicit and not a first-proof UI deliverable. No protected-data or device recovery result is claimed. Current provider candidate and account/terms/quota gates are in the Qwen report.

Read-only inspection found Xcode 27.0 (27A266a) at /Applications/Xcode.app, while the active developer directory points to CommandLineTools. Per-command DEVELOPER_DIR allowed version/simulator/device listing; no global setting changed. iOS 27 simulators available; minimum-OS runtime unavailable in the listing. Registered iPad (A16) currently unavailable; no physical iPhone shown. Actual test-device OS, signing team/bundle ID/certificate/profile and distribution path are unverified. SC-T008 must confirm these before physical delivery; SC-T042 retains release choices. No signing access, installation or account changes were performed. Development remains expressly unauthorized.

## Curriculum delivery decision — 2026-10-21

SC-T005 selects bundle-first reviewed content and required local reference assets, shipped via app updates. No CDN, download manager or content backend selected. SC-T019 must record real pack sizes/integrity/compatibility and SC-T020 verify first-launch airplane-mode completion. Missing review/assets cannot be advertised available. SC-T006 is owner-approved without a qualified educator review. SC-T007 design-input review is complete. Native/device acceptance remains open under delivery tickets. No app/distribution work authorized.

## SC-T008 delivery boundary — 2026-10-21

Owner started implementation. Simulator build/test uses `tools/native/verify.sh` and provisional `org.example.SpeechCoachAI`; this is not an adopted signing/distribution identifier. No development team/profile/entitlements are configured. Owner test target: iPhone 15 Plus on iOS 27 (owner-reported, not connected/verified). Registered physical iPad (A16) is unavailable; no physical iPhone appeared in devicectl listing. Confirm bundle ID, signing team, connected device and actual OS before signed delivery. Minimum-OS runtime is absent. Physical launch, release/archive, TestFlight and distribution remain NOT_RUN.


## Physical connection recheck — 2026-10-21

After owner connected the phone, `devicectl` confirmed a paired wired iPhone 15 Plus running iOS 27.0.1 (24A446). Developer Mode is disabled, which prevents the development launch check. The registered iPad also now appears available/paired; no iPad install was requested in this follow-up. One valid local Apple Development signing identity is available, but app bundle/profile configuration remains pending. No private key material was read, provisioning/account changes made, or app installed. Next action: owner enables Developer Mode on the iPhone, restarts and confirms the prompt; then resume signing/build/install verification.

## Signed development installation — 2026-10-21

SC-T008 installed/launched `com.personal.SpeechCoachAI` on owner iPhone 15 Plus, iOS 27.0.1/24A446 after owner enabled Developer Mode and trusted the profile. Existing Apple Development identity used with per-command team configuration; no private key exported. Automatic provisioning produced a device-including development profile expiring 2026-10-28. Development updates retain this app identity; no release/store publication. Keep device unlocked during Xcode execution. On 2026-10-21 the same development signing installed and launched UI checks on a wired iPad (A16), iPadOS 27.0.1. Minimum-OS checks remain outstanding. SC-T009 opens protected local state; failures preserve existing data and require retry, never reinstall/reset.
