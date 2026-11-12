# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Aryan Ameri <github@aryan.ameri.coffee>

set shell := ["mise", "exec", "--", "bash", "-euo", "pipefail", "-c"]

# Tool versions live in mise.toml

default:
    @just --list

setup:
    #!/usr/bin/env bash
    # This is the one recipe that must not run through `mise exec` shell
    set -euo pipefail
    mise install

# Check the presets and this repository's own config against Renovate's schema
validate:
    docker run --rm -v "$PWD:/w:ro" -w /w ghcr.io/renovatebot/renovate:44.236.5@sha256:935fc7f1de18fdde6cc40c9dd57cc06a4300251b4997e3841ffd9b1e84972767 renovate-config-validator --strict --no-global default.json app.json renovate.json

# Verify every action is a SHA
actions-check:
    GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}" pinact run --verify --check

# Rewrite tag references to the SHA
actions-pin:
    GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}" pinact run

# Move every action to latest release
actions-update:
    GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}" pinact run --update

workflow-audit:
    GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}" zizmor --persona=auditor .github/workflows

lint: actions-check workflow-audit
    actionlint
    reuse lint

ci: lint validate
