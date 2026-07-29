#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/CalculatorPro.xcodeproj/project.pbxproj"
INFO_PLIST="$ROOT_DIR/CalculatorPro/Resources/Info.plist"
XCODE_DEVELOPER_DIR="${XCODE_DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR="$XCODE_DEVELOPER_DIR"

cd "$ROOT_DIR"

git diff --check
plutil -lint "$INFO_PLIST"

mapfile_versions() {
  sed -n 's/^[[:space:]]*MARKETING_VERSION = \([^;]*\);/\1/p' "$PROJECT_FILE" | sort -u
}

mapfile_builds() {
  sed -n 's/^[[:space:]]*CURRENT_PROJECT_VERSION = \([^;]*\);/\1/p' "$PROJECT_FILE" | sort -u
}

marketing_versions="$(mapfile_versions)"
build_numbers="$(mapfile_builds)"

if [[ ! "$marketing_versions" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "MARKETING_VERSION must be one consistent three-part numeric version; found: $marketing_versions" >&2
  exit 1
fi

if [[ ! "$build_numbers" =~ ^[1-9][0-9]*$ ]]; then
  echo "CURRENT_PROJECT_VERSION must be one consistent positive integer; found: $build_numbers" >&2
  exit 1
fi

bundle_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
if [[ "$bundle_version" != '$(MARKETING_VERSION)' ]]; then
  echo "CFBundleShortVersionString must reference \$(MARKETING_VERSION); found: $bundle_version" >&2
  exit 1
fi

echo "Metadata validation passed: version=$marketing_versions build=$build_numbers"
"$ROOT_DIR/scripts/build.sh"

simulator_id="$(
  DEVELOPER_DIR="$XCODE_DEVELOPER_DIR" xcrun simctl list devices available |
    sed -n '/iPhone/ s/.*(\([0-9A-F-]\{36\}\)).*/\1/p' |
    head -n 1
)"

if [[ -z "$simulator_id" ]]; then
  echo "No available iPhone Simulator found." >&2
  exit 1
fi

DEVELOPER_DIR="$XCODE_DEVELOPER_DIR" xcodebuild \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO \
  test
