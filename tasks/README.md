# Active milestone and task lifecycle

Task IDs use `ZAAP-NNN`; milestone IDs use `ZAAP-MNNN`. `tasks/` contains only planned or active contracts. Completed detail remains in Git history after rollup into `PROJECT_STATUS.md`.

## Milestone-first planning

1. Allocate an immutable milestone ID and create `milestones/planned/ZAAP-MNNN-<slug>.md` from `MILESTONE_TEMPLATE.md`.
2. Define one coherent production outcome, the complete child-task checklist, milestone acceptance criteria, risk/rollback invariants, and milestone-level verification.
3. Create every child from `TEMPLATE.md`, set `Milestone: ZAAP-MNNN`, and list it in the milestone. A future milestone reminder may have no child tasks until planning starts.
4. Move the milestone to `milestones/running/`, set `Status: running`, and name one milestone owner before claiming its first task.

## Child task claims

Allowed statuses are `planned`, `running`, `blocked`, and `ready-for-rollup`. Claim only dependency-ready work whose `Owned paths` are disjoint from every running task. Move the identical file from `planned/` to `running/`, set `Status: running`, and record one owner. Land the claim before creating one branch/worktree and one implementation agent for the task.

A task owns one observable production behavior. Prefer one source subtree and its matching generated artifact subtree. Security and migration tasks include rollback/recovery evidence. A task may not claim all of `manifests/`, `artifacts/`, or `scripts/` unless it is an explicitly serialized repository-wide migration.

A task changing `manifests/<layer>/<component>/` also owns `artifacts/<layer>/<component>/`. App-of-apps registry work owns the exact registry and rendered Application artifact.

## Completion and milestone gate

Implementation agents run focused proof, fill their handoff, and set `ready-for-rollup`. The serial rollup owner merges child tasks one at a time, checks them off in the milestone, and runs `./scripts/validate.sh`.

A milestone becomes `ready-for-rollup` only when every child task is rolled up and checked, no active child still references it, every milestone acceptance and rollback/security invariant is observed, and the milestone verification scenario passes. The owner records evidence, updates `PROJECT_STATUS.md`, and removes the completed milestone. Failed proof remains active or blocked.

Roll up dependency and policy changes before components. Never combine unrelated ready tasks. Validate lifecycle structure with `agent-workspace repo-tasks validate --root .` when available.
