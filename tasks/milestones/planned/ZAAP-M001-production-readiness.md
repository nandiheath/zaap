# ZAAP-M001 — Reach production readiness

- Status: planned
- Owner: unassigned
- Risk: high

## Goal

Close the repository's confirmed reproducibility, data protection, security-boundary, supply-chain, and operational-readiness gaps.

## Tasks

- None yet; create repository-scoped child tasks only after reviewing the current `main` branch and accepting their dependencies, ownership, and rollout order.

## Acceptance criteria

- [ ] Every confirmed critical and high repository gap has rolled-up evidence or an explicit blocked condition.
- [ ] Data protection, network/security, supply-chain, observability, bootstrap, and recovery behavior are verified without inferring live state from static validation.

## Verification

- Scenario or command: run `source bin/activate-hermit && ./scripts/render.sh`, verify generated artifacts are stable, and execute the milestone's authorized disposable-cluster recovery scenarios.
- Expected observation: desired state is reproducible, security invariants hold, and recovery evidence is observed without CI deployment credentials.

## Blockers

- Live and disposable-cluster scenarios require their child-task authorization and environments.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Rollback/recovery:
- Follow-ups:
