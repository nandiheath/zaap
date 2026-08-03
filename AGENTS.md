# Zaap Agent Guide

## Session protocol

Before editing:
1. Read `PROJECT_STATUS.md`, `tasks/README.md`, the parent milestone, and the child task.
2. Planning creates a milestone before child tasks; every spawned task references it and appears in its checklist.
3. Scan only the manifests, scripts, or workflow files relevant to the task.
4. Claim planned work using `tasks/README.md`: verify dependencies and path ownership, move the child to `tasks/running/`, and set `Status` and `Owner`.
5. Activate the pinned toolchain with `source bin/activate-hermit`.

During task work:
- Edit only the task's declared owned paths and completion handoff.
- Treat `manifests/` as source and `artifacts/` as generated output. Never hand-edit rendered artifacts.
- Render and validate the affected source before handoff.
- Do not read or copy files under `credentials/`. Never put secret values in Git, logs, task files, or command arguments.
- Do not mutate the cluster directly. The only exception is an explicitly assigned bootstrap or recovery task with a documented rollback path.
- Do not change shared status, CI, dependency policy, or another task file unless the task owns it.

After implementation:
1. Regenerate the owned artifact subtree.
2. Run the focused verification in the child task.
3. Complete the task handoff, set `Status: ready-for-rollup`, and stop without editing the milestone.
4. The rollup owner merges children serially, checks them off in the milestone, runs repository and milestone-level verification, updates `PROJECT_STATUS.md`, and removes successful contracts. A milestone is never done from child-task proof alone.

## Delivery model

```text
manifests/ -> scripts/render.sh -> artifacts/ -> protected main -> Argo CD -> cluster
```

- `manifests/infrastructure/` contains cluster services and the infrastructure app-of-apps.
- `manifests/application/` contains workloads and the application app-of-apps.
- `artifacts/` is committed because Argo CD consumes rendered YAML from this repository.
- `scripts/render.sh` performs environment interpolation, Kustomize, and Helm rendering.
- Argo CD is the deployment credential holder. GitHub Actions validates desired state; it does not receive cluster credentials.
- Bootstrap resources are the narrow exception to GitOps and are applied by `scripts/bootstrap.sh`.

## Security invariants

- Only `${ARGOCD_GITHUB_REPO}`, `${ARGOCD_GITHUB_ORG}`, `${VAULT}`, and `${ARGOCD_ADMIN_GITHUB_USER}` may be interpolated. `config/.env` contains identifiers, never credentials.
- Runtime secrets come from 1Password through External Secrets. Generated Secret manifests or plaintext credentials are prohibited.
- GitHub Actions must use least-privilege `GITHUB_TOKEN` permissions and immutable full commit SHAs for third-party actions.
- Deployments flow only from reviewed, validated commits on `main`; workflows must not call `kubectl`, Argo CD APIs, or cloud provider deploy APIs.
- Automated dependency updates require CI and human review. No automerge for major versions, container digests, or cluster-critical components.

## Verification

For planning-contract changes, run:

```bash
agent-workspace repo-tasks validate --root .
```

For manifest or dependency changes, activate Hermit, run the existing renderer, and review the exact generated artifact subtree:

```bash
source bin/activate-hermit
./scripts/render.sh
git diff --exit-code -- artifacts/
```

A bootstrap/recovery task must also provide a targeted dry run or a disposable-cluster check. Live-cluster health is not inferred from successful static validation.
