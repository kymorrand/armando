# Handoff — Windows — 2026-04-21

**Machine:** Windows PC (Kyle's dev box)
**Project:** Tennis Social Platform (`C:\Projects\MirrorFactory\tennis-social-platform`)
**Branch:** `feature/serv-107-combine-session`
**Lead:** Thorn
**Session type:** Dispatch-protocol demo + opportunistic follow-up hardening

---

## What was done

Kyle asked for a live walkthrough of the Thorn↔Canopy relationship and a quick runthrough of the dispatch-and-documentation protocol. Used a trivially-scoped Combine 3D color swap (court US Open blue → tennis-court green, ball tennis-yellow → red) that still exercised the real URP `_BaseColor` rule from CLAUDE.md. That demo spiraled into a genuinely useful session:

### 3 Canopy dispatches completed today

1. **Demo color swap** (`contract-canopy-demo-court-green-ball-red.md`) — pass-with-flag.
   - Canopy caught a Thorn verification error before shipping: the contract claimed the scene had no `_courtColor` override, based on a grep run against the wrong scene path (`Assets/Steamroller/Scenes/` instead of the real `Assets/Steamroller/Contents/Scenes/`). The real scene file had `_courtColor: (0.235, 0.388, 0.557)` — a scene-instance override that beats the source default at runtime.
   - Canopy did NOT silently edit the scene (CLAUDE.md forbids `.unity`-as-text edits). Instead reported the discrepancy with three resolution options. Protocol working as designed.
   - Resolution: Kyle component-Reset + Save on `CombineCourtBuilder3D` in Unity.

2. **Kyle's Reset revealed 5 rounds of latent scene drift + wiped 3 LayerMask fields.**
   - The save fixed: `_courtColor` → green (finally visible), `_netColor` alpha 0.9 → 0.4 (R20 intent never persisted), added `_simulatorBacklineColor` + `_playerMarkerColor` (R20), added R14 retuned velocities (`_upSpeedFlat=3`, `_upSpeedLob=9`, `_forwardSpeedFlat=6`, `_forwardSpeedLob=3`, `_flatShotHeight=0`, `_lobShotHeight=3`), removed pre-R8 dead fields (`_forwardSpeed=4`, `_upSpeed=6`).
   - Kyle re-selected the three wiped LayerMasks manually after Thorn pulled pre-reset values from the scene (bits 128→Target, 64→CollisionBackBoard).

3. **Post-107 LayerMask defensive defaults** (`contract-canopy-post-107-layermask-defensive-defaults.md`) — pass, 0 revisions, ~3 min wall.
   - Added `OnValidate()` + shared `TryAutoPopulateLayer(ref, name, fieldName)` helper on `CombineCourtBuilder3D.cs`.
   - Auto-repairs blank `_targetLayer` / `_floorLayer` / `_clickPlaneLayer` via `LayerMask.GetMask(name)` with `LogWarning` on success, `LogError` if the layer is missing from TagManager.
   - Runtime guard at top of `BuildCourt()` logs one `LogError` per still-blank required layer (doesn't short-circuit). `_backstopLayer` intentionally unguarded per its docstring.
   - Canopy flagged (not fixed): `CombineCourtBuilder.cs` (2D) and `InputManager.cs` have the same unguarded-LayerMask pattern.

4. **Demo color revert** (`contract-canopy-demo-color-revert.md`) — pass, 0 revisions, ~2 min wall.
   - Kyle requested full revert of the demo color swap after the walkthrough completed.
   - Court source default: tennis-court green → US Open blue (reverted).
   - Ball: all 4 hardcoded red sites → tennis-ball yellow (reverted).
   - Comments reverted (class docstring, `_playerMarkerColor` contrast note, gradient block, inline comments).
   - Post-107 LayerMask block in same file **preserved** (CHANGELOG `### Added` entry + source block both kept).
   - `CHANGELOG.md` demo `### Changed` entry removed; post-107 `### Added` entry kept.
   - Scene `_courtColor` override NOT reverted — preserved per scene-integrity rule; Kyle will handle in Unity manually if desired.

### Documentation updated

- Morning demo contract — Outcome filed as pass-with-flag, includes "Subsequent Revert" addendum linking to the revert contract.
- Post-107 contract — Outcome filed as pass, 0 revisions.
- Revert contract — Outcome filed as pass, 0 revisions.
- `_grove/reports/garden-2026-04-21.md` — full garden report including "Thorn Error" analysis, post-morning addendum, and two new rules under watch.
- `_grove/index.md` — banner updated end-of-session, Recent Reports table appended with all three dispatches, three rules under watch added.

### Rules under watch (not promoted to CLAUDE.md, on recurrence only)

1. **Scene-path verification** — if Thorn writes "verified via grep" in a contract, the grep must hit the real path, not an assumed path. Tennis Social scenes live under `Contents/Scenes/`, not `Scenes/`.
2. **`[SerializeField] LayerMask` fields without source defaults are scene-fragile.** OnValidate + GetMask + runtime-guard is the recommended treatment; promote if Reset failure surfaces on 2D builder or InputManager.
3. **Scene `[SerializeField]` drift across rounds.** When a dispatch adds/renames/deletes a SerializeField on a MonoBehaviour used in a committed scene, include a scene re-serialization step or explicitly flag the drift.

---

## In progress

Nothing actively in progress. All three dispatches closed cleanly, all paperwork filed.

### Working tree state (uncommitted)

```
 M CHANGELOG.md                                                                  # post-107 ### Added entry (demo ### Changed removed by revert)
 M _grove/index.md                                                               # end-of-session banner + Recent Reports updates
 M game-client/Assets/Steamroller/Code/Gameplay/Combine/CombineCourtBuilder3D.cs # post-107 OnValidate+guard only (+96/-0 vs HEAD)
 M game-client/Assets/Steamroller/Contents/Scenes/Combine_Gameplay_3D.unity      # Kyle's Reset+Save drift-fix (+9/-5 vs HEAD)
?? _grove/reports/garden-2026-04-21.md
?? _grove/reports/status-canopy-2026-04-21.md
?? _grove/sprints/contract-canopy-demo-color-revert.md
?? _grove/sprints/contract-canopy-demo-court-green-ball-red.md
?? _grove/sprints/contract-canopy-post-107-layermask-defensive-defaults.md
```

`CombineBall3D.cs` matches HEAD exactly (revert complete).

---

## Next steps

1. **Kyle decision: commit the working tree?**
   - **Option A (keep):** commit on `feature/serv-107-combine-session` as something like "chore(combine-3d): layermask defensive defaults + scene drift fix + demo paperwork". Preserves the real post-107 hardening + Kyle's scene save + today's Grove trail.
   - **Option B (split):** commit the code + scene fix as one commit (post-107 LayerMask + Kyle's scene save), Grove paperwork as a separate commit.
   - **Option C (drop code, keep paperwork):** discard `CombineCourtBuilder3D.cs` + scene changes as session drift, keep only Grove. **Not recommended** — the LayerMask defensive defaults are real value and the scene fix resolves 5 rounds of latent drift.

2. **Kyle decision: revert the `_courtColor` scene override?**
   - Scene still has `_courtColor: (0.133, 0.447, 0.282)` green from Kyle's Reset+Save mid-session. Source default is now US Open blue again (reverted). Runtime reads scene, so court will render green until:
     - Unity → open scene → `CombineCourtBuilder3D` → right-click `_courtColor` → Revert to Prefab Default (if Unity exposes it) OR set manually to `(0.235, 0.388, 0.557)` → Save scene.
   - Only needed if Kyle wants runtime-blue. The source-of-truth is correct either way.

3. **Candidate follow-up dispatch (queued, NOT approved):** Apply the OnValidate + guard pattern to `CombineCourtBuilder.cs` (2D) and `InputManager.cs` (`backboardCollisionLayer`, `targetCollisionLayer`). Canopy flagged both. Hold until the Reset failure mode recurs on either — per "stay tight" rule.

4. **Paused work (pre-existing):** Phase 1 Stability sprint re-architecture conversation. Plan is at `_grove/sprints/plan-phase1-stability.md` (DRAFT/PAUSED). Kyle paused before implementation; resume when Kyle is ready.

---

## Blockers

None. Nothing waiting on Kyle or external input except the two decisions above (commit strategy + optional scene override revert), both of which are cosmetic/organizational.

---

## Notes for next session

- **Greenhouse Unity version mismatch:** Canopy noted the Linux greenhouse has `6000.0.41f1` installed but the project requires `6000.3.11f1`, so batch-mode compile skipped on the greenhouse. Kyle's local Editor is the real compile gate. Not urgent — flagged for visibility only.
- **Unity project lock:** Every dispatch hit Kyle's open Unity Editor holding the project lock on batch compile. Canopy correctly did not retry blindly. This is normal for interactive sessions — just means Kyle's Editor auto-recompiles on focus.
- **SERV-107 paperwork:** Linear issue SERV-107 remains marked Done (from yesterday's close-out). Today's work is post-107 hardening + a demo; neither warranted reopening. If a SERV-111 (or similar) is wanted for the 2D/InputManager follow-up, it's filed only on Kyle's request.
- **Demo colors:** The scene still contains green court pixels if Kyle opens it. Everything else (source, ball, CHANGELOG, contracts) is back to pre-demo baseline.
