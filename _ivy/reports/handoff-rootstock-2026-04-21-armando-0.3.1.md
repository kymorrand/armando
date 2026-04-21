# Handoff: rootstock, 2026-04-21 (armando 0.3.1 release)

**Machine:** rootstock
**Mode:** Interactive
**Project:** ~/armando (with related artifacts in ~/projects/trellis)

## What was done

Shipped **Armando 0.3.1.0** — a mission-00-shaped audit of Armando's own
config that folds seven fixes from Mission 01 lessons into the agent
configuration.

The seven changes:

1. **Path canonicalization.** `/home/kyle/trellis/` replaced everywhere with
   `/home/kyle/projects/trellis/`. Mission-00 artifacts and handoff directories
   physically moved. Legacy `/home/kyle/trellis/` reduced to a pointer-only
   `README.md`.
2. **ScheduleWakeup / cadence-as-best-effort.** Deferred active scheduling
   to Mission 02's Missions API. Added explicit "self-cadence is best-effort
   until Mission 02 lands" bullet to the heartbeat cadence rules.
3. **Fabrication hardening (sidecar protocol).** New `.verify.json` sidecar
   schema per sprint contract, with SHA-256 hashing of stdout for
   load-bearing claims. Re-plan loop now reads + replays + diffs hashes
   before accepting sub-agent output. Zero edits to Bloom/Root/Canopy soul
   files — the contract carries the sidecar obligation.
4. **Vercel preflight rule.** Added to sprint contract template and to
   Armando's "What You Do Directly": framework non-null / SSO+bypass
   configured / env-var parity between preview and prod.
5. **Explicit `--target preview` on Vercel deploys.** Added to "What You
   Don't Do" as Red when omitted (default is prod; Mission 01 Sprint 1 shipped
   to prod accidentally).
6. **Queue-file-wins-on-resume.** Added to resume protocol: when `for-kyle.md`
   has Kyle responses newer than checkpoint, the queue file wins over
   checkpoint state.
7. **`permitted_write_paths` / `permitted_read_paths` / `red_paths`.**
   Replaces implicit "mission directory" scope. Added to mission-brief
   template as a required `Path scope` section. Envelope map updated to
   reference glob-based path declarations.

## Files changed

**~/armando repo (committed as `206d585`, tagged `armando-0.3.1.0`):**

- `CHANGELOG.md` — prepended `[0.3.1]: 2026-04-21` section
- `CLAUDE.md` — version bump, path fixes
- `VERSION` — `0.3.1`
- `agents/armando.md` — all seven sections' rule additions (205 lines
  changed; largest touch in release)
- `templates/sprint-contract.md` — Verification Artifact + Preflight +
  Outcome fields + Vercel deploy rule
- `templates/mission-brief.md` — `Path scope` section
- `playbook/tool-envelope-map.md` — `permitted_write_paths` column
- `commands/spiral.md`, `playbook/rename-missions.md`,
  `templates/{checkpoint,for-kyle-queue,heartbeat-log}.md`,
  `templates/handoffs/*.md` — path fixes

**~/projects/trellis repo (committed as `24a9fc9`):**

- `missions/mission-00-armando-audit/brief.md` (moved from legacy path)
- `missions/mission-00-armando-audit/artifacts/armando-0.2-to-0.3-audit.md`
  (moved from legacy path)
- `missions/mission-00-armando-audit/artifacts/armando-0.3.0-to-0.3.1-audit.md`
  (NEW: the delta audit document)
- `handoffs/{incoming,outgoing,archive}/.gitkeep` — canonical handoff location

## Git state

- `~/armando`: `main` at `206d585`, ahead of `origin/main` by 1 commit.
  Tag `armando-0.3.1.0` created locally. **Not pushed.**
- `~/projects/trellis`: `main` at `24a9fc9`, ahead of `origin/main` by 1
  commit. **Not pushed.** One unstaged modification remains
  (`missions/mission-01-greenhouse-v0/heartbeat-log.md`) — this is a Red-
  disclosure heartbeat from the tail of Mission 01; out of scope for 0.3.1
  and deliberately not touched.

## In progress

Nothing. The 0.3.1 release is complete and tagged locally.

## Next steps

1. **Kyle to push** (or authorize push) once satisfied with the release:
   - `cd ~/armando && git push && git push --tags`
   - `cd ~/projects/trellis && git push`
2. **Kyle to decide** what to do with the Mission 01 heartbeat-11 diff
   (unstaged in trellis): commit as a standalone disclosure commit, revert,
   or leave for the next Mission 01 reopen.
3. **Mission 02** (Missions API) is the next planned piece. It will
   implement active heartbeat scheduling, retiring the
   cadence-as-best-effort bullet added in this release.

## Blockers

None. No items queued to `_ivy/queue/`.

## Rules added this session

Recorded in the release CHANGELOG and in `agents/armando.md` directly:

- Vercel deploys default to prod; `--target preview` required unless a prod
  release is explicitly approved (Red without it).
- Sub-agents must emit a `.verify.json` sidecar for load-bearing claims.
  Armando replays and hash-diffs before accepting output.
- `for-kyle.md` queue wins over `checkpoint.md` on resume when the queue has
  responses newer than the checkpoint timestamp.
- Mission briefs must declare `permitted_write_paths`, `permitted_read_paths`,
  and `red_paths` explicitly. No more implicit "mission directory" scope.
- Self-scheduled heartbeat cadence is best-effort until Mission 02 ships an
  external Missions API scheduler.
