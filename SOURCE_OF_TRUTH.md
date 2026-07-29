# CalculatorPro Sources Of Truth

This file defines which artifacts are authoritative so humans and AI agents do
not maintain conflicting copies.

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Cross-agent coding rules | `AGENTS.md` | `CLAUDE.md` and `GEMINI.md` are thin import bridges. |
| App source | `CalculatorPro/` | Follow the feature and common-layer boundaries. |
| Xcode project | `CalculatorPro.xcodeproj/project.pbxproj` | The `project.pbxproj.backup*` files are historical only. |
| Marketing version | `MARKETING_VERSION` in the app target build settings | Must use three numeric components. |
| Build number | `CURRENT_PROJECT_VERSION` in the app target build settings | Must be a positive integer. |
| Bundle marketing version | `CalculatorPro/Resources/Info.plist` | Must reference `$(MARKETING_VERSION)`. |
| App Store metadata and review notes | `APP_STORE_METADATA.md` | Must describe only functionality available in the submitted build. |
| UI conventions | `UI设计规范.md` plus established SwiftUI components | Update the document when a durable visual rule changes. |
| Public privacy page | `docs/privacy-policy.html` | Published through GitHub Pages. |
| Public support page | `docs/support.html` | Published through GitHub Pages. |
| Build verification | `scripts/build.sh` | Debug iOS Simulator build without signing. |
| Full verification | `scripts/verify.sh` | Metadata checks, simulator build, and XCTest. |

## Test Assets

`CalculatorProTests/CalculatorTests.swift` is connected to the
`CalculatorProTests` XCTest target and runs through the `CalculatorPro` scheme.
`scripts/verify.sh` is the required entry point for build and test verification.

`test_calculator.swift` is a historical standalone simulation with duplicated
calculator logic. It is useful as reference material only and is not proof that
the production implementation works.

`test_results.md` records an older manual comparison. It is not a live test
result and must not be presented as current validation.

## Maintenance Rule

Change the source listed in this document, then update dependent entry points or
generated output. Do not turn compatibility files, backup files, or historical
reports into competing sources of truth.
