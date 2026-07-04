# Armando: The Gardener

Armando is a four-agent AI development team built on Claude Code. Named after an engineer and gardener who kept complex systems running far from shore. Engineering discipline meets cultivation patience.

**Owner:** Kyle Morrand. **Organization:** Mirror Factory, Inc. **Version:** 0.3.3.

## Agents

| Agent | Role | Model |
|-------|------|-------|
| **Armando** | Lead/orchestrator. Plans, reviews, coordinates, dispatches. Interactive or Horizon mode. | Opus |
| **Root** | Backend: runtime, APIs, tests, security. | Opus |
| **Bloom** | Frontend: UI, styling, design system. | Opus |
| **Canopy** | Unity/C#: gameplay, editor tooling, shaders. | Opus |

Armando replaces the prior PM agent "Thorn" from 0.2 — the role and reviewer discipline are preserved and absorbed into Armando's voice.

## Operating modes

**Interactive** (default): Kyle actively prompts; Armando responds; sprint contracts, parallelization checks, Grove updates after every merge. **Horizon** (0.3+): Armando operates against a mission brief for extended periods, Kyle as an async collaborator — heartbeats on cadence, `for_kyle` queue for blockers, checkpoint state at session end. Activated only by an explicit mission brief with `mode: horizon`. Full protocol: `agents/armando.md`.

## Repo structure

`agents/` (definitions, symlinked to `~/.claude/agents/`) · `commands/` (slash commands, symlinked to `~/.claude/commands/`) · `_ivy/` (global memory: cross-project context, session handoffs in `reports/`, cross-project patterns in `memory/`) · `templates/` (project/mission/handoff templates) · `playbook/` (operational standards — `documentation.md`, `review-checklist.md`, `rename-missions.md`, `tool-envelope-map.md`) · `install.sh` / `install.ps1` · `CHANGELOG.md` (prepend-only) · `REFERENCES.md`.

## Installation

Clone + run the platform installer for your OS (`install.sh` / `install.ps1`) — symlinks agent/command definitions into `~/.claude/`, adds the `armando` shell function, does **not** touch project repos. For a bare machine with no Node/Claude Code, or a fresh Windows box with no admin, use the portable bootstrap instead. Full walkthroughs (both install paths, override vars, uninstall): see [INSTALLATION.md](INSTALLATION.md).

After install, `armando` from any project directory starts a session. Update: `cd ~/armando && git pull` (symlinks mean agents/commands update immediately).

## Project standards

Every project Armando works on should have: `CLAUDE.md`/`AGENTS.md` (project constitution), `_grove/` (project vault — reports, ADRs, sprint plans, designs), `CHANGELOG.md` (updated every sprint, enforced by Armando in review). Templates: `templates/`.

## Facts (non-discoverable)

- **Multi-machine**: Armando can run on multiple machines simultaneously; git is the sync layer, not a shared process. Pull before starting work, commit+push when finishing, write a status report to `_grove/reports/` (project-scoped) *and* a handoff to `~/armando/_ivy/reports/` (cross-machine) before ending a session. Check Linear and `_grove/` for context from other machines. Never edit the same files on two machines simultaneously.
- **Horizon missions** live at `/home/kyle/projects/trellis/missions/[mission-id]/` (`brief.md`, `heartbeat-log.md`, `for-kyle.md`, `checkpoint.md`, `artifacts/`). Inter-agent handoffs flow through `/home/kyle/projects/trellis/handoffs/{outgoing,incoming,archive}/`. Once the Greenhouse control plane (Mission 01 deliverable) exists, these sync to `library_entries` rows.
- **Rename missions**: run the full grep gauntlet before declaring complete — see `playbook/rename-missions.md`. Installers (`install.sh`, `install.ps1`) and shell rc files (`~/.bashrc`, `~/.zshrc`, `$PROFILE`) are first-class rename targets, not afterthoughts (Mission 00 shipped a silent degradation by skipping this).
- **CHANGELOG is prepend-only** — new entries at the top, all history preserved, never replace.

Voice/identity conventions (no em dashes, confident builder voice) live in the Trellis agent registry, not here — this repo is being frozen at 0.3.3 (tag `claude-code-final`) rather than actively developed further.
