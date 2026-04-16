# Handoff — Windows — 2026-04-16

- **Machine:** Kyle's Windows PC
- **Project:** tennis-social-platform
- **Branch:** `feature/serv-107-combine-session` (pushed, in sync with origin)
- **Lead:** Thorn
- **Dispatched:** Canopy (four dispatches, all accepted)

## What Was Done

Three-phase sprint closing out the Combine mode milestone and scaffolding the Phase 2 3D version so Kyle can smoke-test tomorrow.

### Phase A — Milestone lock (2D Combine)

Canopy's round-4 polish committed as `9af406d`:
- 3-second session-end hold before scene tears down (was instantaneous, Kyle described as "very abrupt").
- Programmatic "Combine Complete" TextMesh overlay spawned above the court at `GetCourtPosition(0.5, 0.6)`.
- OnDestroy cleanup so the overlay can't leak into GameLauncher if Kyle quits mid-hold.

Outcome contract backfill: `40fcd5c`. Tagged `milestone/combine-2d-v1`. This is the scene Kyle uses tomorrow to calibrate simulator cameras — it stays in-project permanently.

### Phase B — 2D rename

`git mv Combine_Gameplay.unity → Combine_Gameplay_2D.unity`, committed as `d275ca1`.
- `EditorBuildSettings.asset` also updated (scope expansion Canopy flagged, accepted — without it the build would point at a missing path).
- Kyle's unstaged Editor-side tweaks (URP `UniversalAdditionalLightData`, panel size 1000×600 → 1500×800, `_autoReturnSeconds: 6`) were preserved through the rename and committed with it.

### Phase C1 — 3D code scaffold

Committed as `937d16f`. 8 files:

**New:**
- `ICombineCourtBuilder.cs` (58 lines) — shared interface. `CourtTransform` property instead of `transform` (avoids MonoBehaviour clash). `BuildCourt` deliberately NOT on the interface — concrete classes own lifecycle (Canopy's literal read; accepted).
- `CombineCourtBuilder3D.cs` (394 lines) — horizontal floor builder. Coordinate convention: `nx=0` left wing (−X), `nx=1` right wing (+X), `ny=0` net (near edge, player's side), `ny=1` far baseline. ITF dimensions 10.97m × 11.885m. Builds floor quad + 10 line segments + vertical net strip at ny=0 (0.914m tall) + dark backstop wall at ny=1 (3m tall, 2m overhang). Floor quad is visual-only; `FloorCollider` GameObject handles raycast.
- `CombineBall3D.cs` (97 lines) — sphere primitive at real tennis-ball diameter (0.065m), unlit yellow, `Launch(entry, landing, duration=0.4)` = Lerp + `sin(π·t)` parabolic arc, self-destroys on landing. Phase 1 visual only — SERV-10 (ball-speed CV) will swap this for real ballistics.

**Modified:**
- `CombineCourtBuilder.cs` (the 2D one) — added `: ICombineCourtBuilder` and `CourtTransform` property.
- `CombineSession.cs` — added `[SerializeField] CombineCourtBuilder3D _courtBuilder3D`; `CourtBuilder` became a polymorphic interface property resolving whichever concrete field is non-null; routing updated in `BeginSession`, `SpawnCompleteTextOverlay`, `CompleteSessionAfterHold`.
- `CalibrationDrill.cs`, `RallyIQDrill.cs`, `ClutchDrill.cs` — retyped `_court` field from `CombineCourtBuilder` to `ICombineCourtBuilder`; 7 call sites of `_court.transform` → `_court.CourtTransform`.

### Phase C2 — 3D scene + GameConfig + V keybind

Committed as `a9b9982`. 11 files (8 new + 3 modified):

**Scene (surgical copy of 2D with targeted field swaps):**
- `Combine_Gameplay_3D.unity` + `.meta` — Main Camera at `(0, 6, -5)`, quaternion `(0.2419, 0, 0, 0.9703)` for 28° pitch down, background `(0.05, 0.06, 0.08, 1)` near-black. GameObject `Backboard` renamed `FloorCollider`, moved to `(0, 0, 5.9425)`, BoxCollider resized to `(10.97, 0.2, 11.885)`, layer 6 preserved. GameObject `CombineCourtBuilder` renamed `CombineCourtBuilder3D` with script GUID swapped to `c3d7b81442e05a449a3f6c0b8f2d4e17`. `CombineSession._courtBuilder: {fileID: 0}`, `_courtBuilder3D: {fileID: 8123456006}`.

**Config:**
- `Combine3D_SceneCollection.asset` + `.meta` — references `Combine_Gameplay_3D.unity`.
- `Combine3D_GameConfig.asset` + `.meta` — `gameName: "Combine3D"`, references the new SceneCollection.

**Hand-authored stable-GUID meta files** (so scene YAML refs resolve before Unity's first auto-import):
- `CombineCourtBuilder3D.cs.meta` → `c3d7b81442e05a449a3f6c0b8f2d4e17`
- `CombineBall3D.cs.meta` → `b3d9a62553f17b55ab4e7d1c9e3f5a28`
- `ICombineCourtBuilder.cs.meta` → `a1c5d73624e28c36bc5f8e2d0f4a6b39`

**Modified:**
- `ApplicationManager.cs` — V keybind handler after C; `CreateCombine3DSession()` filters `configs[]` by name `"Combine3D"`.
- `EditorBuildSettings.asset` — both 2D and 3D scenes listed and enabled.
- `CHANGELOG.md` — entry added.

## Commits (all pushed)

1. `9af406d` — Hold Combine session end 3s before scene transition
2. `40fcd5c` — docs(grove): Combine polish round 4 outcome
3. `d275ca1` — Rename Combine_Gameplay scene to Combine_Gameplay_2D
4. `937d16f` — Scaffold Combine 3D code layer
5. `a9b9982` — Add Combine 3D scene, GameConfig, SceneCollection, and V keybind
6. Tag: `milestone/combine-2d-v1` at `9af406d`

## In Progress

Nothing in flight. Sprint closed cleanly.

## Next Steps (tomorrow, Windows)

**1. One-time Inspector wire-up (required before V works):**
- Open Unity, load `GameLauncher.unity`.
- Select the `ApplicationManager` GameObject in hierarchy.
- Drag `Assets/Steamroller/ScriptableObjects/Combine3D_GameConfig.asset` into the `configs[]` array.
- Save the scene.

Without this, V logs `"no GameConfig named 'Combine3D' found"` and does nothing.

**2. Smoke test:**
- `git pull` → let Unity import the new files.
- Play `GameLauncher`.
- Press `C` → verify 2D Combine still works (this is Kyle's camera-calibration path).
- Press `V` → verify 3D Combine launches:
  - Horizontal US Open blue floor visible
  - White court lines (baseline, service, center, sidelines) visible on floor
  - Dark net strip visible at near edge
  - Dark backstop wall visible at far edge
  - Drill transition screens show in order (Calibration → Rally IQ → Clutch)
  - Targets spawn on horizontal floor surface
  - Ball sphere arcs from net entry to target on hit
  - JSON scoring events emitted to control server
  - After last drill, scene holds 3s on "Combine Complete" overlay then returns to GameLauncher

**3. Linear:** File SERV-111 (Combine 3D mode) — still a placeholder.

## Blockers

None for code. One human-action gate: Inspector wire-up above.

## Notes for Next Session

- Working tree has ~40 unrelated `.mat` / `.asset` / `.prefab` modifications — pre-existing noise from Unity Editor re-serializing assets. Exclude from commits unless Kyle asks.
- `_grove/index.md` was missing; created this session from `~/armando/templates/grove-index.md`. All six commit summaries in Recent Reports.
- Protocol slip to remember: Round-4 session-end hold was dispatched during a context-compaction boundary — contract (`contract-canopy-combine-polish-round-4-session-hold.md`) was written *after* dispatch, not before. Do not repeat.
- Canopy's three accepted deviations this sprint (BuildCourt-not-on-interface, EditorBuildSettings scope expansion, SpawnCompleteTextOverlay interface migration) were all semantic-correctness fixes. Flag in outcome, don't penalize.

## Rules Added This Session

None. All protocol slips this sprint are covered by existing CLAUDE.md rules; Canopy's deviations were accepted-with-note rather than mistakes.
