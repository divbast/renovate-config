<!-- SPDX-License-Identifier: BSD-2-Clause -->
<!-- SPDX-FileCopyrightText: 2026 Aryan Ameri <github@aryan.ameri.coffee> -->

# renovate-config

Shared [Renovate](https://docs.renovatebot.com/) presets for the repositories
of the divbast organisation, so that each repository stops carrying its own
copy of the same settings.

## Presets

- `default.json` is for every divbast repository. It sets the commit style,
  the squash automerge, the subject prefix for tool and workflow updates, and
  the `build:` prefix for Dockerfile updates, the trivy lookup, and the Go and
  jq rules that apply wherever those tools appear. It lifts Renovate's hourly
  PR limit, so a repository with many pending updates is not held back, and
  it carries four regex managers for build tools that no default manager
  reads in workflows: the BuildKit image (`image=moby/buildkit:v...@sha256:`),
  the SBOM scanner (`generator=docker/buildkit-syft-scanner:...@sha256:`),
  the rehearsal registry (a `docker run ... registry:...@sha256:` line under
  a `# renovate: registry` marker) and `MISE_VERSION` (under a
  `# renovate: datasource=github-releases depName=jdx/mise` marker).
- `app.json` is for the repositories that build an image. It adds only the
  FrankenPHP label and PR note.

## Using them

Every repository extends the default preset. An app repository extends the
app preset as well:

```json
{
  "extends": [
    "github>divbast/renovate-config",
    "github>divbast/renovate-config:app"
  ]
}
```

A repository keeps in its own `renovate.json` only what is specific to it,
such as the custom managers for its pinned inputs.

## Checks

`just validate` runs Renovate's own `renovate-config-validator --strict` over
the presets and this repository's `renovate.json`, in a pinned Renovate
image. `check-managers.js` then runs in the same image and fails when a
`matchManagers` value names no manager of that Renovate, which the validator
does not catch and Renovate itself ignores. The recipe also runs it over
`test/fixtures/bad-manager.json` and requires that run to fail, so the check
cannot quietly stop checking.

`just ci` adds the lint gates (pinact, zizmor, actionlint, ShellCheck and
`reuse lint`), which come from `divbast/ci`'s `common.just`. `just setup`
checks `divbast/ci` out into `.ci` at the commit the workflows pin and
installs the toolchain from `mise.toml`. The gates that call GitHub need a
fine-grained `GITHUB_TOKEN`; see
[ci's README](https://github.com/divbast/ci#local-github-token).

## Workflows

This repository calls the shared workflows in `divbast/ci`, all at one
pinned release:

- `ci.yml` runs ci's `lint.yml`, and a `validate` job of its own that runs the
  same validator as `just validate`. A `required` job needs both, and is the
  one check main's ruleset asks for.
- `renovate.yml` runs self-hosted Renovate for this repository alone. It
  merges its own pull requests only while the repository variable
  `RENOVATE_CONFIG_AUTOMERGE` is `enabled`.
- `stall.yml` fails each day that updates have stopped flowing: a Renovate
  pull request stuck, or Renovate silent.

Renovate moves every `divbast/ci` ref in one pull request, because ci's pin
check refuses workflows that name more than one commit. The preset puts
those refs in the `divbast/ci` group, and holds a new major of `divbast/ci`
for approval on the Dependency Dashboard. A major is minted by any commit in
ci that declares a `Breaking-change:` trailer; minor and patch releases keep
merging by themselves.

## Licence

BSD-2-Clause.
