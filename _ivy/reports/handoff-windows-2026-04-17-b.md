# Handoff — Windows — 2026-04-17 (late session)

- **Machine:** Windows (Kyle's PC, C:\Projects\MirrorFactory\tennis-social-platform)
- **Project:** tennis-social-platform
- **Agent:** Thorn
- **Session predecessor:** `handoff-windows-2026-04-17.md` (earlier same day)

## What Was Done

1. **SERV-107 Combine 3D sprint closed on paper and pushed.**
   - Committed 5 new CLAUDE.md "What NOT to Touch" rules promoted from
     the sprint's rule-watch list (URP `_BaseColor`/`_Color` dual-write,
     trigger↔collider swap deletion, delete-method comment sweep,
     floor-threshold-is-geometric, Unity runtime debug keybind grep).
     CLAUDE.md rule count: 8 → 13.
   - Wrote and committed `_grove/adrs/adr-004-2d-combine-depth-cue-parity.md`
     (decision: 2D Combine does NOT get depth-cue parity with 3D).
   - Wrote and committed `_grove/sprints/retro-combine-3d-serv-107.md`
     (velocity table: 25 dispatches, 1 revision, 25/25 pass, ~17 min avg;
     plan-vs-reality gaps; SERV-111 draft body inline).
   - Updated `_grove/index.md` Follow-ups section.
   - Commit: `ee3c063 docs: close out SERV-107 Combine 3D sprint`.
   - Pushed to `origin/feature/serv-107-combine-session`.

2. **Opened PR #1** from `feature/serv-107-combine-session` → `dev`:
   https://github.com/tennissocial/tennis-social-platform/pull/1
   - 57 commits, 1,093 files changed (mostly Unity 6.3 asset re-serialization).
   - Rolls up Unity 6.3 LTS upgrade + BrickBreak fixes + SERV-105
     (hardware capabilities) + SERV-106 (arcade lifecycle) + SERV-107
     (Combine chassis + R1–R21 3D) + SERV-108/109/110 (drills).
   - PR body calls out real reviewable surfaces explicitly so the
     asset-churn doesn't drown out the actual code.
   - **Parked** — Kyle wants to come back to it later for the Unity-side
     Editor open / compile / Combine smoke / BrickBreak + arcade
     regression checks listed in the PR's Test Plan.

3. **Drafted Phase 1 Stability sprint plan.**
   - `_grove/sprints/plan-phase1-stability.md` — 4 dispatches in 3 waves:
     - Wave 1 PARALLEL: Root P1-1 (Catch2 C++ test harness) ‖ Canopy P1-2
       (Unity NetworkInput exponential-backoff reconnection).
     - Wave 2: Root P1-3 (startup/shutdown orchestration scripts).
     - Wave 3: Root P1-4 (health check script).
   - Deferred to next sprint: 4-hour soak test harness, Unity GameObject
     lifecycle audit, Python tracker reconnection, DMX overwrite decision
     (ADR-005 candidate).
   - Branch strategy: `feature/phase1-stability` from `dev` — verified
     zero file overlap with PR #1 (no commits on serv-107 touched
     `NetworkInput.cs`, `scripts/`, or `control-server/src/`+`include/`).
   - `_grove/sprints/contract-root-p1-1-cpp-test-harness.md` drafted
     with ≥13 tests target, Catch2 via FetchContent, refactor allowance
     for a surgical pure-helper extraction out of `SafetySystem.cpp`.
   - **NOT DISPATCHED.** Kyle paused to do a broader re-architecture +
     test-strategy planning session before implementation starts.
   - Both planning docs marked `DRAFT / DO NOT DISPATCH` in their
     headers so a future session doesn't accidentally fire them.

4. **Audit findings I surfaced during planning** (for Kyle's re-arch session):
   - C++ control-server: Sprint 1 port already fixed the 3 critical audit
     bugs (SafetySystem race, ScoreboardManager JSON, dead websocket
     lock). Audit's "must-do" list had those + 5 other Phase 1 items;
     4 still open (Unity reconnect backoff, orchestration scripts,
     health check, 4-hour soak) + 1 Lobster-blocked (ESP32 watchdog).
   - Gap audit didn't flag: **zero C++ tests exist** for the
     control-server. `hardware_capabilities.py` has pytest; the server
     itself has nothing.
   - Gap audit flagged but port didn't fix: `ControlServer.cpp:162`
     still force-overwrites every DMX message to `"LGENERALIMPACT"`.
     Needs a decision (intentional debug code or real bug?) — ADR-005
     candidate.
   - Unity `NetworkInput.cs` (739 lines): has ad-hoc reconnection
     scattered across `EstablishConnection`, `ConnectCallback`, and
     the receive-loop error path — no exponential backoff, no single
     state machine.
   - Linear MCP: **still not surfacing.** Tried `ToolSearch` variants
     (`linear`, `+linear`, `linear create issue`, `select:`-form);
     only Notion (read-only Linear connector) and Gmail/Calendar/Drive
     show. SERV-111 filing remains manual — draft body is in the sprint
     retro doc.

## In Progress

- **Phase 1 Stability sprint planning — paused.** Kyle asked to zoom
  out for a re-architecture + test strategy conversation before any
  implementation. Draft docs preserved, marked DO NOT DISPATCH.
- **PR #1 Unity-side checks — parked by Kyle.** Test Plan items 2/4/5
  (Editor open, BrickBreak regression, arcade regression) don't need
  projection hardware and could run at Kyle's desk when he comes back;
  item 3 (Combine 3D full smoke) is venue-bound.

## Next Steps (when Kyle returns)

1. **Re-architecture + test strategy session.** Kyle has opinions about
   how the 8-hour-readiness story should be structured that the current
   draft plan doesn't capture. Expect the draft to change. Don't dispatch
   from the current plan — re-issue fresh contracts after the session.
2. **PR #1 resolution.** Either Kyle runs the Unity-side regression
   checks at his desk and we merge (venue smoke deferred), or we wait
   for venue access and run the full smoke before merge.
3. **SERV-111 filing.** Still manual. Draft body in
   `_grove/sprints/retro-combine-3d-serv-107.md`. If Linear MCP comes
   online in a future session, Thorn can backfill.

## Blockers

- **Re-architecture session** — blocks sprint dispatch. Kyle-owned.
- **PR #1 Unity-side checks** — Kyle-owned.
- **Linear MCP tool surface** — unblocks SERV-111 filing; currently
  no workaround beyond manual paste.
- **Projection hardware access** — blocks full R16–R21 Combine 3D
  smoke test. Not on critical path for Phase 1 stability.

## Key Files to Re-Read Next Session

- `_grove/index.md` — updated this session; top lines describe current stance.
- `_grove/sprints/plan-phase1-stability.md` — DRAFT, expect scope
  changes after Kyle's re-arch session.
- `_grove/sprints/contract-root-p1-1-cpp-test-harness.md` — DRAFT,
  preserved for reference; reissue fresh contracts after re-arch.
- `_grove/sprints/retro-combine-3d-serv-107.md` — sprint retro with
  SERV-111 draft body for manual Linear paste.
- `docs/audit/00-EXECUTIVE-SUMMARY.md` — audit's Phase 1 must-have list.
- `docs/audit/02-control-server.md` — C++ server detailed audit;
  useful context for the re-arch conversation.

## Git State at Handoff

- Branch: `feature/serv-107-combine-session`
- HEAD: `ee3c063` (docs closeout, pushed)
- PR #1 open: `feature/serv-107-combine-session` → `dev`
- Working tree status at handoff write time: clean except the two new
  DRAFT sprint docs in `_grove/sprints/` — **will be committed before
  session ends** so the next session sees them immediately.

## Rules / ADRs Landed This Session

- No new CLAUDE.md rules (five were added in the earlier session today).
- No new ADRs (ADR-004 landed in the earlier session).
- **Rule under watch (not promoted):** Unity `PrimitiveType.Quad`
  default normal direction — one instance (SERV-107 R21 net flip) not
  yet enough to codify. Watch for recurrence.
