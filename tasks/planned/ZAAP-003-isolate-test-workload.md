# ZAAP-003: Remove the test workload from production

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** medium

## Owned paths

- `manifests/application/application-app-of-apps/kustomization.yaml`
- `manifests/application/application-app-of-apps/apps/test-app.yaml`
- `manifests/application/test-app/`
- `artifacts/application/application-app-of-apps/`
- `artifacts/application/test-app/`

## Goal

Ensure the public nginx diagnostic workload is not reconciled as a production application.

## Implementation

1. Remove `test-app` from the production app-of-apps.
2. Delete its production source and generated artifact, or move a genuinely required probe to an explicitly isolated non-production environment.
3. Confirm Argo CD pruning behavior and record the safe removal sequence.

## Acceptance criteria

- [ ] The rendered production application registry contains no `test-app` Application.
- [ ] No production VirtualService or Service routes to the test workload.
- [ ] Removal has a documented Git rollback.

## Verification

```bash
./scripts/validate.sh
! grep -R "test-app" manifests/application/application-app-of-apps artifacts/application/application-app-of-apps
```

Expected: validation passes and the production registry contains no test workload.

## Blockers

None.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** revert the isolated removal commit
- **Follow-ups:** none
