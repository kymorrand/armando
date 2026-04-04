# Changelog

All notable changes to Armando are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [0.2.0] — 2026-04-04

### Added
- **Sprint contracts** — Thorn writes a structured contract before every dispatch with task scope, file boundaries, acceptance criteria, verification commands, and timestamps.
- **Parallelization guards** — Thorn must list files each agent will touch and confirm no overlap before parallel dispatch.
- **Grove activation** — Thorn creates and maintains `_grove/` with compiled index on every project. Index updated after every dispatch completion.
- **Post-dispatch memory writes** — Thorn updates Grove after every agent completes, not just at session end.
- **Re-plan after merge** — Thorn reassesses remaining sprint plan after each agent completes, before dispatching next task.
- **Velocity tracking** — Sprint contracts include `dispatched_at` timestamps. Garden reports include `completed_at`, `agent_wall_clock`, `review_duration`, `outcome`, and `revision_count`.
- `REFERENCES.md` — Attribution for all research sources informing Armando's design.
- `VERSION` file — Machine-readable version number.
- `CHANGELOG.md` — This file.
- `templates/sprint-contract.md` — Template for dispatch contracts.
- `templates/grove-index.md` — Template for project Grove index.
- Version banner in `armando` shell function — displays version on launch.

### Changed
- `agents/thorn.md` — Dispatch protocol now requires sprint contracts, parallelization checks, post-dispatch Grove updates, and re-planning after each merge.
- `commands/spiral.md` — Updated to include re-plan step after each agent completes.
- `install.sh` / `install.ps1` — Shell function now displays version banner and reads from `VERSION` file.

## [0.1.0] — 2026-03-23

### Summary
Initial working version of Armando. Four agents (Thorn, Bloom, Root, Canopy) with markdown definitions, user-level install via symlinks, slash commands, CLAUDE.md per-project conventions, garden reports, and handoff protocol.

### Agents
- **Thorn** — PM/Lead. Plans, reviews, dispatches. Never writes code.
- **Bloom** — Frontend. UI, styling, design system.
- **Root** — Backend. Runtime, APIs, tests, security.
- **Canopy** — Unity/C#. Gameplay, editor tooling, shaders.

### Infrastructure
- User-level install at `~/.claude/agents/` with symlinks to `~/armando/agents/`
- Cross-platform installers (`install.sh`, `install.ps1`)
- `armando` shell alias with auto-pull and auto-commit
- Slash commands: `/spiral`, `/status`, `/test-all`, `/review-all`, `/unity-verify`
- Playbook with documentation standards and review checklist
- `_ivy/` for global cross-project memory
- `_grove/` template for per-project vaults

### Shipped Work (as of v0.1.0)
- Coordinated multi-agent sprint on Trellis (Gardener Activity page)
- Screenshot regression testing system
- Trellis app Week 1 foundation (scaffold, auth, dashboard)
- 833 tests passing on Trellis runtime
- 23 CLAUDE.md rules accumulated from sprint lessons
