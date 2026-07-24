# ZAAP-006: Upgrade the Immich data stack safely

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-004
- **Risk:** high

## Owned paths

- `manifests/application/immich/`
- `artifacts/application/immich/`
- `docs/runbooks/immich-upgrade.md`

## Goal

Move Immich from `v1.119.0` and the obsolete single-instance `pgvecto.rs` contract to a currently supported release and database extension without data loss.

## Implementation

1. Read every upstream breaking change and supported PostgreSQL/vector migration step between the pinned and target releases.
2. Capture a verified backup, rehearse the migration on a restored database, and define rollback boundaries.
3. Upgrade through required intermediate versions instead of skipping incompatible migrations.
4. Remove the superuser application role if the supported target no longer requires it.

## Acceptance criteria

- [ ] The target versions are supported together by current Immich documentation.
- [ ] A production-shaped restore completes the migration and Immich can index, upload, and retrieve media.
- [ ] Rollback is proven at every irreversible boundary before production execution.
- [ ] Renovate cannot bypass the major-version migration review.

## Verification

```bash
./scripts/validate.sh
```

Expected: static validation passes; the runbook also contains observed application and database migration evidence from an isolated environment.

## Blockers

ZAAP-004 and access to representative restored data.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** restore the pre-migration backup under the documented old release
- **Follow-ups:** none
