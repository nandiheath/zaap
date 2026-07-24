# ZAAP-011: Pin the runtime supply chain

- **Status:** planned
- **Owner:** unassigned
- **Depends on:** ZAAP-003, ZAAP-006
- **Risk:** high

## Owned paths

- `manifests/application/`
- `manifests/infrastructure/`
- `artifacts/application/`
- `artifacts/infrastructure/`
- `renovate.json`

## Goal

Ensure every deployed image, chart, and remote manifest resolves to reviewed immutable content while retaining automated update proposals.

## Implementation

1. Replace floating image tags with tag-plus-digest references and pin every chart version.
2. Replace mutable remote Kustomize URLs with release assets whose integrity is pinned or vendored and provenance recorded.
3. Configure Renovate to update source pins without scanning generated artifacts.
4. Add an enforceable CI check that rejects new floating runtime dependencies.

## Acceptance criteria

- [ ] No deployed container uses `latest`, `stable`, an omitted tag, or a tag without a digest.
- [ ] Every Helm chart has an explicit version and every remote manifest has immutable provenance.
- [ ] Renovate proposes digest/version changes with release age controls and no automerge.
- [ ] CI rejects a deliberately introduced floating reference.

## Verification

```bash
./scripts/validate.sh
```

Expected: validation includes an immutable-reference check and passes for the complete rendered tree.

## Blockers

ZAAP-003 and ZAAP-006 prevent pinning dependencies that are intentionally being removed or migrated.

## Completion handoff

- **Summary:** pending
- **Files changed:** pending
- **Observed verification:** pending
- **Rollback/recovery:** revert component pins independently; never fall back to floating tags
- **Follow-ups:** none
