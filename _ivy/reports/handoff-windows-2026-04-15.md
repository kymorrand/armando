# Handoff — Windows — 2026-04-15

- **Machine:** Kyle's Windows PC
- **Project:** tennis-social-platform
- **Branch:** `feature/serv-107-combine-session`

## What was done

Sprint 1 Phase 2 deploy-gate build for tomorrow's (2026-04-16) simulator
test. Two Canopy dispatches, both on the single sprint contract
`_grove/sprints/contract-canopy-serv-108-109-110-drills.md`:

1. **Code build — commit `76c9d6f`** — Programmatic US Open blue half-court
   (`CombineCourtBuilder`) + concrete `CombineTarget` (required because
   base `Target` is abstract) + the three real drills:
   - `CalibrationDrill` (SERV-108) — 12 balls, 4-zone diamond at service T
   - `RallyIQDrill` (SERV-109) — 18 balls, 3 phases (FH/BH/Alt), corridor targets
   - `ClutchDrill` (SERV-110) — 8-ball streak, shrinking target, color escalation
   - `DrillJsonOutput` — shared `[Serializable]` data + writer to
     `{persistentDataPath}/combine_results/*.json` + `Debug.Log`
   - `CombineSession.cs` +8 lines: `_courtBuilder` SerializeField + public property.

2. **Scene wiring — commit `c660a53`** — Canopy edited `Combine_Gameplay.unity`
   YAML directly (one-off exception, Kyle-authorized) to save Inspector
   clicks. Added Backboard GameObject + CombineCourtBuilder GameObject +
   wired `CombineSession._courtBuilder`. Layer bits verified against
   `TagManager.asset` (Target=128/index 7, CollisionBackBoard=64/index 6).
   Manifest `implementationType` strings updated to drop `Stub` suffix.
   `Combine_Gameplay.unity` registered in `EditorBuildSettings`. Seven
   `.meta` files for the new `.cs` files tracked.

Garden report: `_grove/reports/garden-2026-04-15.md`.
Sprint contract Outcome section filled in.

## Architecture decision

**Option A** chosen: court geometry on the vertical backboard plane.
Targets coplanar with the wall, existing impact pipeline unchanged.
**Option B** (3D floor court with ball arc projection) queued as Phase 2
upgrade if Option A plays well tomorrow.

## In progress

Nothing. Code and scene wiring are committed. Waiting on Kyle's smoke
test on Unity 6.3 LTS.

## Next steps

1. **One Inspector click** — open `GameLauncher.unity`, drag
   `Assets/Steamroller/Data/Combine_GameConfig.asset` into
   `ApplicationManager.configs[]`, save scene. This is the ONLY remaining
   manual Editor step.
2. Confirm Unity 6.3 LTS compile is clean.
3. Press `C` in GameLauncher — full Calibration → Rally IQ → Clutch
   sequence should run on the US Open blue court.
4. Collect JSON outputs from `{persistentDataPath}/combine_results/` and
   verify schemas match `DrillJsonOutput.cs`.
5. If smoke test passes: tag feature branch, open PR into
   `staging/sprint-1-port`, run on the physical simulator.
6. Move Linear SERV-108, SERV-109, SERV-110 from "In Review" to "Done".

## Blockers

- **Unity compile not yet verified.** Thorn's Greenhouse host has no Unity
  install. Kyle verifies on Windows tomorrow.
- **Backboard placement is placeholder.** Backboard GameObject sits at
  world `(0, 0, 5)` with a 12×8×0.2 BoxCollider. Kyle should adjust to
  match the physical simulator geometry before the sim test.
- **Shader warning.** `Shader.Find("Unlit/Color")` works in Editor but
  requires the shader in `Always Included Shaders` for non-dev player
  builds. Fallback to `Standard` is wired but visual parity would drift.
  Non-blocking for tomorrow (Editor play), blocking if we make a player
  build for the sim PC.

## Uncommitted noise on branch

A large batch of Unity 6.3 LTS serialization drift (Art materials, Rocks,
Subway, PowerUps, Effects, BrickBreak_Gameplay scene, GameLauncher scene
light/render settings, `ProjectSettings/ShaderGraphSettings`,
`ProjectSettings/SceneTemplateSettings`) is left uncommitted on the
working tree. Deliberately NOT in this sprint's commits — belongs in a
separate Unity-upgrade commit when Kyle is ready. `git status` at session
end shows these as `M` entries, also several untracked `.csproj`, `.sln`,
`.vscode/`, `.claude/`, `references/`, `editmode-results.xml`, and
`DefaultScene.meta` / `URP.meta` / `_Textures.meta` / `Ball.meta` files
that Unity regenerated on project open.

## Linear

- **SERV-107** — Done (delivered earlier).
- **SERV-108, SERV-109, SERV-110** — In Review until Kyle confirms smoke test.
