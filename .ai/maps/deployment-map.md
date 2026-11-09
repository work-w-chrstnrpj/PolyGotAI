# PolyGotAI Deployment Map

Local Xcode builds to the simulator and the owner's devices. No TestFlight or App Store yet.

- Release on merge of `development` into `main` → `.github/workflows/release.yml`, `.github/scripts/` (ADR-0007)
- Build and run all tests → `tools/native/verify.sh <simulator-uuid>`
- Xcode project and scheme `SpeechCoachAI` → `application/SpeechCoachAI.xcodeproj`
- App icon source → `application/SpeechCoachAI/Resources/PolyGotAI.icon`, `assets/branding/polygotai/`
- Docs → `docs/deployment/deployment.md`
