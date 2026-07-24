# ZAAP-014: Rehearse secure cluster bootstrap

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-001, ZAAP-010
- **Risk:** high

## Owned paths

- `scripts/bootstrap.sh`
- `manifests/infrastructure/bootstrap/`
- `artifacts/infrastructure/bootstrap/`
- `docs/runbooks/bootstrap.md`
- `.github/workflows/bootstrap-test.yaml`

## Goal

Prove a fresh disposable cluster can reach healthy GitOps reconciliation without exposing credentials or relying on undocumented manual steps.

## Implementation

1. Make bootstrap preflight the target context, required CRDs, tool versions, and secret inputs before mutation.
2. Add server-side dry-run and idempotency checks.
3. Rehearse against a disposable local cluster with fake/non-production secret fixtures.
4. Stop at the handoff to Argo CD; do not grant CI access to a real cluster.

## Acceptance criteria

- [ ] A fresh disposable cluster reaches healthy Argo CD and External Secrets prerequisites.
- [ ] A second bootstrap run is idempotent.
- [ ] Wrong-context and missing-secret preflights fail before mutation.
- [ ] No production cluster credential or secret is available to GitHub Actions.

## Verification

```bash
./scripts/validate.sh
./scripts/bootstrap-test.sh
```

Expected: the disposable-cluster rehearsal passes twice and negative preflight fixtures fail closed.

## Blockers

Depends on reproducible infrastructure source and final AppProject boundaries.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** delete only the disposable cluster; production rollback remains GitOps-based
- **Follow-ups:** none
