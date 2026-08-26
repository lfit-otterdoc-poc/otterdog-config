local orgs = import 'vendor/otterdog/examples/template/otterdog-defaults.libsonnet';

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
  _repositories+:: [
    orgs.newRepo('otterdog-config') {
      allow_merge_commit: true,
      allow_update_branch: false,
      delete_branch_on_merge: false,
      dependabot_alerts_enabled: false,
      description: "Otterdog configuration-as-code for managing the lfit-otterdoc-poc GitHub organization.",
      private: true,
      web_commit_signoff_required: false,
      workflows+: {
        default_workflow_permissions: "write",
      },
    },
    orgs.newRepo('otterdog-test-repo') {
      description: "Otterdog POC test repository",
      private: true,
    },
  ],
}
