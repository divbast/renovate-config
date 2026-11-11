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
  jq rules that apply wherever those tools appear.
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
image. `just ci` adds the lint gates (pinact, zizmor, actionlint and
`reuse lint`). `just setup` installs the toolchain from `mise.toml`.

## Workflows

CI and the self-hosted Renovate run are written out in this repository for
now. In stage 2b they move onto the shared workflows in `divbast/ci`.

## Licence

BSD-2-Clause.
