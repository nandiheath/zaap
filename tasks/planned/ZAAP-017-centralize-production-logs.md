# ZAAP-017: Centralize production logs

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-005, ZAAP-013
- **Risk:** high

## Owned paths

- `manifests/infrastructure/loki/`
- `manifests/infrastructure/vector/`
- `manifests/infrastructure/infrastructure-app-of-apps/apps/loki.yaml`
- `manifests/infrastructure/infrastructure-app-of-apps/apps/vector.yaml`
- `manifests/infrastructure/infrastructure-app-of-apps/kustomization.yaml`
- `artifacts/infrastructure/loki/`
- `artifacts/infrastructure/vector/`
- `artifacts/infrastructure/infrastructure-app-of-apps/application_loki.yaml`
- `artifacts/infrastructure/infrastructure-app-of-apps/application_vector.yaml`
- `docs/runbooks/log-retention.md`

## Goal

Retain queryable workload and infrastructure logs across pod restarts with bounded storage and an explicit data-handling policy.

## Implementation

1. Add a pinned Loki deployment with Longhorn-backed retention sized for the cluster.
2. Add a pinned node log collector with explicit namespace, label, and sensitive-data filters.
3. Register both components in the infrastructure app-of-apps tree.
4. Document retention, capacity alerts, tenant access, redaction, backup expectations, and recovery.
5. Prove ingestion and post-restart queries in a disposable cluster before production sync.

## Acceptance criteria

- [ ] Application and infrastructure container logs are searchable from the central backend.
- [ ] A known test record remains queryable after its source pod restarts.
- [ ] Retention and storage limits prevent unbounded disk growth.
- [ ] Credentials and secret payloads are excluded or redacted by documented filters.
- [ ] Deployment pins are immutable and rendered artifacts are current.

## Verification

```bash
./scripts/validate.sh
kubectl -n loki rollout status statefulset/loki --timeout=5m
kubectl -n vector rollout status daemonset/vector --timeout=5m
```

Expected: desired-state validation passes; ingestion, restart persistence, redaction, and bounded-retention evidence are recorded.

## Blockers

None

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** stop collectors before removing the backend; retain the Longhorn volume until export or retention expiry is approved
- **Follow-ups:** none
