# TODO

The canonical claimable backlog is `tasks/planned/`; ownership and state transitions are defined in `tasks/README.md`. Do not add unowned checklist items here.

## Foundation

- [ZAAP-001: Restore reproducible Prometheus source](tasks/planned/ZAAP-001-restore-prometheus-source.md)
- [ZAAP-003: Remove the test workload from production](tasks/planned/ZAAP-003-isolate-test-workload.md)

## Data safety and supported applications

- [ZAAP-004: Back up and restore the Immich database](tasks/planned/ZAAP-004-protect-immich-database.md)
- [ZAAP-005: Back up and restore Longhorn volumes](tasks/planned/ZAAP-005-protect-longhorn-volumes.md)
- [ZAAP-006: Upgrade the Immich data stack safely](tasks/planned/ZAAP-006-upgrade-immich-data-stack.md)

## Network and access boundaries

- [ZAAP-007: Enforce strict mesh mTLS](tasks/planned/ZAAP-007-enforce-strict-mtls.md)
- [ZAAP-008: Enforce namespace network boundaries](tasks/planned/ZAAP-008-enforce-network-boundaries.md)
- [ZAAP-009: Secure shared Redis access](tasks/planned/ZAAP-009-secure-redis.md)
- [ZAAP-010: Isolate Argo CD projects](tasks/planned/ZAAP-010-isolate-argocd-projects.md)

## Runtime operations

- [ZAAP-011: Pin the runtime supply chain](tasks/planned/ZAAP-011-pin-runtime-supply-chain.md)
- [ZAAP-012: Harden workload runtime contracts](tasks/planned/ZAAP-012-harden-workload-runtime.md)
- [ZAAP-013: Add actionable production alerting](tasks/planned/ZAAP-013-add-actionable-alerting.md)
- [ZAAP-014: Rehearse secure cluster bootstrap](tasks/planned/ZAAP-014-rehearse-secure-bootstrap.md)
- [ZAAP-015: Run a deployment recovery drill](tasks/planned/ZAAP-015-run-deployment-recovery-drill.md)

## Follow-up hardening

- [ZAAP-016: Remove the static Cilium API host](tasks/planned/ZAAP-016-remove-static-cilium-api-host.md)
- [ZAAP-017: Centralize production logs](tasks/planned/ZAAP-017-centralize-production-logs.md)
- [ZAAP-018: Ingest API-server audit events](tasks/planned/ZAAP-018-ingest-api-audit-events.md)