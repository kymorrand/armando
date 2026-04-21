# Changelog

All notable changes to Armando are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [0.3.0]: 2026-04-20

### Added: Horizon mode

Horizon mode lets Armando operate autonomously against a mission brief for
extended periods (typically 1-8 hours, sometimes longer) with Kyle as an
async collaborator. Activated only by an explicit mission brief with
`mode: horizon`; never self-declared.

- **Authority envelope.** Three-tier Green/Yellow/Red decision model
  governs every tool use during a mission. Defaults live in
  `playbook/tool-envelope-map.md`; mission briefs override per mission.
  `~/.claude/settings.json` has `skipDangerousModePermissionPrompt: true`,
  so the envelope is the only guardrail.
- **Heartbeat protocol.** Armando writes one heartbeat per tick (default
  60m cadence, tolerance ±10m) to the mission's `heartbeat-log.md`. Fixed
  structure: Since last heartbeat / Current / Next / For Kyle / Blockers /
  ETA. Timer starts at plan approval. Atomic operation yield at tick time.
  Flash heartbeats allowed when a mission-critical event occurred AND the
  next tick is more than 20 minutes away.
- **`for_kyle` queue protocol.** Q-[N] schema for queued items requiring
  Kyle's async input. Priority tiers: Soft / Medium / Hard. Armando never
  blocks on a queue item; routes around and continues other work. At every
  heartbeat tick start, Armando scans the queue for Kyle's responses.
- **Checkpoint state file.** Rewritten at every session end. Captures git
  state, in-progress work, sub-agent state, ephemeral values, reading list
  for resume, and a single-sentence "Next action on resume". Target:
  resume within 1-2 prompt exchanges.
- **Session-resume flash heartbeat.** Written at the start of every
  resumed session; notes any `for_kyle` responses processed during resume.
- **Seven-event flag list for sub-agents.** Bloom, Root, and Canopy flag
  envelope-relevant events (scope drift, unexpected push, unexpected
  dependency, unexpected external API, unexpected destructive op,
  unexpected spending, unexpected system modification) prominently in
  status reports. Armando classifies and integrates.
- **`inherited_envelope` field on sprint contracts.** Sub-agents inherit
  the mission's envelope tier for each dispatch. Default green; mission
  brief can raise the baseline.
- **Inter-agent handoff protocol.** Armando can request research briefs
  from Ivy and critiques from Mr. Owl via artifacts written to
  `/home/kyle/trellis/handoffs/outgoing/`. Polls
  `/home/kyle/trellis/handoffs/incoming/` at session start and every
  heartbeat tick. Outside-charter or target-agent-doesn't-exist →
  automatic Red; queue and route around.

### Added: Templates

- `templates/mission-brief.md`. Three Horizons mission brief (H1/H2/H3,
  authority envelope, collaboration charter, success criteria,
  pre-provisioned access).
- `templates/heartbeat-log.md`. Append-only log schema with cadence rules.
- `templates/for-kyle-queue.md`. Q-[N] queue item schema with priority
  definitions.
- `templates/checkpoint.md`. Session-end state file schema.
- `templates/handoffs/research-brief-request.md`. Armando → Ivy request.
- `templates/handoffs/critique-request.md`. Armando → Mr. Owl request.
- `templates/handoffs/build-report.md`. Local copy of the build report
  template (Armando → Mr. Owl / Library).
- `templates/handoffs/research-brief.md`. Local copy of the research brief
  template (Ivy → Armando).
- `templates/handoffs/critique.md`. Local copy of the critique template
  (Mr. Owl → Armando + Kyle).

### Added: Playbook

- `playbook/tool-envelope-map.md`. Full tool-by-tool Green/Yellow/Red
  mapping covering built-in tools, Bash command classes, web tools,
  scheduling, Linear, Google Workspace, Notion, Gamma, Vercel plugin, and
  special cases (agent soul files, credentials, spending, destructive
  ops). Mission briefs override per mission.

### Changed: Structural

- **Thorn → Armando rename.** The PM/orchestrator agent renamed from
  "Thorn" to "Armando". The four-agent team is now Armando, Bloom, Root,
  Canopy. Thorn's reviewer discipline (direct, sharp, protective, specific
  critiques with file-and-line citations) is absorbed into Armando's
  voice. `armando` shell function unchanged; no user-facing command
  change. Historical `_ivy/reports/handoff-*.md` files that reference
  Thorn remain unchanged (audit trail).
- **Sprint contracts** include new fields: `Mode` (interactive | horizon),
  `Mission ID` (horizon only), `Inherited Envelope` (horizon only), and
  `Envelope-flag events` in the Outcome section (horizon only).

### Changed: Agents

- `agents/thorn.md` → `agents/armando.md`. Expanded with Operating Modes
  section, Sub-agents in Horizon Mode governance, Horizon Mode Protocol
  (start / resume / envelope / heartbeat / for_kyle / handoffs /
  checkpoint / complete), Tool Permissions summary, Greenhouse
  Integration note.
- `agents/bloom.md`, `agents/root.md`, `agents/canopy.md`. Thorn →
  Armando references. New "When Dispatched in a Horizon Mission" section
  with the seven-event flag list. Explicit "no em dashes" rule. Sprint
  workflow updated to reference `inherited_envelope` in the contract.

### Changed: Commands

- `commands/spiral.md`. Mode detection (Interactive default, Horizon when
  mission brief present). Sub-agent seven-event flag check added to
  REVIEW step. Horizon mission workflow branch appended. Status report
  path aligned to `_grove/reports/` (project-scoped).
- `commands/status.md`. Clarified project-scoped
  (`_grove/reports/status-*.md`) vs cross-machine
  (`~/armando/_ivy/reports/handoff-*.md`) destinations. Added Horizon-
  mission envelope-flag-events field for sub-agent reports.
- `commands/review-all.md`. Thorn → Armando references. Status report
  path alignment (`_grove/reports/`). Envelope flag check step added for
  Horizon missions.

### Preserved (no changes, strictly additive)

- Claude Code as substrate; Opus model across all four agents
- Four-agent team architecture with sub-agent worktree isolation
- `isolation: worktree` frontmatter on Bloom, Root, Canopy
- CLAUDE.md per project as constitution
- `_grove/` per project (index, reports, sprints, adrs, designs)
- `_ivy/` for cross-project memory + handoffs
- Sprint contract protocol (with added `inherited_envelope` field)
- Parallelization check before concurrent dispatch
- Post-dispatch re-plan loop
- Grove index updated after every dispatch completion
- Garden reports with velocity summary
- "Rules Added This Session" rule-compounding loop
- Linear board management (with refined Green/Yellow classification for
  status transitions)
- Kyle's writing conventions (no em dashes, confident-builder voice)
- Commit message style, CHANGELOG-prepend-never-truncate rule
- Cross-machine handoff pattern (`_ivy/reports/handoff-{machine}-{date}.md`)
- `armando` shell function auto-pull / auto-commit wrapper
- Installer behavior (symlinks to `~/.claude/agents/` and
  `~/.claude/commands/`)
- Slash commands (`/spiral`, `/status`, `/test-all`, `/review-all`,
  `/unity-verify`)
- Playbook files (`documentation.md`, `review-checklist.md`)
- Unity project support (Canopy's full scope including MCP integration)
- MCP integration patterns (Linear, Gmail, Calendar, Drive, Granola,
  Notion, Gamma)
- Vercel plugin skills inventory

### Governed by

Mission 00: Armando Audit (Mission brief at
`/home/kyle/projects/trellis-startup/02-missions/mission-00-armando-audit.md`).
Full delta document at
`/home/kyle/trellis/missions/mission-00-armando-audit/artifacts/armando-0.2-to-0.3-audit.md`.

## [0.2.0]: 2026-04-04

### Added
- **Sprint contracts**: Thorn writes a structured contract before every dispatch with task scope, file boundaries, acceptance criteria, verification commands, and timestamps.
- **Parallelization guards**: Thorn must list files each agent will touch and confirm no overlap before parallel dispatch.
- **Grove activation**: Thorn creates and maintains `_grove/` with compiled index on every project. Index updated after every dispatch completion.
- **Post-dispatch memory writes**: Thorn updates Grove after every agent completes, not just at session end.
- **Re-plan after merge**: Thorn reassesses remaining sprint plan after each agent completes, before dispatching next task.
- **Velocity tracking**: Sprint contracts include `dispatched_at` timestamps. Garden reports include `completed_at`, `agent_wall_clock`, `review_duration`, `outcome`, and `revision_count`.
- `REFERENCES.md`: Attribution for all research sources informing Armando's design.
- `VERSION` file: Machine-readable version number.
- `CHANGELOG.md`: This file.
- `templates/sprint-contract.md`: Template for dispatch contracts.
- `templates/grove-index.md`: Template for project Grove index.
- Version banner in `armando` shell function: displays version on launch.

### Changed
- `agents/thorn.md`: Dispatch protocol now requires sprint contracts, parallelization checks, post-dispatch Grove updates, and re-planning after each merge.
- `commands/spiral.md`: Updated to include re-plan step after each agent completes.
- `install.sh` / `install.ps1`: Shell function now displays version banner and reads from `VERSION` file.

## [0.1.0]: 2026-03-23

### Summary
Initial working version of Armando. Four agents (Thorn, Bloom, Root, Canopy) with markdown definitions, user-level install via symlinks, slash commands, CLAUDE.md per-project conventions, garden reports, and handoff protocol.

### Agents
- **Thorn**: PM/Lead. Plans, reviews, dispatches. Never writes code.
- **Bloom**: Frontend. UI, styling, design system.
- **Root**: Backend. Runtime, APIs, tests, security.
- **Canopy**: Unity/C#. Gameplay, editor tooling, shaders.

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
