# ZAAP-007: Enforce strict mesh mTLS

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/infrastructure/cluster-network-configs/`
- `artifacts/infrastructure/cluster-network-configs/`
- `docs/runbooks/mesh-mtls-rollout.md`

## Goal

Require authenticated mesh transport while preserving explicitly documented non-mesh traffic such as Kubernetes probes and operator control paths.

## Implementation

1. Inventory workloads and ports that are outside ambient mesh interception.
2. Add namespace-scoped or mesh-scoped `PeerAuthentication` policies, starting with dry-run telemetry and staged namespaces.
3. Handle required exceptions narrowly by port and namespace; do not retain a blanket permissive fallback.
4. Record abort signals and rollback ordering.

## Acceptance criteria

- [ ] Mesh service-to-service traffic succeeds under `STRICT` mTLS.
- [ ] A plaintext in-cluster client is rejected where no exception is declared.
- [ ] Health probes, CNPG, DNS, and ingress paths retain required connectivity.
- [ ] Exceptions have an owner and reason.

## Verification

```bash
./scripts/validate.sh
istioctl x authz check <pod>
```

Expected: static validation passes and staged connectivity checks prove encrypted success and plaintext rejection.

## Blockers

Requires live traffic inventory and a maintenance window for staged enforcement.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** revert each namespace policy in reverse rollout order
- **Follow-ups:** none
