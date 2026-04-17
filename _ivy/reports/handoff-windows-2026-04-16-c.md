# Handoff — Windows — 2026-04-16 (evening stop)

- **Machine:** Kyle's Windows PC
- **Project:** tennis-social-platform
- **Branch:** `feature/serv-107-combine-session`
- **Lead:** Thorn
- **Dispatched:** Canopy (R14 + R15 this session, layered on R4–R13 from earlier in the day)
- **Continues:** `handoff-windows-2026-04-16-b.md` (evening continuation) and the R4–R13 rounds dispatched earlier today
- **Stopping point:** Clean pause. No in-flight work. Awaiting Kyle's combined smoke test tomorrow.

## What Was Done This Session

Two Canopy dispatches landed, both pass / zero revisions. Details live in the garden report — this file is the cross-machine summary.

### R14 — Combine 3D playability pass
Kyle's 138-second smoke-test video surfaced four coupled blockers. All four fixed in one dispatch:

1. **Hit detection silently failing (0/12 hits).** `GROUND_CONTACT_Y_THRESHOLD = 0.1f` sat on a floating-point knife edge with the FloorCollider's top face (`size.y=0.2m` centered at `y=0` → top at `y=0.1m`). CCD jitter pushed contact points to `y≈0.10001` which were silently rejected. Threshold raised to `0.3f` (0.2m buffer above floor top). Comment rewritten to document the FloorCollider geometry dependency.
2. **Ball depth illegible.** Added drop shadow: sibling `Quad` under the ball's parent, 0.30m diameter, URP black 50% alpha, tracked via `LateUpdate` (after physics step), destroyed with ball in `LifetimeCoroutine`.
3. **Inactive cubes invisible on blue court.** `DIM_ALPHA` raised `0.3 → 0.7` in Calibration. New mirrored `INACTIVE_ALPHA = 0.7f` const in RallyIQ (Canopy introduced this — good judgment call).
4. **Velocity defaults too aggressive.** Code defaults re-synced to Kyle's Inspector tuning (`_forwardSpeedFlat 12→6`, `_forwardSpeedLob 6→3`). Flat/lob height window widened (`_flatShotHeight 0.5→0.0`, `_lobShotHeight 2.5→3.0`) so the full camera y-range maps to the flat↔lob interpolation curve.

### R15 — ClutchDrill target position
Kyle's R14 smoke test reached drill 3 and flagged the 2m cube "in the wrong spot" — half-poking onto the player side of the net. Screenshot analysis + code read: `ClutchDrill.CreateTarget()` used `_court.CourtCenter` which in `CombineCourtBuilder3D` resolves to `transform.position` — the court-builder's transform origin at the net plane (`z=0` in court-local coords). With `INITIAL_SCALE = 2.0f` the cube straddled the net. **Fix:** one-line swap `CourtCenter → ServiceLineCenter` in `ClutchDrill` — the "T" anchor, same one Calibration uses. Did NOT modify the `CourtCenter` property in either builder — dimension-agnostic invariant preserved.

## Commits This Session

**None.** All R4–R15 work is uncommitted in the working tree per the standing "Kyle smoke-tests first" contract rule. Eleven atomic commits are planned for tomorrow layered on HEAD = `4b42fb4`:

1. R4 — log fixes (InputManager NPE + quaternion normalization)
2. R5 — net-plane click collider
3. R6 — click-plane trigger flip
4. R7 — SerializeField launch velocity
5. R8 — height→arc interpolation
6. R9 — target visibility sign fix
7. R11 — URP runtime color toggle (`SetBaseColor` + 12 call sites)
8. R12 — volumetric cube targets + trigger hit detection
9. R13 — low-profile markers + ground-contact hit detection
10. R14 — playability pass (threshold + shadow + alpha + velocity retune)
11. R15 — ClutchDrill target anchor

(R10 is already committed as `4b42fb4` — the morning URP fix.)

## In Progress

**Nothing.** This is a clean stopping point. No partial dispatches, no half-written code, no unresolved errors.

## Next Steps (tomorrow morning)

1. **Kyle smoke-tests the combined R10+R11+R12+R13+R14+R15 stack.** Expected observations:
   - Calibration hit detection reliable (not 0/12).
   - Inactive cubes visibly distinct from active.
   - Ball has tracking drop shadow.
   - Velocity feel matches Inspector values across full y-axis.
   - ClutchDrill target lands at the "T" on the far court.
2. **If smoke test passes** — sequence the 11 atomic commits. Pre-commit housekeeping: add `.canopy-compile*.log` to `.gitignore` so future diagnostic runs don't leak into working tree.
3. **If smoke test surfaces issues** — R16+ dispatches as needed. Current expectation bar: no net-new bugs.
4. **After commits land** — promote three queued rules to CLAUDE.md:
   - URP `_BaseColor` / `_Color` dual-write rule (from R10+R11)
   - Trigger↔bouncy-solid collider swap rule (from R12)
   - Combine 3D geometry invariants rule (from R14)
5. **File SERV-111** in Linear — the Combine 3D scene work issue, still a placeholder.

## Blockers

- **Kyle's combined smoke test.** That's the only blocker. Everything else is queued behind it.
- No external blockers. Canopy is idle. Bloom + Root untouched this session.

## Workspace State at Stop

- **HEAD:** `4b42fb4` (unchanged — R10 from this morning).
- **Uncommitted code (11 dispatches layered):** `CombineBall3D.cs`, `CombineCourtBuilder3D.cs`, `CombineMaterialHelper.cs`, `CombineTarget.cs`, `CalibrationDrill.cs`, `RallyIQDrill.cs`, `ClutchDrill.cs`, `InputManager.cs`, `Combine_Gameplay_3D.unity`, `CHANGELOG.md`.
- **Uncommitted docs:** `_grove/index.md`, `_grove/reports/status-canopy-2026-04-16.md`, 12 sprint contracts (R4–R15) as untracked files in `_grove/sprints/`.
- **Pre-existing noise:** ~40 `.mat` / `.asset` / `.prefab` Unity re-serialization diffs still in working tree (from prior session — exclude from commits unless Kyle asks).
- **Diagnostic artifacts cleaned:** `.canopy-compile.log` + `.canopy-compile-r15.log` deleted before stop.

## Agent Velocity

| Agent | This Session | Sprint Total |
|-------|--------------|--------------|
| Canopy | 2 dispatches, 0 revisions, ~50min total | 19/19 accepted (SERV-107), 1 revision (R13 comment cleanup), 1 protocol slip (R10 auto-commit — now covered in template) |

## Notes for Next Session

- The shell wrapper will auto-commit and push this handoff after exit. Just write the file.
- Garden report at `_grove/reports/garden-2026-04-16.md` has the full session narrative — read it alongside this handoff for details on R14's four coupled fixes and R15's one-line placement fix.
- The R13 "grep method/constant names in comments when changing values" rule is paying off — Canopy self-caught one stale comment during R14 self-review before reporting.
- Don't re-dispatch anything unless Kyle's smoke test flags something new. R14 + R15 were targeted at everything Kyle observed in the last video; expect them to resolve cleanly.
- If the Unity Editor is still holding the project lock when tomorrow's session starts, focus-switch it to trigger auto-compile before any smoke test.
