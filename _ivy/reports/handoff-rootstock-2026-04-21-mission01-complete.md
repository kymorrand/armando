# Handoff: rootstock, 2026-04-21 (Mission 01 complete)

**Mode:** Horizon (mission closed this session)
**Machine:** rootstock
**Project:** trellis
**Mission:** mission-01-greenhouse-v0
**Mission status:** **COMPLETE** at 2026-04-21T17:12-04:00
**Mission state file:** `/home/kyle/projects/trellis/missions/mission-01-greenhouse-v0/checkpoint.md`
**Deliverable:** `/home/kyle/projects/trellis/missions/mission-01-greenhouse-v0/artifacts/build-report.md`

## One-line summary

Greenhouse v0 substrate live on prod at `https://trellis-tan.vercel.app`, 7/7 prod smoke green, Library seeded with 40 rows (39 full embeddings + 1 partial), merge commit `3ccae47` on `main`. Mission 02 awaits Kyle's brief.

## What happened this session (post-compaction)

1. Resumed from pre-merge halt (Q-5 hard: Kyle merge PR #1)
2. Kyle approved merge ("can you do the merge?"). Executed `gh pr merge 1 --merge` → commit `3ccae47`, prod deploy `dpl_GgNk3ZXgfSddmaCuewUnaMcKv8tR` READY in ~80s
3. First prod smoke 1/7. Triage via Vercel API: production target missing `GREENHOUSE_MCP_TOKEN` + `AI_GATEWAY_AUTH_TOKEN` (preview had both from Sprint 7; production had never been seeded). Yellow: added both via `POST /v10/projects/$ID/env target=production`
4. Forced redeploy `dpl_HdnNz61BdywkXZ3TNPjMTHw38RUE` on same SHA, READY. Second prod smoke **7/7 PASS**
5. Fast-forwarded local main, wrote `.env.local`, ran `pnpm sync:local`: 39 creates succeeded, 1 failure (Mission 01 heartbeat-log exceeded 8192-token embed ceiling; row landed with partial embedding)
6. Re-queried `library_list` via MCP on prod: confirms 40 rows across 8 kinds
7. Finalized build report, heartbeat log (H10), for-kyle queue (Q-5 resolved, Q-6 disclosure), checkpoint, Grove index

## Files modified in this session

**Under `/home/kyle/projects/trellis/`:**
- `main` fast-forwarded to `3ccae47` (post-merge)
- `.env.local` (new, gitignored; points sync + tests at prod Supabase)
- Vercel production env: added `GREENHOUSE_MCP_TOKEN` + `AI_GATEWAY_AUTH_TOKEN`
- `missions/mission-01-greenhouse-v0/heartbeat-log.md` (H10 appended)
- `missions/mission-01-greenhouse-v0/for-kyle.md` (Q-5 resolved, Q-6 added)
- `missions/mission-01-greenhouse-v0/checkpoint.md` (rewritten for complete state)
- `missions/mission-01-greenhouse-v0/artifacts/build-report.md` (finalized)
- `_grove/index.md` (mission-complete state)

**Supabase (prod):**
- `library_entries` table: +40 rows

## Rules added this session

None new. The existing "no fabrication in status reports" rule (commit `17802b5`) held through the post-merge cycle. Every commit SHA, deploy ID, URL, and smoke output in this session's reports was independently verified.

## Proposed rules for Armando 0.3.1 (queued, not added)

1. **Vercel env-parity preflight.** Any mission that ends in a production deploy-smoke must verify per-target env-var parity (production vs. preview) during planning. Would have caught the missing `GREENHOUSE_MCP_TOKEN` / `AI_GATEWAY_AUTH_TOKEN` pre-merge.
2. **Vercel framework preflight.** Same rule body, plus `framework` / `ssoProtection` / `protectionBypass` checks (already proposed in Sprint 7b).
3. **Library-parity acceptance criterion.** When a mission's final sprint is "seed the Library", add an acceptance criterion that queries `library_list` on prod and asserts expected count + kind distribution.

Recommended implementation: `scripts/vercel-preflight.ts` in Mission 02 that bundles all three checks.

## Blockers

None. Mission closed. Awaiting Kyle's Mission 02 brief.

## Next session should

1. Read `_grove/index.md` (mission-complete context)
2. Read `missions/mission-01-greenhouse-v0/artifacts/build-report.md` (what's live, what's known-broken)
3. Check for a Mission 02 brief; if present, enter Horizon mode. If not, operate Interactive.

## Working tree state at session end

`main` fast-forwarded, clean of tracked changes. Untracked/dirty:
- `.env.local` (gitignored)
- `.claude/worktrees/` (7 sprint worktrees; safe to `git worktree remove` at Kyle's discretion)
- `_grove/` (Armando-owned, intentional)
- `missions/` (mission artifacts uncommitted — wrapper should commit on exit)
