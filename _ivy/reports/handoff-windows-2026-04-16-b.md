# Handoff — Windows — 2026-04-16 (evening continuation)

- **Machine:** Kyle's Windows PC
- **Project:** tennis-social-platform
- **Branch:** `staging/sprint-1-port`
- **Lead:** Thorn
- **Dispatched:** Canopy (multiple rounds across the day for Combine 3D physics fixes)
- **Continues:** `handoff-windows-2026-04-16.md` (the morning handoff that closed Phase C2)

## What Was Done This Session

Iterated on the Combine 3D mode after Kyle's smoke test exposed problems the morning sprint couldn't have caught (no playtime). Three rounds of fixes landed:

### Round 1 — Composition + physics + impact wiring (commit `25aedda`)
Kyle's first feedback: "the scene doesn't make sense... when I hit the screen, there's no ball that goes on the other side."
- **Camera reframe:** moved from `(0, 6, -5)` 28° pitch (looking down at a tiny trapezoid in a grey void) to `(0, 1.5, -3)` 8° pitch with a navy `(0.05, 0.08, 0.14, 1)` background. Court now reads as full horizontal floor stretching forward.
- **Floor lines:** rebuilt as Cube primitives (were Quads — invisible from glancing angles).
- **Net:** raised to 3m with posts.
- **Backstop:** added BoxCollider so the ball can't escape forever.
- **Targets axis fix:** drills were reading `refT.up` (world Y) for "top" target offset, which floated targets 1.5m above the floor in 3D. Added `CourtRightAxis` / `CourtUpAxis` / `CourtSurfaceNormal` to `ICombineCourtBuilder`. In 2D these still map to the local frame; in 3D they map to court right (X), court forward (Z), and world up (Y) so targets sit flat on the floor.
- **Ball physics:** `CombineBall3D.cs` was a Lerp+sin placeholder with no Rigidbody. Rewrote it: Rigidbody (0.057kg, gravity, Continuous collision), SphereCollider with shared static `PhysicsMaterial` (bounciness 0.75), self-destructs on settle (<0.1 m/s for 0.5s) or 8s lifetime. ITF-spec dimensions.
- **Impact wiring:** added `InputManager.ImpactOccurred` static event, `CombineSession` subscribes when 3D and routes to `_courtBuilder3D.SpawnBallFromImpact(worldImpactPos)`. Unsubscribe in `CompleteSessionAfterHold` and `OnDestroy`.

### Round 2 — HUD text + spawn alignment (commit `0885395`)
Kyle's second feedback: "WARM" (the warm-up title) filled the entire screen, and clicking didn't put the ball where the click was.
- **HUD text:** `GetHudTextAnchor` now pushes the TextMesh to 6m forward of the camera (was 1.2m — too close, text dominated the view).
- **First spawn fix:** `SpawnBallFromImpact` now reconstructs the click ray and intersects the net plane at `z = transform.position.z` instead of using the floor-raycast hit point.

### Round 3 — Y-restriction fix (commit `bf88bd9`)
Kyle's third feedback: "there's a specific area on the y-axis where the balls come through correctly. anywhere higher or lower they come from a default center position." Recorded a video; I extracted 72 frames at 2fps via ffmpeg to confirm the pattern.
- **Root cause:** the post-fix `Mathf.Clamp(spawnPos.y, 0.3f, 3.5f)` after net-plane intersection clamped the lower ~30% of the screen to `y=0.3`. With camera at `(0, 1.5, -3)` 8° pitch FOV 60°, the click ray crosses `z=0` at `y ∈ [-0.65, +2.81]`, so most low clicks ended up clamped to the same y.
- **Fix:** ditched plane intersection. `SpawnBallFromImpact` now spawns 4m along the click ray from camera origin. Any point on the ray reprojects back to the click pixel, so the ball always appears under the cursor. Kept a floor-clip protection (`y >= BALL_RADIUS`).

### Round 4 — Started but not finished
Kyle reported: **"some quaternion error is happening a lot. and the setup otherwise doesnt seem fixed."**

Scanned all `Quaternion.LookRotation` and `Quaternion.Euler` calls in the Combine code — none had obvious zero-vector or parallel-vector issues. Then Kyle pasted the actual error:

```
QuaternionToEuler: Input quaternion was not normalized
UnityEngine.GUIUtility:ProcessEvent (int,intptr,bool&)
```

The `GUIUtility:ProcessEvent` trace means it fires during Editor inspector GUI processing, not during play — so it's a stored quaternion in the scene file, not a runtime LookRotation. Scanned `Combine_Gameplay_3D.unity` and found two near-unit-but-not-quite values:
- **Line 442:** `(0.40821788, -0.23456968, 0.10938163, 0.8754261)` — magnitude² = 0.99999
- **Line 897 (Main Camera):** `(0.0698, 0, 0, 0.9976)` — magnitude² = 1.00007

Both are Euler→Quaternion round-trips with too few decimal places. Unity flags them when the inspector tries to convert back to Euler.

Asked Kyle two clarifying questions before dispatching: which "setup doesn't seem fixed" specifically, and whether the error spams during play or only on inspector selection. He chose to wrap for the night before answering.

## Commits This Session (all on `staging/sprint-1-port`, pushed)

1. `25aedda` — Combine 3D: composition + physics + impact wiring (camera reframe, lines, net, backstop, axis migration, Rigidbody ball, ImpactOccurred event)
2. `0885395` — Combine 3D: HUD text anchor 6m + ray-to-net spawn
3. `bf88bd9` — Combine 3D: ray-distance spawn (fixes y-restriction)

(Plus the brick spawning / namespace-shadowing fixes visible in the recent commits — those are from a prior context, not from tonight.)

## In Progress

**The quaternion-not-normalized error.** Almost certainly the two scene-file rotations above. Fix is straightforward — re-write them with full-precision values whose magnitude² rounds cleanly to 1.000000. But before dispatching, need Kyle to confirm:
1. Is the error spamming continuously (runtime LookRotation) or only on inspector clicks (stored scene quat)?
2. What other "setup" issues remain — fresh screenshot would clarify whether targets, lines, net, framing, or HUD is the next thing to fix.

## Next Steps (tomorrow morning)

1. **Get the two answers from Kyle** (continuous-vs-inspector error, fresh screenshot).
2. **If stored-quat:** dispatch Canopy with a tiny contract to:
   - Rewrite scene line 897 Camera quaternion with full precision (e.g. `Quaternion.Euler(8f, 0f, 0f)` computed values: `(0.0697564737, 0, 0, 0.9975640503)`).
   - Identify and fix the line-442 GameObject the same way.
3. **If runtime quat:** add `Debug.Assert(Mathf.Abs(q.sqrMagnitude - 1f) < 0.0001f)` around suspect LookRotation sites, replay, find the offender.
4. **Address whatever Kyle flags as "still not fixed"** in the screenshot — likely targets, ball trajectory feel, or HUD readability.
5. **Then file SERV-111** in Linear to capture the Combine 3D mode (still a placeholder — kept slipping because Canopy work was the priority).

## Blockers

- **Kyle's two answers** (see In Progress).
- That's it. No external blockers.

## Notes for Next Session

- Working tree still has ~40 unrelated `.mat` / `.asset` / `.prefab` modifications. Pre-existing Unity Editor re-serialization noise. Exclude from commits unless Kyle asks.
- The video review workflow worked well: Kyle records `mp4`, drops in `references/`, I extract frames via `ffmpeg -i video.mp4 -vf "fps=2,scale=1280:-1" frames/f%03d.png`, then read frames 1–72 sequentially. Use again for any "weird visual behavior" report.
- Three accepted Canopy deviations this session, all semantic-correctness:
  1. Path was `Steamroller/Contents/Scenes/...` not `Steamroller/Scenes/...` as I wrote in the contract — Canopy used the correct path.
  2. Canopy's 5 new interface members (CourtRightAxis etc.) weren't in my original contract — accepted because the axis decoupling needed it.
  3. PhysicsMaterial on `CalibrationDrill` targets — same pattern, accepted.
- Be specific with Canopy on Unity 6 API names: `linearVelocity` (not `velocity`), `PhysicsMaterial` (no C, not `PhysicMaterial`), `PhysicsMaterialCombine` enum.
- The `staging/sprint-1-port` branch is where we've been pushing all day. Did NOT merge to `main` — needs Kyle approval after the 3D mode actually works in his hands.

## Rules Added This Session

None new. Tonight's slip — diving into runtime LookRotation analysis before checking the scene file's stored quaternions when the stack trace clearly said `GUIUtility:ProcessEvent` — is covered by existing "read the actual error before guessing" hygiene. Just remember it tomorrow.
