# Session Handoff

**Machine:** Greenhouse (Linux/Ubuntu)
**Project:** Tennis Social Platform
**Date:** 2026-03-24

## What Was Done

### Infrastructure
- Installed Git LFS, migrated 1,473 binary files (3.8GB) to LFS
- Pushed `staging/sprint-1-port` to GitHub (first successful push)
- Created `dev` branch and pushed to remote
- Installed cmake 3.28 + verified g++ 13.3 (C++17) on Greenhouse
- **Control server compiles clean** — first verified build, zero warnings

### Repo Reorganization
- Merged Kyle's additions from main (audit docs + dallas tracker)
- Replaced old `tracking/` (Steamroller archive) with active arcade mode tracker from Dallas pilot
- Set up `_grove/` project vault with reports, ADRs, sprint plans, designs
- Created CHANGELOG.md
- Wrote 3 ADRs: Git LFS, branching strategy, Unity 6 upgrade
- Updated CLAUDE.md with docs standards, branching strategy, dev environment

### Root Dispatch: JSON Score Persistence
- Root completed file-based JSON scoring for ScoreboardManager
- Branch: `feature/json-score-persistence` — pushed, reviewed, approved
- Atomic writes (temp file + rename), graceful error handling, configurable path
- **Not yet merged into dev** — ready for merge

### Armando Repo Created
- https://github.com/kymorrand/armando (private)
- Agent definitions, commands, install scripts (Linux + Windows)
- Automated session sync: pull on start, push on exit
- Installed and working on both Greenhouse and Kyle's Windows PC

## In Progress
- Kyle opening Unity game-client/ in Unity 6.3 LTS on Windows PC (migration from 2022.3)
- cmake build downloads Boost (~4min) — cached in control-server/build/ now

## Next Steps
- Merge `feature/json-score-persistence` into `dev`
- Sprint 2 planning (Phase 1 checkpoint is March 27 — 3 days away)
- Unity 6.3 migration results from Kyle's Windows PC
- Discuss Canopy workflow now that Windows PC has Armando
- Install C++ test framework (Catch2 or Google Test) — queued

## Blockers
- None currently

## Decisions Made This Session
- Branching: dev → staging → main (staging = hardware testing, main = verified)
- Unity upgrade: 2022.3 → 6.3 LTS
- Scoring: file-based JSON persistence (not in-memory, not database)
- Tracking: arcade mode tracker replaces archive port
- Documentation: _grove/ vault + CHANGELOG.md mandatory on all projects
- Multi-machine: Armando repo with automated sync, not SSH dispatch
