# ZAAP-008: Enforce namespace network boundaries

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-007
- **Risk:** high

## Owned paths

- `manifests/infrastructure/cluster-network-configs/`
- `artifacts/infrastructure/cluster-network-configs/`
- `docs/runbooks/network-policy.md`

## Goal

Default-deny production namespaces and allow only the measured ingress, egress, DNS, secret, database, and monitoring flows.

## Implementation

1. Capture required flows from Cilium/Hubble before enforcement.
2. Add default-deny ingress and egress policies per managed namespace.
3. Add least-privilege allows using stable identities, ports, and namespaces rather than broad CIDRs where possible.
4. Stage enforcement and retain a break-glass rollback manifest outside automatic sync.

## Acceptance criteria

- [ ] Unspecified cross-namespace and internet traffic is denied.
- [ ] Argo CD, DNS, 1Password/External Secrets, ingress, monitoring, storage, CNPG, Redis, and Immich retain only documented flows.
- [ ] Hubble shows no unexplained policy drops during the observation window.
- [ ] The rollback restores connectivity without disabling Cilium.

## Verification

```bash
./scripts/validate.sh
cilium connectivity test
```

Expected: validation and the focused allowed/denied flow matrix pass.

## Blockers

ZAAP-007 and access to Hubble flow observations.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** apply the reviewed break-glass policy and revert the Git commit
- **Follow-ups:** none
