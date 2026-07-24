# ZAAP-015: Run a deployment recovery drill

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-004, ZAAP-005, ZAAP-006, ZAAP-010, ZAAP-013
- **Risk:** high

## Owned paths

- `docs/runbooks/deployment-recovery.md`
- `PROJECT_STATUS.md`

## Goal

Demonstrate that a bad reviewed deployment and a node/data failure can be detected, stopped, and recovered within declared objectives.

## Implementation

1. Define reversible failure scenarios for bad manifests, unhealthy workloads, database recovery, and volume recovery.
2. Exercise Git revert through CI and Argo CD, then separately exercise data restore in isolation.
3. Measure detection, decision, reconciliation, and recovery time.
4. Record gaps as new narrowly owned tasks rather than editing production during the drill.

## Acceptance criteria

- [ ] A bad manifest is blocked before merge and a bad-but-valid workload revision is recovered by reviewed Git revert.
- [ ] Argo CD does not require CI cluster credentials or an imperative deploy step.
- [ ] Database and volume restore procedures meet or revise the declared RPO/RTO.
- [ ] Alerting fires and resolves with no unexplained silent period.

## Verification

```bash
./scripts/validate.sh
```

Expected: static validation passes and the runbook contains timestamps and observed evidence for every recovery scenario.

## Blockers

Requires completed backup, target application, Argo isolation, and alerting work plus an approved maintenance window.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** each drill scenario starts from a verified backup and reviewed revert point
- **Follow-ups:** convert every unmet objective into a planned task
