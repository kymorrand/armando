# Handoff — Windows PC — April 6, 2026

## Machine
Kyle's Windows PC

## Project
**Forge** — Mirror Factory pricing strategy tool
- Local path: `C:\Projects\MirrorFactory\mf-forge` (git bash: `/c/Projects/MirrorFactory/mf-forge`)
- Repo: https://github.com/mirror-factory/mf-forge (private, `mirror-factory` org)
- Branch: `main` @ `de53cbd`

## What Was Done This Session

Fresh project bootstrap — no code yet, just foundation.

1. **Reviewed** the 4 seed files: `README.md`, `forge-spec-v3.md` (v3 product spec), `seed-deals.json`, `seed-profile.json`.
2. **Initialized git** and pushed to new private repo on `mirror-factory` GitHub org.
3. **Wrote `.gitignore`** — covers Python, Node/Vite, env files, SQLite, data/exports dirs, Armando workspace state.
4. **Wrote `CLAUDE.md`** — project constitution: architecture, tech stack, agent scope boundaries (Root = `backend/`, Bloom = `frontend/`, Canopy n/a), 8-phase build order, 10 initial "What NOT to Do" rules (top rule: *LLM never calculates — Python does all math*).
5. **Initialized `_grove/`** — `README.md` + `index.md` with project summary, architecture snapshot, decision log, file ownership map, known issues.
6. **Created Linear project** — "Forge — Pricing Strategy Tool" under **Product team (PROD)**, Urgent, target 2026-06-30, lead Kyle.
7. **Seeded 9 Phase 1/2 Linear issues** — see table below.

### Commits on main
- `80c211b` — Initial commit: spec, seed data, gitignore
- `de53cbd` — Add CLAUDE.md constitution and initialize _grove vault

## Linear Issues Seeded (Product team)

| ID | Scope | Blocked by | Priority |
|---|---|---|---|
| PROD-264 | [Root] Scaffold backend (FastAPI, packages, requirements, /health) | — | Urgent |
| PROD-265 | [Root] MF Company Profile schema + JSON storage + derived fields | — | Urgent |
| PROD-266 | [Root] Pricing engine base interface + TriScenario wrapper | — | Urgent |
| PROD-267 | [Root] Implement 5 pricing models (hourly, value_capture, retainer_revshare, equity_retainer, saas_costplus) | 266 | Urgent |
| PROD-268 | [Root] Negotiation floor derivation from profile | 265 | High |
| PROD-269 | [Root] FastAPI endpoints /profile, /calculate, /negotiate | 265, 266, 267, 268 | High |
| PROD-270 | [Bloom] Scaffold frontend (Vite+React+TS+Tailwind+API client) | — | High |
| PROD-271 | [Bloom] MF Profile editor + summary component | 269, 270 | High |
| PROD-272 | [Bloom] Quick Mode UI — first client-call-usable surface | 269, 270 | Urgent |

**Parallelization window:** PROD-264, 265, 266, and 270 have zero blockers. Root + Bloom can start simultaneously with clean file boundaries (`backend/` vs `frontend/`).

## In Progress
Nothing started. Everything is planning-only. No code, no worktrees, no sprint contracts dispatched yet.

## Next Steps (pick up here on the other machine)

1. **Open this project** on the new machine:
   - Clone: `git clone https://github.com/mirror-factory/mf-forge.git`
   - Path: wherever you keep MF projects on that machine
2. **Start Thorn** in the project directory and say: *"Resume Forge — read the handoff and the Grove index, then propose Sprint 1."*
3. **Sprint 1 decision** still pending Kyle's approval. The plan I'm proposing:
   - **Parallel dispatch:** Root gets PROD-264 + 265 + 266 in one contract; Bloom gets PROD-270 in another.
   - Both run in isolated worktrees. No file overlap (confirmed — `backend/` vs `frontend/`).
   - Acceptance: backend boots on 8000 with `/health`, profile loads from `seed-profile.json`, TriScenario wrapper tested with a dummy strategy; frontend boots on 5173 with typecheck+lint passing.
   - After both merge: write sprint contract for PROD-267 (five pricing models) and PROD-272 (Quick Mode UI) in parallel.
4. **Still undecided (Kyle's call before Sprint 1 goes out):**
   - Tailwind vs. another utility CSS for Bloom?
   - React Router v6 or something else?
   - JSON files for storage v1 is locked in (decision logged), SQLite later.
   - PDF generation library — deferred to Phase 6, not blocking.

## Blockers
- None technical. Waiting only on Kyle to greenlight Sprint 1 scope and the two open decisions above.

## Notes for the Next Session
- `CLAUDE.md` is the constitution — Thorn reads it first, every time.
- `_grove/index.md` has the decision log, file ownership map, and known issues.
- The forge-spec-v3.md is 1,100+ lines and is the source of truth for product behavior. Don't re-read it whole — grep/read relevant sections.
- MF's real urgency: $21,150/mo new recurring revenue gap by June 30, 2026. Three active deals (Blue Wave, QuoteWave, Moses). This tool needs to be usable on a live call in weeks, which is why Quick Mode (PROD-272) is priority Urgent even though it comes after backend API.
