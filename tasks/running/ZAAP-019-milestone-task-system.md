# ZAAP-019: Adopt milestone-based task planning

- **Status:** ready-for-rollup
- **Owner:** Main
- **Milestone:** ZAAP-M002
- **Depends on:** none
- **Risk:** low

## Owned paths

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `tasks/`

## Goal

Adopt the canonical milestone-first planning lifecycle while preserving generated-artifact and production-safety rules.

## Implementation

1. Add milestone contracts and require every planned task to reference one.
2. Standardize task and milestone templates with milestone-level verification.
3. Group the existing production-readiness backlog under explicit milestones.

## Acceptance criteria

- [x] Repository guidance defines milestone-first planning and completion gates.
- [x] Task and milestone templates are present under `tasks/`.
- [x] Existing planned tasks reference milestones.

## Verification

```bash
source bin/activate-hermit
./scripts/validate.sh
```

Expected: rendering and validation complete without deployment.

## Blockers

None.

## Completion handoff

- **Summary:** Added milestone-first planning, templates, child-task references, and rollup gates while preserving production and generated-artifact policy.
- **Files changed:** `AGENTS.md`, `tasks/README.md`, task templates and metadata, and milestone contracts under `tasks/milestones/`.
- **Observed verification:** `agent-workspace repo-tasks validate --root .` passed; `./scripts/validate.sh` rendered 409 resources with 283 valid, 0 invalid, 0 errors, and 126 skipped schemas.
- **Rollback/recovery:** not applicable
- **Follow-ups:** none
