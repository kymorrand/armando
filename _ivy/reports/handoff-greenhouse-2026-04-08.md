# Handoff — greenhouse — 2026-04-08

**Machine:** greenhouse
**Project:** mf-forge
**Session type:** Sprint 2 Wave 2 + design pivot

## What Was Done

### Sprint 2 Wave 2 (shipped)
- **Bloom B merged** — Quick Mode UI (ModelSelector, HourlyInputs, ValueCaptureInputs, TriScenarioOutput, ConfidenceBanner, RecommendedFloor), `useCalculation` hook, real backend POST, v3.2-aligned TS types. Picked up from orphaned worktree after the previous session was cut off by an Anthropic API 500. Quality gates green (typecheck, lint, build). Commit `1ee107f` + merge `9875e22`.
- **Root C hotfix (CORS)** — `CORSMiddleware` added to `backend/main.py` with `FORGE_CORS_ORIGINS` env override and default dev allow-list (`localhost:5173`, `127.0.0.1:5173`, `192.168.1.244:5173`). 5 new tests, 56/56 total backend tests green. Commit `c03db7f`. Sprint contract at `_grove/sprints/sprint-02-contract-root-c-cors.md`.
- **Remote dev verified** — uvicorn running `--host 0.0.0.0 --reload`, Vite on `0.0.0.0:5173`, `frontend/.env.local` set to `VITE_API_URL=http://192.168.1.244:8000`. Kyle confirmed Quick Mode UI worked end-to-end from his desktop browser.

### Design pivot — Forge becomes a CRO agent
Kyle paused building after hands-on use revealed Profile + Quick Mode "feel like silly form field calculators." Ran a tabletop exercise against the QuoteWave deal (the highest-ambiguity live deal: Oscar Tello + Darren at Soft Wash Nation, Bob's Apr 2 term sheet rejected, Layers as asymmetric value, Friday 11am call coming up). Exercise exposed 5 critical gaps in forge-spec-v3. Kyle proposed reframing Forge as **"a Chief Revenue Officer role on our team, as an agent that has an interface."** Committed to reframe with guardrails:
- Follow Layers patterns but stay **isolated** from Layers (Alfonso is heads-down, don't distract).
- **Sync-first** MVP, async (inbox / Granola / email) is Phase 2.
- **Team** with lightweight multi-user.
- Non-negotiable **honest-broker rule**: Forge tabletops, never decides.

### DESIGN.md written + committed
- `DESIGN.md` at repo root — self-contained ~6k-word design doc, 14 sections. Commit `33a3f09`.
- `forge-spec-v3.md` deprecated with banner pointing to DESIGN.md.
- Sections: Purpose / Why We Pivoted / 10 Product Principles / Users + Modes / Four Layers Primitives (Profile/Library/Sessions/Tools with MVP tool set) / Five Interaction Patterns / MVP Scope / What Survives / What Gets Thrown Away / Stack Decision Open (A: Next.js+AI SDK+Supabase recommended / B: keep current / C: hybrid) / 15 Open Questions / Action Items / Appendix A: QuoteWave Case Study / Appendix B: Glossary.

## In Progress

**Nothing active.** Design phase is paused pending Kyle's second-pass review with a fresh Claude session.

## Next Steps

1. **Kyle's second-pass Claude session (external).** Kyle has handed off DESIGN.md to a separate Claude session. He will:
   - Paste in Apr 4 pipeline notes, **Trellis** prototype context, 2026 cashflow notes, deeper Layers details.
   - Do deep research on Vercel AI SDK agent/tool-calling patterns, generative UI, Supabase auth + RLS.
   - Pressure-test the CRO reframe, MVP scope, and stack decision.
   - Work the 15 open questions in §11 and the 12 action items in §12.
   - Draft Sprint 3 scope.
2. **Return to Thorn session** with refined DESIGN.md + Sprint 3 plan. At that point:
   - Frontend gets thrown away (all of `frontend/`). Keep the git history — don't `rm -rf` without a tag.
   - Backend pricing engine survives (56 tests, pricing strategies, profile schema, CORS middleware).
   - Likely stack migration (Vite/React → Next.js + AI SDK + Supabase if Option A sticks).
3. **Friday 11am QuoteWave call** — Kyle said he and Bob can navigate it without Forge. No blocker, but Thorn should ask for call outcome in the next session since it will feed the design.

## Blockers

- **Waiting on Kyle's external Claude session** for DESIGN.md second-pass. Nothing to dispatch until he returns with Sprint 3 scope.
- **14 commits ahead of origin.** Not pushed. Kyle has not approved push.

## State of the Tree

- Branch: `main`, 14 commits ahead of `origin/main`, clean working tree (only gitignored `data/`).
- Backend: `backend/.venv/bin/uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload` was running during session — Kyle may have killed it.
- Frontend: `cd frontend && npm run dev -- --host 0.0.0.0` was running — Kyle may have killed it.
- Vercel: https://mf-forge.vercel.app still live from Sprint 2 Wave 1 (Bloom A bootstrap).
- `frontend/.env.local` is untracked (gitignored) with `VITE_API_URL=http://192.168.1.244:8000`.

## Rules / Patterns Reinforced This Session

- **Worktree recovery works.** Bloom B's orphaned worktree from an API 500 was recoverable via git review + merge. Pattern: inspect the worktree's git log, diff against main, run the project's quality gates before merging. No data loss.
- **CORS must be configured before any cross-origin dev testing.** Add to the sprint contract template for any project where frontend + backend run on different hosts/ports.
- **Never restart uvicorn without `--reload`** in dev if you want hot-swap after agent dispatches. Lost ~5 minutes to this during Root C verification.
- **Design pauses are valid sprint outputs.** Kyle's "this feels wrong" instinct after shipping Quick Mode was the single highest-value moment of the session. Thorn should not treat "pause and redesign" as failure — it's a first-class outcome.
