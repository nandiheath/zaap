# ZAAP-016: Remove the static Cilium API host

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/infrastructure/cilium/`
- `artifacts/infrastructure/cilium/`
- `docs/runbooks/cilium-api-connectivity.md`

## Goal

Keep Cilium connected to the Kubernetes API when control-plane addresses change, without falling back to kube-proxy.

## Implementation

1. Confirm the stable per-node or load-balanced Kubernetes API endpoint supplied by the reference `zaap-k3s` topology.
2. Replace the hard-coded service IP with that endpoint and document its ownership and failure modes.
3. Exercise control-plane restart or address-change behavior in a disposable cluster.
4. Define a rollback that restores the last known reachable endpoint without disabling Cilium policy enforcement.

## Acceptance criteria

- [ ] No cluster-specific Kubernetes API IP is committed in the Cilium values.
- [ ] Cilium agents reconnect automatically after the tested control-plane address change or restart.
- [ ] Cilium health, service routing, and network policy enforcement remain healthy.
- [ ] The runbook identifies endpoint ownership, diagnostics, and rollback.

## Verification

```bash
./scripts/validate.sh
cilium status --wait
cilium connectivity test
```

Expected: static validation passes and disposable-cluster evidence shows API reconnection plus successful Cilium connectivity checks.

## Blockers

Requires confirmed `zaap-k3s` API endpoint semantics and a disposable cluster; do not guess a production endpoint.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** restore the previously verified endpoint and confirm all Cilium agents reconnect
- **Follow-ups:** none
