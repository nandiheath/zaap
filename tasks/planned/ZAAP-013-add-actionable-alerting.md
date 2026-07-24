# ZAAP-013: Add actionable production alerting

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-001, ZAAP-004, ZAAP-005
- **Risk:** medium

## Owned paths

- `manifests/infrastructure/prometheus/`
- `artifacts/infrastructure/prometheus/`
- `docs/runbooks/alerts/`

## Goal

Page an operator for user-impacting failures and stale backups with bounded noise and a linked recovery action.

## Implementation

1. Define service objectives for ingress, Argo sync, node/storage capacity, certificates, secrets, Immich, PostgreSQL, and backups.
2. Configure Alertmanager routing through an External Secret-backed receiver.
3. Add burn-rate or sustained-condition alerts with runbook links and inhibition rules.
4. Exercise one safe synthetic alert end to end and measure delivery time.

## Acceptance criteria

- [ ] Critical alerts cover failed delivery, unavailable ingress, expiring certificates, database health, volume health, and stale backups.
- [ ] Every page names impact, owner, and immediate action.
- [ ] The receiver credential never appears in Git or generated output.
- [ ] A synthetic alert reaches and resolves at the configured receiver.

## Verification

```bash
./scripts/validate.sh
amtool check-config <rendered-alertmanager-config>
```

Expected: configuration passes and the handoff records observed fire, delivery, acknowledgement, and resolution.

## Blockers

Requires restored Prometheus source, backup metrics, and an approved notification receiver.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** disable only the noisy rule or route, not monitoring globally
- **Follow-ups:** none
