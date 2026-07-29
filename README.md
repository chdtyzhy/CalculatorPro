# CalculatorPro

CalculatorPro is a focused offline calculator for iPhone, built with SwiftUI.
It supports basic arithmetic, percentages, sign changes, decimal input,
backspace, and sequential chained calculations.

## Requirements

- macOS with Xcode installed at `/Applications/Xcode.app`
- iOS Simulator SDK included with Xcode
- No third-party dependencies

## Open The Project

```bash
open CalculatorPro.xcodeproj
```

Use the `CalculatorPro` scheme to run the app.

## Command-Line Validation

```bash
./scripts/verify.sh
```

The command validates release metadata and builds the Debug app for the iOS
Simulator without changing the global `xcode-select` configuration.

## AI-Assisted Development

- Start with [AGENTS.md](AGENTS.md) for project rules and validation policy.
- Use [SOURCE_OF_TRUTH.md](SOURCE_OF_TRUTH.md) to locate authoritative files.
- Claude Code enters through [CLAUDE.md](CLAUDE.md), and Gemini CLI enters
  through [GEMINI.md](GEMINI.md); both import the same shared rules.
- Read [UI设计规范.md](UI设计规范.md) before visual changes.

### Tool Compatibility

| AI coding tool | Project instruction entry |
| --- | --- |
| OpenAI Codex | Reads `AGENTS.md` directly. |
| Claude Code | Reads `CLAUDE.md`, which imports `AGENTS.md`. |
| Cursor | Reads `AGENTS.md` directly. |
| Gemini CLI | Reads `GEMINI.md`, which imports `AGENTS.md`. |
| GitHub Copilot coding agent | Reads `AGENTS.md` directly. |

Keep shared rules in `AGENTS.md`. Tool-specific entry files must remain thin
bridges and must not duplicate the complete rule set.

The repository intentionally has no project-level skills yet. Add a `skills/`
directory only when a repeated workflow has enough stable steps and constraints
to justify a reusable skill.

## Public Pages

- Privacy policy: https://chdtyzhy.github.io/CalculatorPro/privacy-policy.html
- Technical support: https://chdtyzhy.github.io/CalculatorPro/support.html
