# ZAAP-012: Harden workload runtime contracts

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-003, ZAAP-006, ZAAP-009
- **Risk:** high

## Owned paths

- `manifests/application/immich/`
- `manifests/application/redis/`
- `manifests/infrastructure/cloudflared/`
- matching subtrees under `artifacts/`

## Goal

Give production workloads explicit resource, privilege, availability, and service-account contracts without breaking storage or acceleration requirements.

## Implementation

1. Measure normal and peak CPU/memory before setting requests, limits, and autoscaling policy.
2. Apply restricted security contexts, read-only filesystems, dropped capabilities, seccomp, and disabled service-account token mounts where supported.
3. Add probes, graceful termination, topology spread, and disruption budgets where replicas make them meaningful.
4. Document narrow exceptions for device access, writable paths, or singleton workloads.

## Acceptance criteria

- [ ] Every container has measured requests and bounded limits or a documented exception.
- [ ] Privilege escalation and unnecessary service-account tokens are disabled.
- [ ] Voluntary disruptions preserve the declared availability contract.
- [ ] Immich upload, machine learning, Redis, and tunnel health paths still work.

## Verification

```bash
./scripts/validate.sh
kubectl get pods -A -o json | kubectl-view-allocations -
```

Expected: static validation passes and staged runtime checks show no OOM, probe, or permission regression.

## Blockers

Depends on removing transitional workloads and completing the Immich/Redis target architecture.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** roll back one workload contract at a time
- **Follow-ups:** none
