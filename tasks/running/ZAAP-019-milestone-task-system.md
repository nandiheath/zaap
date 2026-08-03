# ZAAP-019: Adopt milestone-based task planning

- **Status:** running
- **Owner:** Main
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

- [ ] Repository guidance defines milestone-first planning and completion gates.
- [ ] Task and milestone templates are present under `tasks/`.
- [ ] Existing planned tasks reference milestones.

## Verification

```bash
source bin/activate-hermit
./scripts/validate.sh
```

Expected: rendering and validation complete without deployment.

## Blockers

None.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** not applicable
- **Follow-ups:** none
