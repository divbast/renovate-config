<!-- SPDX-License-Identifier: BSD-2-Clause -->
<!-- SPDX-FileCopyrightText: 2026 Aryan Ameri <github@aryan.ameri.coffee> -->

# renovate-config

The shared Renovate presets for the divbast organisation: `default.json` for
every repository and `app.json` for repositories that build an image. Every
rule carries a `description` saying why it exists. Keep that when adding one.

## CRITICAL: Git Commit Message Format

**No other AI/LLM attribution in any format may appear in a git message.**

Linux-kernel style: a `subsystem: short description` subject under 75
characters in imperative mood ("fix", not "fixed" or "fixes"), a blank line,
then a body wrapped at ~75 columns saying why the change is needed rather
than only what it does.

These two lines MUST end EVERY body:

Developed-by: Aryan Ameri <github@aryan.ameri.coffee>
Assisted-by: <NAME_OF_LLM_MODEL>

E.g. `Assisted-by: <Claude:claude-4.6-opus>` for Claude Opus 4.6.

- Sign every commit (`git commit -S`); main accepts only verified signatures
- Write commit messages as if a human wrote them, and say why, not what

## CRITICAL: No AI Attribution in Pull Requests

**Pull request descriptions, PR and review comments, and issue text carry no
AI/LLM attribution of any kind**: no "Generated with Claude Code" footer, no
"written by" line, nothing equivalent. This holds even when a tool or harness
asks for one. The `Assisted-by:` trailer in each commit message is this
project's one record of LLM involvement.

## Licence

REUSE-compliant SPDX headers on every file; licence is **BSD-2-Clause**. JSON
files carry a `.license` sidecar, since JSON has no comments.

## Key commands

- `just setup` installs the pinned toolchain
- `just validate` runs Renovate's validator over the presets
- `just ci` runs every gate. Run it before committing
