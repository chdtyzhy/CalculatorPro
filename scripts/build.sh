#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODE_DEVELOPER_DIR="${XCODE_DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [[ ! -d "$XCODE_DEVELOPER_DIR" ]]; then
  echo "Xcode developer directory not found: $XCODE_DEVELOPER_DIR" >&2
  echo "Set XCODE_DEVELOPER_DIR to a valid Xcode Developer directory." >&2
  exit 1
fi

cd "$ROOT_DIR"

DEVELOPER_DIR="$XCODE_DEVELOPER_DIR" xcodebuild \
  -project CalculatorPro.xcodeproj \
  -scheme CalculatorPro \
  -configuration Debug \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build
