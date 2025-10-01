# Chunk 16 — Testing, CI, and Release Prep

**Objective**  
Lock quality and prepare for distribution.

**Deliverables**
- Test matrix: unit + UI (key flows), coverage report
- CI workflow updates (resolve SPM, build, test)
- Release notes + TestFlight checklist

**Acceptance Criteria**
1. CI green on PRs with unit+UI tests.
2. Coverage meets agreed baseline (≥ 70% unit where meaningful).
3. Archive succeeds; TestFlight build created (manual trigger).

**Tasks for Codex**
- Add/adjust CI yml (scheme/workspace names as in repo).
- Produce RELEASE_NOTES.md and TESTFLIGHT_CHECKLIST.md.

**Tests**
- Ensure tests run headless in CI.
- Manual: create an archive and validate.

**Issue Seed:** _Chunk 16 — Testing, CI & Release_
