# Active Task Lifecycle

`tasks/` contains only planned or active work. Completed task details remain in Git history after their outcomes are rolled into `PROJECT_STATUS.md`.

## States and ownership

Allowed `Status` values: `planned`, `running`, `blocked`, `ready-for-rollup`.

1. Allocate an immutable `ZAAP-NNN` ID by scanning `tasks/planned/` and `tasks/running/`.
2. To claim work, move `tasks/planned/ZAAP-NNN-<slug>.md` to the same filename under `tasks/running/`, change `Status: planned` to `Status: running`, and set `Owner`. Land that claim before implementation branches or worktrees diverge.
3. Before claiming, verify every `Depends on` task has been rolled up. Compare `Owned paths` with all running tasks. Overlap means the work must be serialized.
4. A blocked task remains under `tasks/running/` with `Status: blocked` and a concrete unblock condition under `## Blockers`.
5. An implementation agent edits only its owned paths and task handoff. It sets `Status: ready-for-rollup` only after every acceptance criterion and focused verification passes.
6. The rollup owner reviews ready tasks, merges them one at a time, runs `./scripts/validate.sh`, updates `PROJECT_STATUS.md`, and removes the rolled-up task file.

## Task design

- One observable production behavior per task.
- Prefer one source subtree and its matching generated artifact subtree.
- Include exact acceptance criteria and commands with expected observations.
- Declare dependencies instead of sharing paths between parallel tasks.
- Security and migration tasks must include rollback or recovery evidence.
- A task may not claim all of `manifests/`, `artifacts/`, or `scripts/` unless it is an explicitly serialized repository-wide migration.

## Generated path ownership

A task changing `manifests/<layer>/<component>/` also owns `artifacts/<layer>/<component>/`. List both paths. Changes to an app-of-apps registry require ownership of that exact registry file and its rendered Application artifact.

## Rollup order

Roll up dependency and policy changes first, then component changes. Never combine unrelated ready tasks to save a merge; isolated commits preserve rollback boundaries.
