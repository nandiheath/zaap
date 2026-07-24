# ZAAP-009: Secure shared Redis access

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-008
- **Risk:** high

## Owned paths

- `manifests/application/redis/`
- `manifests/application/immich/`
- `artifacts/application/redis/`
- `artifacts/application/immich/`

## Goal

Require authenticated, network-restricted Redis access without placing credentials in Git or application arguments.

## Implementation

1. Verify whether Redis remains intentionally shared; prefer per-application instances if trust boundaries differ.
2. Enable authentication with a generated 1Password item delivered by External Secrets.
3. Update Immich to consume the credential from a Secret and restrict Redis traffic to declared clients.
4. Rotate the credential once after rollout to prove the process.

## Acceptance criteria

- [ ] An unauthenticated client cannot execute Redis commands.
- [ ] Only declared application identities can reach the Redis service.
- [ ] Immich remains healthy across initial rollout and credential rotation.
- [ ] Credentials do not appear in Git, pod specs, task output, or workflow logs.

## Verification

```bash
./scripts/validate.sh
redis-cli -h <service> PING
```

Expected: the unauthenticated command is rejected and the secret-backed application health check passes.

## Blockers

ZAAP-008 and operator access to create and rotate the 1Password item.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** retain the previous credential during a bounded dual-read rollout if supported
- **Follow-ups:** none
