<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# otterdog-config

Otterdog configuration-as-code for managing the lfit-otterdoc-poc GitHub organization.

## Architecture

We manage GitHub configuration for hundreds of open source projects with
[Otterdog](https://github.com/eclipse-csi/otterdog). At that scale the
Otterdog **WebApp** (not the CLI) drives everything: an always-on,
webhook-driven service that validates pull requests, posts plan comments, and
applies changes on merge.

### Grouping model

We group projects by **umbrella**. Each umbrella gets its own cluster, and
the projects under it become **tenants** within that cluster.

```text
Umbrella cluster (one Kubernetes cluster per umbrella)
├── Shared infrastructure (MongoDB, Valkey/Redis, GHProxy, ingress)
└── Otterdog WebApp (one per umbrella)
    ├── One GitHub App installed on every tenant org
    ├── One Otterdog config repo listing every tenant org
    └── Tenants (project orgs)
        ├── project-tenant-a  (GitHub org + its repos)
        ├── project-tenant-b  (GitHub org + its repos)
        └── project-tenant-c  (GitHub org + its repos)
```

Mapping to Otterdog concepts:

| Concept             | Maps to                                             |
|---------------------|-----------------------------------------------------|
| Umbrella            | One Kubernetes cluster + one WebApp deployment      |
| WebApp installation | One GitHub App shared across the umbrella's tenants |
| Tenant              | One GitHub organization managed by the WebApp       |
| Tenant repos        | Repositories inside each tenant org                 |
| Config repo         | Single Otterdog config repo listing all tenant orgs |

The WebApp routes every incoming webhook by GitHub App **installation**, so one
deployment cleanly serves every tenant org while keeping them isolated by org.

### Why one WebApp per umbrella

- The WebApp supports one GitHub App across every tenant org, so a single
  deployment covers all tenants under an umbrella.
- Fewer moving parts than one deployment per project (no per-project MongoDB,
  Redis, GitHub App, or values file to operate).
- Tenants stay isolated at the org level, which matches how teams run umbrella
  projects.

Run a separate WebApp when a project must keep fully separate administration or
secrets from the rest of its umbrella.

## Cluster requirements

Each umbrella cluster must provide the following before you deploy the WebApp.

### Kubernetes platform

- A running Kubernetes cluster (locally for testing, e.g. kind/k3s/minikube;
  AWS EKS for production).
- [Helm](https://helm.sh) installed.
- An ingress controller exposing a stable, public **HTTPS** URL for GitHub
  webhooks.

### In-cluster dependencies

- **MongoDB** — persistence for WebApp state. Provide its connection string.
- **Valkey/Redis** — caching and message queue. Must run **without
  authentication** (GHProxy does not support authenticated Redis).
- **GHProxy** — GitHub API proxy, included in the Otterdog Helm charts.

### Secrets (Vault Secrets Operator)

The committed values enable Vault (`vault.enabled: true`), so the cluster also
needs:

- The Vault Secrets Operator running, with its CRDs installed.
- A reachable Vault with a KV v2 mount holding the Otterdog secrets.
- The `secrets-manager-sa` service account plus the Vault role and auth-path
  binding the chart references.

Without these, Helm cannot sync the referenced secrets.

- The WebApp serves internal management endpoints at
  `https://<address>/internal/`; **restrict them by IP** to Otterdog operators
  via ingress annotations.
- Webhook traffic to `https://<address>/github-webhook/receive` carries a
  webhook secret for validation.

### GitHub App (one per umbrella)

Create a single GitHub App for the umbrella and install it on every tenant org.

- Homepage URL: the WebApp address.
- Webhook URL: `<WEBAPP>/github-webhook/receive` with a webhook secret.
- Repository permissions: Actions, Administration, Commit statuses, Contents,
  Environments, Pages, Pull requests, Secrets, Variables, Webhooks, Workflows =
  **Read & Write**; Issues, Metadata = **Read**.
- Organization permissions: Administration, Custom Organization Roles, Secrets,
  Variables, Webhooks = **Read & Write**; Members, Plan = **Read**.
- Subscribed events: Issue comment, Pull request, Pull request review, Push,
  Workflow job, Workflow run.

### Deployment inputs (Helm `values.yaml`)

Non-secret settings live in [deploy/webapp/values.yaml](deploy/webapp/values.yaml):

- `config.configOwner`, `config.configRepo`, `config.configPath` — the Otterdog
  config repo listing all tenant orgs.
- `config.baseUrl`, `config.dependencyTrackUrl`.
- `github.appId`, `github.webhookEndpoint`, `github.webhookValidationContext`,
  `github.webhookSyncContext` — the commit-status contexts the WebApp reports
  back to pull requests.

MongoDB, Valkey, and GHProxy connections are auto-derived by the chart from its
bundled subcharts. Secrets never live in this file — the Vault Secrets Operator
syncs them at runtime as raw strings (no base64): config token, GitHub App
private key, webhook secret, Dependency-Track token, and database credentials.

### Initialization

The chart runs `/internal/init` automatically as a Helm post-install and
post-upgrade hook (`initJob.enabled: true`), so the WebApp fetches config and
syncs state on every install and upgrade.

To re-run it manually for recovery, call the endpoint directly:

```bash
curl https://<webapp-address>/internal/init
```
