# Handoff — Windows — 2026-04-17

- **Machine:** Kyle's Windows PC
- **Project:** tennis-social-platform
- **Branch:** `feature/serv-107-combine-session`
- **Lead:** Thorn
- **Dispatched:** Canopy × 4 today (R16, R17, R18, R19) — all landed in `84d2afd`, already pushed to origin
- **Continues:** `handoff-windows-2026-04-16-c.md` (yesterday evening stop)
- **Stopping point:** Clean. Post-crash cleanup + documentation pass complete. Awaiting Kyle's resumed R18+R19 debug-camera smoke test.

## What Happened This Session

Two phases this session — a morning dispatch phase before the crash and an afternoon recovery phase after Kyle came back online.

### Morning (pre-crash)

Four Canopy dispatches shipped clean on the "depth readability + dev tooling" theme:

- **R16** — ball `TrailRenderer` (0.3s, tennis-yellow fade) + altitude-scaled drop shadow (0.30→0.60m diameter, 0.5→0.15 alpha via ball altitude). Classic depth-cue pattern.
- **R17** — `G`-key debug toggle gating (a) 1m-spaced court-depth grid + cross-width hash marks, and (b) trajectory prediction line on `CombineBall3D` showing the expected parabolic arc at spawn.
- **R18** — trail width multiplier 3f → 1.5f (Kyle "too fat" feedback from R16) + runtime debug camera controls gated by R17's `DebugVisualsEnabled`: arrow keys pitch/yaw, W/S forward/back (0.5m/press), Q/E up/down (0.25m/press), `=`/`-` FOV (5°/press, clamped), R reset, T save. Every change logs `[CombineCourtBuilder3D] Camera: pos=(x,y,z) rot=(x,y,z) fov=f` to the console so Kyle can read values and bake them into the scene.
- **R19** — rebind all six R18 letter keys because Q clobbered `GameMode_Combine.Update()`'s Q=ExitGameMode (pressing Q to raise the camera also quit the game mode), and S/R/T overlapped with other framework systems. New bindings: `]` fwd, `[` back, PgUp up, PgDn down, Backspace reset, Backslash save. Arrow keys / `=` / `-` / `G` unchanged.

All four rounds rolled into a single squashed commit `84d2afd Combine 3D playability + depth readability (SERV-107 R4-R9, R11-R19)` that also absorbed yesterday's uncommitted R4–R15 backlog. The planned "11 atomic commits" from yesterday's handoff collapsed into one squash — acceptable (R4–R19 is one logical pass and we never practiced bisect rollback) but flagged in sprint retro.

### Afternoon (post-crash)

Unity editor crashed while Kyle was smoke-testing R18's runtime debug camera. Unity auto-wrote the scene state to `game-client/Assets/_Recovery/0.unity` (Unity's "here's what you were editing" crash safety mechanism). No actual work lost — `84d2afd` was already committed and pushed.

This afternoon's work was recovery + documentation, no code changes, no agent dispatches:

1. **Artifacts cleaned.** Deleted `game-client/Assets/_Recovery/` + `_Recovery.meta` (Unity crash safety, not real work). Deleted stale `.canopy-compile.log` (gitignored but cluttering git-status).
2. **Gitignore hardened.** Added `game-client/Assets/_Recovery/` and `game-client/Assets/_Recovery.meta` patterns so a future editor crash can't accidentally leak the recovery folder into a commit.
3. **Contract outcomes backfilled.** R16/R17/R18 sprint contract `## Outcome` sections were skipped during the rapid morning cadence — all three now filled with approximate timestamps, pass status, and notes about the retroactive fill. R19 was already filled live.
4. **Grove index regenerated.** Yesterday's "R10 committed, R4–R15 uncommitted, 11 atomic commits planned tomorrow" status is gone. New status reflects the squashed commit reality, captures R16–R19 work, adds a dedicated "Follow-ups Beyond Current Sprint" section for parked items (SERV-111 filing, 5 queued rule promotions to CLAUDE.md, 2D depth-cue parity decision).
5. **Garden report written** — `_grove/reports/garden-2026-04-17.md`.

## Commits This Session

**None from this afternoon's cleanup pass** — that's what the pending commit (post-handoff) will capture. The morning's `84d2afd` is already on origin.

## In Progress

**Nothing.** Clean stop.

## Next Steps (next session)

1. **Kyle resumes the R18+R19 debug-camera smoke test** — the interrupted one. Press V → press G → fly camera with the new bindings (`[` `]` / PgUp / PgDn / arrows / `=` `-` / `\` / Backspace) → find optimal projection-screen framing → press `\` to save → read logged `pos/rot/fov` values from console → manually bake them into the scene's camera transform.
2. Also confirm the rest of the R16–R19 stack reads well during that same pass: trail at 1.5× width (not flaming), altitude shadow scales visibly with ball height, debug grid + trajectory line render cleanly when G is ON, no new Q=ExitGameMode regression.
3. If anything surfaces new → R20 dispatch. Otherwise:
4. **File SERV-111 in Linear** (Combine 3D umbrella issue, still a placeholder in sprint contracts).
5. **Promote five queued rules to CLAUDE.md "What NOT to Do"** in a single dispatch-free documentation pass:
   - URP `_BaseColor`/`_Color` dual-write (R10/R11)
   - Trigger ↔ bouncy-solid collider swap (R12)
   - Delete-method comment sweep (R13)
   - Floor-threshold-is-geometric (R14)
   - Unity runtime debug keybind grep (R18 — new today)
6. Sprint retro + plan next sprint. Candidate directions:
   - 2D depth-cue parity (do 2D balls need trail/shadow or does the vertical backboard make depth irrelevant?)
   - Pivot to control-server WebSocket hub refactor (idle since sprint start; race conditions in `SafetySystem.cpp`, unhandled JSON exceptions in `ScoreboardManager`, WebSocket map lock bug all still unfixed)
   - Unity client WebSocket auto-reconnection with exponential backoff

## Blockers

- **Kyle's resumed debug-camera smoke test.** Everything else is queued behind it.
- No external blockers. Canopy is idle. Bloom + Root untouched this sprint.

## Workspace State at Stop

- **HEAD:** `84d2afd` (unchanged from morning push, in sync with origin).
- **Uncommitted (to be committed + pushed this session-end):**
  - `.gitignore` — added `_Recovery/` patterns
  - `_grove/index.md` — regenerated to reflect R16–R19 reality
  - `_grove/sprints/contract-canopy-combine-3d-r16-trail-and-shadow-scale.md` — Outcome backfilled
  - `_grove/sprints/contract-canopy-combine-3d-r17-debug-grid-trajectory.md` — Outcome backfilled
  - `_grove/sprints/contract-canopy-combine-3d-r18-trail-polish-debug-camera.md` — Outcome backfilled
  - `_grove/reports/garden-2026-04-17.md` — new garden report
- **Deleted (good):** `game-client/Assets/_Recovery/`, `game-client/Assets/_Recovery.meta`, `.canopy-compile.log`.
- **Untouched (ignored):** `.claude/worktrees/agent-a8284fc2/` — the SERV-106 arcade-stability worktree is still live on its own branch (`feature/serv-106-arcade-stability`) and was not deleted. Leave for Kyle to handle when SERV-106 next resumes.

## Agent Velocity

| Agent | This Session | Sprint Total |
|-------|--------------|--------------|
| Canopy | 4 dispatches (R16, R17, R18, R19), 0 revisions, 1 immediate-follow-up (R19 after R18 smoke test), ~1h15min total agent wall | 23/23 accepted (SERV-107), 1 revision (R13 comment cleanup, yesterday), 1 protocol slip (R10 auto-commit — covered), 1 smoke-test key-conflict follow-up (R18 → R19) |

## Notes for Next Session

- Shell wrapper will auto-commit and push the handoff after exit — but this session I'll also explicitly commit + push the Grove docs and gitignore bump as part of the "push to GitHub" request (separate from the handoff autocommit).
- The queued rule about Unity debug keybinds (R18 learning) is strong — it's the kind of miss where a file-scoped grep passed (no conflicts in Combine) but a project-wide grep would have caught it. Worth promoting alongside the existing four.
- If Unity's crash-recovery dialog appears on reopen, **decline** the recovery offer — `84d2afd` already has R4–R19 and the recovery file is gone from disk. The on-disk scene is the source of truth.
- If the R18 debug camera feel isn't right even after the keybind fix (step size too coarse, axis feels inverted, etc.), that's a natural R20 candidate — one-line constant tweaks.
- SERV-106 worktree (`.claude/worktrees/agent-a8284fc2/`) still on disk — expected, not stale, leave alone.
