# ZAAP-010: Isolate Argo CD projects

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** none
- **Risk:** high

## Owned paths

- `manifests/infrastructure/infrastructure-app-of-apps/`
- `manifests/application/application-app-of-apps/`
- `artifacts/infrastructure/infrastructure-app-of-apps/`
- `artifacts/application/application-app-of-apps/`

## Goal

Replace the unrestricted `default` Argo CD project with explicit infrastructure and application source, destination, namespace, and resource boundaries.

## Implementation

1. Define separate AppProjects with the single trusted repository and expected cluster destination.
2. Allow cluster-scoped resources only to infrastructure and enumerate required kinds.
3. Restrict application destinations to managed namespaces and deny privileged cluster-scoped kinds.
4. Move Applications in dependency-safe sync waves and verify existing reconciliation.

## Acceptance criteria

- [ ] Application workloads cannot create cluster roles, CRDs, namespaces, or deploy outside approved namespaces.
- [ ] Infrastructure cannot source manifests from an unapproved repository or revision.
- [ ] Both app-of-apps trees remain healthy and synced after cutover.
- [ ] A negative test Application is rejected by project policy.

## Verification

```bash
./scripts/validate.sh
argocd app lint <negative-test-application>
```

Expected: repository validation passes and the negative project-boundary test is rejected.

## Blockers

Requires an inventory of cluster-scoped kinds used by infrastructure and operator access to observe staged Argo CD sync.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** retain the old project assignment until each replacement project is healthy
- **Follow-ups:** none
