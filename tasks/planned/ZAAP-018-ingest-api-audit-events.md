# ZAAP-018: Ingest Kubernetes API audit events

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-017
- **Risk:** high

## Owned paths

- `manifests/infrastructure/vector/`
- `artifacts/infrastructure/vector/`
- `docs/runbooks/kubernetes-api-audit.md`

## Goal

Record security-relevant Kubernetes API activity in centralized storage without logging secret bodies or exhausting node disks.

## Implementation

1. Define a least-data audit policy covering authentication, authorization failures, RBAC changes, secret metadata access, and destructive operations.
2. Configure the reference `zaap-k3s` API server to write bounded audit files through its supported node configuration.
3. Extend the node collector to ingest, label, redact, and forward audit events to the central log backend.
4. Document audit-policy rollout, rotation, access control, detection queries, and rollback.
5. Prove representative allow, deny, RBAC-change, and secret-metadata events in a disposable cluster.

## Acceptance criteria

- [ ] Representative security-relevant API actions produce queryable audit events.
- [ ] Request and response bodies for Secrets are not retained.
- [ ] Local audit files rotate with bounded disk usage and survive backend unavailability safely.
- [ ] Only authorized operators can query retained audit events.
- [ ] Disabling or rolling back audit collection does not interrupt the API server.

## Verification

```bash
./scripts/validate.sh
kubectl auth can-i --list
```

Expected: static validation passes and disposable-cluster evidence records the representative events, redaction, rotation, and safe rollback.

## Blockers

Requires access to the `zaap-k3s` configuration and a disposable cluster for API-server restart testing.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** remove the audit flags only after stopping collection; preserve retained logs under the documented access policy
- **Follow-ups:** none
