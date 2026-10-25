#!/bin/bash
set -euo pipefail

# Run from any working directory. Pass an available iOS simulator UUID.
if [[ $# -ne 1 ]]; then
    echo "Usage: bash tools/native/verify.sh SIMULATOR_UUID" >&2
    exit 2
fi
project_root="$(cd "$(dirname "$0")/../.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
result_root="$project_root/application/.build/verification"
mkdir -p "$result_root"
run_dir="$(mktemp -d "$result_root/run-XXXXXX")"
echo "Verification artifacts: $run_dir"
xcodebuild -list -project "$project_root/application/SpeechCoachAI.xcodeproj" > "$run_dir/project.txt"
test_status=0
xcodebuild test \
    -project "$project_root/application/SpeechCoachAI.xcodeproj" \
    -scheme SpeechCoachAI \
    -destination "platform=iOS Simulator,id=$1" \
    -derivedDataPath "$project_root/application/.build/DerivedData" \
    -resultBundlePath "$run_dir/tests.xcresult" \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- > "$run_dir/test.log" 2>&1 || test_status=$?
# Keep a machine-readable failure summary too; a failing test must not skip evidence collection.
summary_status=1
if [[ -d "$run_dir/tests.xcresult" ]]; then
    summary_status=0
    xcrun xcresulttool get test-results summary --path "$run_dir/tests.xcresult" > "$run_dir/summary.json" || summary_status=$?
fi
if [[ $test_status -ne 0 ]]; then
    tail -n 60 "$run_dir/test.log" >&2
    exit "$test_status"
fi
if [[ $summary_status -ne 0 ]]; then
    echo "Test summary could not be read: $run_dir/tests.xcresult" >&2
    exit "$summary_status"
fi
cat "$run_dir/summary.json"
