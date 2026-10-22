// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2026 The Linux Foundation
//
// LF-wide Otterdog defaults for lfit-otterdog.
//
// Every organization file starts from this file:
//
//   local orgs = import 'vendor/otterdog-config/templates/lf-defaults.libsonnet';
//   orgs.newOrg('my-project', 'my-github-org') { ... }
//
// It builds on the upstream Otterdog defaults (otterdog-defaults.libsonnet,
// EPL-2.0, copied unchanged from eclipse-csi/otterdog) and changes only
// what the Linux Foundation wants to be true in every organization.
// Those settings are written out here even when upstream already agrees,
// so the LF policy can be read in one place.
//
// Source of these defaults: the live settings of the lfreleng-actions,
// onap and FDio organizations, reviewed in the Otterdog POC. The
// strictest (lfreleng-actions) won.
//
// An organization can still override anything below in its own file.
// Repos mirrored from Gerrit need the pull-request rules off: add the
// repo name to `exclude_repo_names` of the base ruleset in the org file.
//
// Reference for every key:
// https://otterdog.readthedocs.io/en/latest/reference/organization/

local upstream = import 'otterdog-defaults.libsonnet';

// Branch rules applied to the default branch of every repo in the org.
// Mirrors the "Base Protections" org ruleset of lfreleng-actions.
local lfBaseRuleset = upstream.newOrgRuleset('LF Base Protections') {
  include_repo_names: ['~ALL'],
  exclude_repo_names: [],
  include_refs: ['~DEFAULT_BRANCH'],

  // Nobody deletes or force-pushes the default branch. Creating it is
  // allowed, or the first push to a new repo would be blocked: with no
  // bypass actors, GitHub lets nobody create a restricted branch.
  allows_creations: true,
  allows_deletions: false,
  allows_force_pushes: false,

  // Changes land through a pull request.
  required_pull_request: upstream.newPullRequest() {
    required_approving_review_count: 1,
    // A new push after approval needs a fresh approval.
    dismisses_stale_reviews: true,
    requires_last_push_approval: true,
    // Every review comment thread must be resolved before merge.
    requires_review_thread_resolution: true,
  },

  // The DCO sign-off check (GitHub App "dco") must pass.
  required_status_checks: upstream.newStatusChecks() {
    // Let repos and branches be created even though no check ran yet.
    do_not_enforce_on_create: true,
    status_checks: ['dco:DCO'],
  },
};

// Organization defaults.
local newOrg(name, id=name) = upstream.newOrg(name, id) {
  settings+: {
    // All LF organizations sit in the LF enterprise account.
    plan: 'enterprise',

    // 1. Every member must have two-factor auth.
    two_factor_requirement: true,

    // 2. Members can read every repo unless given more.
    default_repository_permission: 'read',

    // 3. Only org owners create repos.
    members_can_create_public_repositories: false,
    members_can_create_private_repositories: false,

    // 4. Commits made in the GitHub web UI carry a DCO sign-off.
    web_commit_signoff_required: true,

    // 7. New repos start on `main`.
    default_branch_name: 'main',
  },

  // 8. Base branch rules on every default branch.
  rulesets: [lfBaseRuleset],
};

// Repository defaults.
local newRepo(name) = upstream.newRepo(name) {
  // 4. Web UI commits carry a DCO sign-off.
  web_commit_signoff_required: true,

  // 5. Dependabot alerts and automatic security update PRs.
  dependabot_alerts_enabled: true,
  dependabot_security_updates_enabled: true,

  // 6. Secret scanning, and block pushes that contain a secret.
  secret_scanning: 'enabled',
  secret_scanning_push_protection: 'enabled',

  // 7. Default branch.
  default_branch: 'main',
};

// Re-export every upstream function, with the LF versions on top.
upstream {
  newOrg:: newOrg,
  newRepo:: newRepo,
  lfBaseRuleset:: lfBaseRuleset,
}
