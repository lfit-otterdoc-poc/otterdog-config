// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2026 The Linux Foundation
//
// Otterdog top-level config for lfit-otterdog.
//
// Otterdog manages GitHub organization settings as code. You describe the
// org (settings, repos, teams, rulesets, webhooks) in a Jsonnet file. Then:
//   - the CLI shows a plan (diff) and can apply it, like Terraform
//   - the webapp does the same on pull requests to this repo, and applies
//     the change when the PR merges
//
// This file is the entry point. Both the CLI and the webapp read it.
// It configures:
//   - the default template that org settings build on
//   - the folder that holds one settings file per organization
//   - how the CLI finds its GitHub credentials
//   - the list of GitHub organizations to manage
{
  defaults: {
    jsonnet: {
      // LF-wide defaults every org file builds on. They live in this
      // repo under templates/ and extend the upstream Otterdog defaults.
      // Format: <repo url>#<path in repo>@<git ref>. Otterdog clones the
      // repo and vendors the templates/ folder next to each org file.
      // Pinned to a tag on purpose: Otterdog pulls this ref on every
      // run, so a floating @main would change policy for every managed
      // organization the moment anything lands there. To roll out a
      // change to the defaults: merge it, tag it, then bump this pin in
      // its own pull request so the webapp plans the effect first.
      base_template: 'https://github.com/lfit-otterdoc-poc/otterdog-config#templates/lf-defaults.libsonnet@v0.3.0',
      // Folder with one <github_id>.jsonnet file per organization.
      config_dir: 'orgs',
    },
    credentials: {
      // The CLI reads its GitHub token from environment variables.
      // The webapp ignores this block; it uses the GitHub App instead.
      provider: 'env',
    },
    env: {
      // Names of the environment variables, not the values.
      api_token: 'OTTERDOG_API_TOKEN',
      // The next three are only needed for settings GitHub exposes
      // through its web UI and not through its API. Optional.
      username: 'OTTERDOG_USERNAME',
      password: 'OTTERDOG_PASSWORD',
      twofa_seed: 'OTTERDOG_TOTP_SEED',
    },
  },
  organizations: [
    {
      // Display name used in the webapp and CLI output.
      name: 'lfit-otterdoc-poc',
      // The GitHub login of the organization. Also the org file name.
      github_id: 'lfit-otterdoc-poc',
    },
  ],
}
