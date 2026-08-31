# Otterdog configuration file for the lfit-otterdoc-poc GitHub organization.
# Edit this file to define the desired state of the organization, including
# its settings, teams, and repositories.

# Import Otterdog's vendored default template as `orgs`. It provides the
# default settings and constructors used below, such as `newOrg`, `newTeam`,
# and `newRepo`.

local orgs = import 'vendor/otterdog/examples/template/otterdog-defaults.libsonnet';

# Define what the lfit-otterdoc-poc organization looks like and how it behaves.
# This includes organization-wide settings, such as what members are allowed
# to do, and the rules for GHA workflows running in this organization.

orgs.newOrg('lfit-otterdoc-poc', 'lfit-otterdoc-poc') {
  settings+: {
    billing_email: "agrimberg@linuxfoundation.org",
    default_code_security_configurations_disabled: false,
    description: "",
    members_can_create_private_pages: true,
    members_can_create_private_repositories: true,
    members_can_create_public_repositories: true,
    members_can_fork_private_repositories: true,
    name: "LF Release Engineering Otterdoc POC",
    plan: "enterprise",
    web_commit_signoff_required: false,
    workflows+: {
      actions_can_approve_pull_request_reviews: false,
      default_workflow_permissions: "write",
    },
  },

  # Define the GitHub teams Otterdog should manage for this organization.
  # Each team entry sets the team's configuration and membership.
  # The `members+` list defines which GitHub users should belong to that team.

  teams+: [
    orgs.newTeam('Release Engineering') {
      description: "LF Release Engineering",
      members+: [
        "ModeSevenIndustrialSolutions",
        "askb",
        "eb-oss",
        "tykeal",
        "vvalderrv"
      ],
    },
  ],

  # Define the GitHub repositories Otterdog should manage for this organization.
  # Each repository entry defines the desired settings for that repository.
  # Changes here are compared against GitHub and shown in `plan` before applied.

  _repositories+:: [
    orgs.newRepo('otterdog-config') {
      allow_merge_commit: true,
      allow_update_branch: false,
      delete_branch_on_merge: false,
      dependabot_alerts_enabled: false,
      description: "Otterdog configuration-as-code for managing the GH org.",
      private: true,
      web_commit_signoff_required: false,

      # Track the existing GitHub Actions secret without storing or changing
      # its actual value in this repository.
      secrets+: [
        orgs.newRepoSecret('OTTER_API_TOKEN') {
          value: "********",
        },
      ],

      workflows+: {
        default_workflow_permissions: "write",
      },
    },

    orgs.newRepo('otterdog-test-repo') {
      description: "Otterdog POC test repository",
      private: true,
    },

    orgs.newRepo('otterdog-test-repo-2') {
      description: "Otterdog POC test repository 2",
      private: true,
    },
  ],
}
