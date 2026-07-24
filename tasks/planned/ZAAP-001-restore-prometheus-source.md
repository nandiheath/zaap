# ZAAP-001: Restore reproducible Prometheus source

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/infrastructure/prometheus/`
- `artifacts/infrastructure/prometheus/`

## Goal

Make every committed Prometheus artifact reproducible from reviewed source.

## Implementation

1. Identify the chart, version, values, namespace, and release name that produced the current artifact.
2. Recreate the missing Kustomize/Helm source with an explicitly pinned chart version.
3. Compare the rendered output with the deployed contract; document intentional drift rather than copying generated YAML into source.

## Acceptance criteria

- [ ] A clean render creates `artifacts/infrastructure/prometheus/` from source.
- [ ] The source declares the current scrape, retention, storage, and ingress assumptions.
- [ ] No generated Secret or credential value is committed.

## Verification

```bash
./scripts/validate.sh
git diff --exit-code -- artifacts/infrastructure/prometheus/
```

Expected: validation passes and a second render has no Prometheus diff.

## Blockers

Requires live Argo CD and Prometheus configuration inspection if the current artifact cannot establish provenance.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** retain the previous artifact revision for Git rollback
- **Follow-ups:** none
