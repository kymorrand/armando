# Handoff — Windows PC — March 25, 2026 (Session B)

## Machine
Kyle's Windows PC (Unity 6.3 LTS Editor)

## Project
Tennis Social — game-client (Unity/C#)

## Branch
`staging/sprint-1-port` @ commit `d55bbfa`

## What Was Done

### BrickBreak Runtime Fixes (continued from Session A)
This session focused on getting BrickBreak mode playable for the Phase 1 checkpoint (March 27).

**Commits this session:**
1. `2f98468` — **Fix 3 runtime bugs** (Canopy dispatch):
   - SceneTransitionUI singleton: duplicate overwrote `instance` then got destroyed, breaking FadeIn permanently. Fixed with early `return` after Destroy and `instance == this` guard in OnDestroy.
   - MessageFeedbackUIManager NullRef on every hit: unguarded `GetSession().CurrentGame.GetRound()` chain. Added null guards.
   - FeedbackListener OnDestroy NullRef during teardown: same chain, same fix.
   - Removed all `[StartupTrace]` diagnostic logging from Round, RoundSpawner, SceneTransitionUI.

2. `2bc0144` — **Fix CS0234**: `Debug.LogWarning` in `Steamroller.Gameplay.UI` namespace resolves to local `Debug` class. Fixed with `UnityEngine.Debug.LogWarning`.

3. `9c34fdf` — **Hide debug click indicator**: `lastClickIndicator` (black square) disabled in InputManager.Awake.

4. `87827af` → `7b147da` → `5921e8a` — **Brick visibility timing**:
   - Added `Round.HideAllLevels()` called from `GameMode.StartGame()` to hide spawners before countdown.
   - Attempted deferred spawning (after FadeIn) — FadeIn STILL doesn't complete despite singleton fix.
   - Final approach: spawn bricks in StartLevel + 2-second fallback timer if FadeIn never completes.

5. `0df532e` — **Fix CS0234**: `System.Collections.IEnumerator` in `Steamroller.Gameplay.System` namespace resolves to wrong System. Fixed with `global::`.

6. `d55bbfa` — **CLAUDE.md update**: Added namespace shadowing rules.

### CLAUDE.md Rules Added
- Use `UnityEngine.Debug` (fully qualified) in `Steamroller.Gameplay.UI` namespace
- Use `global::System` in `Steamroller.Gameplay.System` namespace

## Current State
BrickBreak is **mostly playable**:
- Bricks spawn and are hittable
- Countdown/instructions work, Space skips them
- Hit detection works with adjustable debug radius (MouseSpoofer Inspector)
- No more black square on hits
- No more pink materials

## In Progress / Known Issues
1. **SceneTransitionUI FadeIn never completes** — Singleton fix didn't resolve it. Deeper issue: possibly bad AnimationCurve config, Canvas ordering, or timeScale. Worked around with 2s fallback timer. Bricks appear slightly before they should (during fade that never clears).
2. **VirtualBallShooterCanvas + DebugCanvas** — Missing prefabs (GUIDs never in git). Non-blocking.
3. **ScatterShot_Star.shadergraph** — Missing shader, VFX error. Only matters if that powerup triggers.
4. **Kyle reported "still some issues"** at session end — specifics not captured. Need Kyle to document.
5. **.mat files dirty in working tree** — 39 Unity material files with line-ending changes from 6.3 upgrade. Not committed. Not breaking anything.

## Next Steps
1. **Kyle to document remaining issues** from latest test for next session
2. **Investigate FadeIn deeper** — Check SceneTransitionData asset in Inspector (FadeInCurve, TransitionColor). Check if Canvas is behind game camera. Check timeScale.
3. **Phase 1 checkpoint prep** (March 27) — Ensure all 4 game modes at least load without crashing
4. **Clean up .mat files** — Either commit them or add to .gitignore

## Blockers
- FadeIn root cause still unknown — may need Kyle to inspect SceneTransitionUI and SceneTransitionData assets in Unity Inspector
