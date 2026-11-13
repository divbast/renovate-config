# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Aryan Ameri <github@aryan.ameri.coffee>

set shell := ["mise", "exec", "--", "bash", "-euo", "pipefail", "-c"]

import? '.ci/just/common.just'

# Tool versions live in mise.toml

default:
    @just --list

# Fetch divbast/ci at the commit the workflows pin, then install the toolchain
setup: ci-checkout
    #!/usr/bin/env bash
    # Not through the mise exec shell: this is what installs what it runs
    set -euo pipefail
    mise install

# Fetch divbast/ci at the commit the workflows pin, into .ci, and nothing else
ci-checkout:
    #!/usr/bin/env bash
    # Not through the mise exec shell, which would first install what is missing
    set -euo pipefail
    # The one commit the workflows call divbast/ci at, spelt in any case
    uses="^[[:space:]]*(-[[:space:]]+)?uses:[[:space:]]*[\"']?divbast/ci/[^@[:space:]\"']+@[^[:space:]\"'#]+"
    sha=$(grep -hoiE "${uses}" .github/workflows/*.y*ml | sed 's/.*@//' | sort -u | paste -sd ' ' - || true)
    if [[ ! "${sha}" =~ ^[0-9a-f]{40}$ ]]; then
        echo "ci-checkout: the workflows must call divbast/ci at one full commit SHA, not at: ${sha:-none}" >&2
        exit 1
    elif [[ "$(git -C .ci rev-parse HEAD 2>/dev/null || true)" == "${sha}" ]]; then
        echo "ci-checkout: .ci is already at ${sha}"
        exit 0
    fi
    changed=$([[ ! -e .ci/.git ]] || git -C .ci status --porcelain)
    if [[ -n "${changed}" ]]; then
        printf 'ci-checkout: moving .ci to %s would carry its own changes across, or stop on them; save or discard them first:\n%s\n' "${sha}" "${changed}" >&2
        exit 1
    fi
    git init -q .ci
    git -C .ci fetch -q --depth 1 https://github.com/divbast/ci "${sha}"
    git -C .ci checkout -q FETCH_HEAD && rm -rf .ci/bin

# Check the presets and this repository's own config against Renovate's schema
validate:
    docker run --rm -v "$PWD:/w:ro" -w /w ghcr.io/renovatebot/renovate:44.237.1@sha256:f80455e144c085aa4b71ed4c0f89477675217de742464e09a09868c4917e8d10 renovate-config-validator --strict --no-global default.json app.json renovate.json

# Every lint gate
lint:
    {{ just_executable() }} ci-fresh actions-check workflow-audit actionlint shell-lint reuse-lint

# Every gate. Run before committing
ci: lint validate
