# ZAAP-004: Back up and restore the Immich database

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/application/immich/postgres-cluster.yaml`
- `manifests/application/immich/external-secret.yaml`
- `artifacts/application/immich/`
- `docs/runbooks/immich-database-recovery.md`

## Goal

Provide encrypted, off-cluster CloudNativePG backups with a demonstrated restore procedure and explicit recovery objectives.

## Implementation

1. Choose an off-cluster object store and source credentials through External Secrets.
2. Configure scheduled base backups and WAL archiving with bounded retention.
3. Define RPO/RTO, monitoring, and a restore into an isolated namespace.
4. Perform a restore drill using representative data; do not test by overwriting production.

## Acceptance criteria

- [ ] Backup data and credentials are encrypted and outside the cluster failure domain.
- [ ] Backup freshness and failures are observable.
- [ ] An isolated restore reaches a consistent database and the measured RPO/RTO are recorded.
- [ ] Secret values never enter Git or logs.

## Verification

```bash
./scripts/validate.sh
kubectl cnpg backup status <restored-cluster> -n <recovery-namespace>
```

Expected: static validation passes and the runbook contains observed successful restore evidence.

## Blockers

Requires an approved object-store destination, retention policy, and operator access for the recovery drill.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** disable the new schedule without deleting verified backup objects
- **Follow-ups:** none
