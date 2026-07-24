# ZAAP-005: Back up and restore Longhorn volumes

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/infrastructure/longhorn/`
- `artifacts/infrastructure/longhorn/`
- `docs/runbooks/longhorn-recovery.md`

## Goal

Protect persistent volumes against cluster loss with encrypted off-cluster backups and a demonstrated restore.

## Implementation

1. Configure a dedicated off-cluster backup target and External Secret credentials.
2. Add recurring jobs with retention that matches the recovery objectives and storage budget.
3. Alert on stale or failed backups.
4. Restore a disposable volume and verify its content checksum and mountability.

## Acceptance criteria

- [ ] The backup target is outside the Longhorn cluster and credentials come from External Secrets.
- [ ] Schedules and retention are explicit.
- [ ] A disposable restore reproduces the expected data and the runbook records observed timings.
- [ ] Deleting a Kubernetes Secret does not delete backup data.

## Verification

```bash
./scripts/validate.sh
kubectl -n longhorn-system get recurringjobs.longhorn.io
```

Expected: validation passes and the recovery drill records a successful checksum comparison.

## Blockers

Requires an approved backup target, retention policy, and operator access for the restore drill.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** stop recurring jobs without deleting existing backups
- **Follow-ups:** none
