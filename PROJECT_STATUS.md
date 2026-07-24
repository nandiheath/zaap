# Zaap Project Status

**Updated:** 2026-07-23  
**Scope:** repository state on `main`; live cluster state was not inspected

## Current architecture

- **Delivery:** source manifests are rendered to committed artifacts; Argo CD tracks `main` and applies infrastructure and application app-of-apps trees with automated prune and self-heal.
- **Secrets:** 1Password Connect and External Secrets supply runtime secrets. Repository configuration contains identifiers only.
- **Networking:** Cloudflare Tunnel enters through an Istio gateway. Istio ambient labels are present on application namespaces, but no `PeerAuthentication` policy is declared, so the mesh has no repository-enforced `STRICT` mTLS mode.
- **Storage/data:** Longhorn provides persistent volumes. CloudNativePG runs the Immich PostgreSQL database as one instance. No repository-defined database or volume backup target was found.
- **Applications:** Immich and a shared unauthenticated, non-persistent Redis are declared. A public nginx test application is also included in the production application app-of-apps.
- **Tooling:** Helm and Kustomize are pinned through Hermit. This production-readiness change adds pinned validation tools, deterministic validation, hardened CI, Renovate policy, and an agent task lifecycle.

## Delivery contract

```text
Pull request -> render + schema validation -> reviewed main -> Argo CD pull -> Kubernetes
```

GitHub Actions must remain credentialless with respect to Kubernetes. Argo CD is the only continuous deployment actor. A failed render, schema check, or generated-artifact diff blocks merge.

## Active repository controls

- `main` requires the strict `Validate desired state / Render and validate` check, one approving review, stale-review dismissal, conversation resolution, linear history, and administrator enforcement. Force pushes and deletions are disallowed.
- GitHub Actions defaults to read-only tokens, cannot approve pull requests, permits only GitHub-owned actions, and requires full commit-SHA action pins.
- Secret scanning, push protection, and Dependabot security updates are enabled. The repository contains identifiers only; workload credentials remain in 1Password and reach the cluster through External Secrets.

## Confirmed risks and gaps

### Critical

- No backup and restore contract exists for Immich PostgreSQL or Longhorn data.
- The committed Prometheus artifact has no matching `manifests/infrastructure/prometheus/` source tree, so it cannot be reproduced.

### High

- Cluster mTLS is permissive and no NetworkPolicy resources were found.
- Redis authentication is disabled while it is shared by applications.
- Cloudflared and nginx use floating image tags; several other images are tag-pinned but not digest-pinned.
- Immich is pinned to `v1.119.0` and a single PostgreSQL `pgvecto.rs` instance; upgrading requires an explicit supported migration, not a blind version bump.
- Every Argo CD Application uses the `default` project; repository source and destination boundaries are not isolated with AppProjects.
- The public test application is part of the production app-of-apps.

### Medium

- Most workloads lack explicit CPU/memory requests and limits, restricted security contexts, and disruption budgets.
- No alert routing, actionable SLOs, centralized log retention, or deployment rollback drill is defined in the repository.
- Bootstrap directly applies generated resources and has no automated disposable-cluster rehearsal.

## Planned work

Claimable work is under `tasks/planned/`, ordered by `Depends on`. The first production-hardening wave fixes reproducibility and repository controls before changes that could affect live traffic or persistent data.

## Recent changes

- **2026-07-23 — Production-readiness foundation:** documented the system and agent protocol; made rendering fail closed; added reproducible validation, least-privilege CI, dependency-update policy, and a prioritized hardening backlog.
