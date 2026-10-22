<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# otterdog-config

Central [Otterdog](https://github.com/eclipse-csi/otterdog) configuration
for the Linux Foundation. Otterdog manages GitHub organization settings
as code: a plan on every pull request, an apply on merge.

This is the **central** repo. It lists which organizations Otterdog
manages and holds the LF-wide defaults. Each managed organization keeps
its own settings in a `.otterdog` repo inside that organization.

<!-- markdownlint-disable MD013 -->

| Path | Purpose |
| --- | --- |
| `otterdog.jsonnet` | Entry point. The list of managed organizations, the defaults template to use, and how the CLI finds credentials. |
| `templates/lf-defaults.libsonnet` | LF-wide defaults every organization file builds on. |
| `templates/otterdog-*.libsonnet` | Upstream Otterdog defaults, copied unchanged (EPL-2.0). |

<!-- markdownlint-enable MD013 -->

## Adding an organization

1. Create a `.otterdog` repo in the organization with
   `otterdog/<github-id>.jsonnet`.
2. Install the Otterdog GitHub App on the organization.
3. Add the organization to `organizations` in `otterdog.jsonnet` here.

## Using the CLI

```bash
export OTTERDOG_API_TOKEN="$(gh auth token)"
otterdog fetch-config <github-id>
otterdog plan --no-web-ui <github-id>
```

`fetch-config` pulls the organization's settings file from its
`.otterdog` repo into the local `orgs/` folder, which starts empty.
`--no-web-ui` limits the plan to settings GitHub exposes through its
API. Some settings live in GitHub's web UI and not in the API; planning
those also needs `OTTERDOG_USERNAME`, `OTTERDOG_PASSWORD` and
`OTTERDOG_TOTP_SEED`.

The token needs the scopes `repo`, `workflow`, `admin:org`,
`admin:org_hook` and `delete_repo`. `.gitignore` excludes `orgs/`.

## Status

Proof of concept. See `docs/` in the working folder for the setup log.
