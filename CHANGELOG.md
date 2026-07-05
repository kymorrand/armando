# Changelog

All notable changes to Armando are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

*(no unreleased changes)*

## Repository Frozen — 2026-07-05 (tag: `claude-code-final`)

Armando's Claude-Code-era — Horizon mode, hand-authored mission briefs, the
sidecar/checkpoint protocol — is frozen here. Trellis (Armando 0.4) replaces it:
persistent LangGraph threads instead of checkpoint files, LangSmith traces instead
of heartbeat prose, Discord/Linear message-queue injection instead of a for-Kyle
queue file. Full account of what worked, what didn't, and why in the
[retrospective](https://github.com/mirror-factory/trellis/blob/main/docs/2026-07-03%20-%20Armando%20Retrospective%20(0.1%20to%200.3.3).md).

The portable/offline install path (`INSTALLATION.md`) stays documented and
supported for bare-machine use. `_ivy/`'s handoff archive is left as-is — folding
it into a Library is week-1 Trellis scope, not part of this freeze.

## [0.3.3]: 2026-05-11

### Added: Portable install mode for Windows 11

Armando's portable install now has native Windows 11 parity. Same prefix
shape as the Linux/Mac portable build (`$env:USERPROFILE\armando-portable\`
with `node\`, `claude\`, `armando\`, `.claude-home\`), same sentinel
bracketed activation block, same teardown discipline. No admin / no UAC
required: per file links use NTFS hardlinks, with a plain-copy fallback for
cross volume installs.

- **`bootstrap.ps1` (NEW).** Windows equivalent of `bootstrap.sh`. Downloads
  the pinned Node 20.18.1 `win-x64.zip` from nodejs.org, verifies the
  SHA-256 (`56e5aacd...4ca03`), extracts it into the prefix, runs
  `npm install --prefix` to land `@anthropic-ai/claude-code` locally,
  clones the armando repo (or `git pull`s an existing checkout), invokes
  `install.ps1` with `$env:CLAUDE_CONFIG_DIR` redirected into the prefix,
  persists `CLAUDE_CONFIG_DIR` at user scope via
  `[Environment]::SetEnvironmentVariable(..., 'User')`, and writes a
  sentinel bracketed block to `$PROFILE.CurrentUserAllHosts` (so both
  Windows PowerShell 5.1 and PowerShell 7+ pick it up). The block self
  guards: if `$env:ARMANDO_PORTABLE\node\node.exe` is missing it silently
  no-ops, so the profile block survives a `Remove-Item -Recurse` of the
  prefix without breaking shell startup. `-DryRun` switch prints the plan
  and writes nothing outside `$env:TEMP`. Idempotent: rerunning skips
  already extracted Node, already installed Claude Code, and refuses to
  duplicate the profile block.
- **`uninstall.ps1` (NEW).** Inverse of bootstrap. Per file in
  `$CLAUDE_CONFIG_DIR\agents\` and `\commands\`: removes the entry if it
  is a reparse point pointing into the armando repo, or (for hardlink /
  copy fallbacks that carry no link metadata) if its SHA-256 matches the
  same named file in `<repo>\agents\` or `<repo>\commands\`. Anything
  else is left alone. Strips both `# >>> armando >>>` and
  `# >>> armando-portable >>>` sentinel blocks from
  `$PROFILE.CurrentUserAllHosts` and `$PROFILE.CurrentUserCurrentHost`,
  writes a `.armando-bak` backup beside each modified profile. Clears the
  user scope `CLAUDE_CONFIG_DIR` env var only when its value points into
  the portable prefix being removed (custom values left intact). Prompts
  before `Remove-Item -Recurse` of the prefix; `-Yes` switch bypasses for
  scripted teardown. Refuses to act on a prefix of `""`, `"\"`, `"$HOME"`,
  `$env:USERPROFILE`, or a drive root.
- **`install.ps1` (EDIT).** Now honors `$env:CLAUDE_CONFIG_DIR` (falls back
  to `$HOME\.claude` when unset, so existing users see no behavior change).
  Per file agent / command links switched from `SymbolicLink` (which
  required admin on Windows) to `HardLink`, with a plain `Copy-Item`
  fallback when source and target sit on different volumes. The appended
  `armando` function is now wrapped in `# >>> armando >>>` /
  `# <<< armando <<<` markers so `uninstall.ps1` can remove it
  deterministically. When `$env:CLAUDE_CONFIG_DIR` is non-default the
  script skips the profile edit entirely; `bootstrap.ps1` owns that block.
- **`CLAUDE.md` (EDIT).** Expanded the "Portable install" section with a
  Windows 11 subsection (one-liner bootstrap, auth step, run command,
  override, dry-run, teardown).

### Notes

- Cross-version safe: scripts run under Windows PowerShell 5.1 (built into
  Windows 11) and PowerShell 7+. No `?:` ternary, no `??` null-coalesce.
- All three `.ps1` files start with `Set-StrictMode -Version Latest` and
  `$ErrorActionPreference = 'Stop'`.
- No `Developer Mode` requirement. The portable install is fully usable on
  a stock Windows 11 user account with only Git for Windows and an
  internet connection as prerequisites.

## [0.3.2]: 2026-05-11

### Added: Portable install mode

Armando can now be installed on a bare machine that has only `curl`, `git`,
and `bash`. The portable bootstrap builds a self-contained prefix at
`$ARMANDO_PORTABLE` (default `~/armando-portable/`) containing a local Node
20.18.1 (pinned by SHA-256), a non-global Claude Code CLI install
(`npm install --prefix`, no `-g`, no sudo), the armando repo, and a
`.claude-home/` directory exposed to Claude Code via `CLAUDE_CONFIG_DIR`.
Nothing lands in the host `~/.claude/`.

- **`bootstrap.sh` (NEW).** Detects platform (`linux-x64`, `darwin-x64`,
  `darwin-arm64`), downloads and SHA-256-verifies the official Node tarball
  from nodejs.org, installs `@anthropic-ai/claude-code` locally, clones
  the armando repo, invokes the existing `install.sh` with `CLAUDE_CONFIG_DIR`
  redirected into the prefix, and writes a sentinel-bracketed activation
  block to `.bashrc` / `.zshrc` / `.profile`. The activation block self-guards:
  if `$ARMANDO_PORTABLE/node/bin/node` is missing it silently no-ops, so the
  rc block survives an aggressive `rm -rf` of the prefix without breaking
  shell startup. `--dry-run` flag prints the plan and writes nothing outside
  `/tmp`. Idempotent: rerunning skips already-downloaded components and
  refuses to duplicate the rc block.
- **`uninstall.sh` (NEW).** Inverse of bootstrap. Removes only symlinks
  under `$CLAUDE_CONFIG_DIR/agents/` and `$CLAUDE_CONFIG_DIR/commands/`
  whose `readlink -f` target resolves into the armando repo root; foreign
  symlinks and regular files are preserved. Strips both
  `# >>> armando >>>` and `# >>> armando-portable >>>` sentinel blocks from
  `~/.bashrc`, `~/.zshrc`, and `~/.profile` (also honors `$ARMANDO_RC`),
  with a `.armando-bak` backup beside each modified file. Prompts before
  `rm -rf` of the portable prefix; `--yes` bypasses for scripted teardown.
  Refuses to act on a portable prefix of `""`, `"/"`, or `"$HOME"`.
  Handles both portable and traditional installs; traditional mode leaves
  `~/armando` itself in place and only unlinks plus unhooks the rc block.
- **`install.sh` (EDIT).** Now honors `$CLAUDE_CONFIG_DIR` instead of
  hardcoding `$HOME/.claude` (falls back to `$HOME/.claude` when unset, so
  existing users see no behavior change). The appended `armando()` shell
  function is wrapped in sentinel markers (`# >>> armando >>>` /
  `# <<< armando <<<`) so `uninstall.sh` can remove it deterministically with
  `awk`. When `$CLAUDE_CONFIG_DIR` is non-default (portable install path)
  the script skips the rc-block write entirely; `bootstrap.sh` owns that
  block.
- **`CLAUDE.md` (EDIT).** New "Portable install" section under "Installation"
  documenting the one-liner bootstrap, the `--dry-run` plan check, the
  `ARMANDO_PORTABLE` override, and the `uninstall.sh` teardown command.

### Notes

- Linux x86_64 verified. Darwin x64 and arm64 plumbing is in place
  (platform detection, pinned SHA-256, `tar -xJ` extraction) but not
  smoke-tested on macOS hardware in this sprint. Flag for Armando on
  first Mac install.
- Windows portable bootstrap is a follow-up. `install.ps1` unchanged in
  this release.

## [0.3.1]: 2026-04-21

### Governed by

Armando 0.3.0 → 0.3.1 delta audit at
`/home/kyle/projects/trellis/missions/mission-00-armando-audit/artifacts/armando-0.3.0-to-0.3.1-audit.md`.
Seven changes surfaced by Mission 01 (Greenhouse v0 build). Mission-00-shaped
audit; Interactive mode (not Horizon). Approved section-by-section by Kyle.

### Added: Fabrication hardening (sidecar protocol)

- **`<sprint-slug>.verify.json` sidecar.** Sub-agents writing status
  reports with claimed tool output also write a structured JSON sidecar
  at `_grove/sprints/`. Schema includes `claim_id`, `command`, `cwd`,
  `timestamp`, `exit_code`, `stdout_sha256`, `stdout_tail`,
  `load_bearing`, `replayable`.
- **Armando's post-dispatch review loop.** Step 1 ("Review their
  changes") expanded to include: read sidecar; re-run 100% of
  load-bearing commands + 25% random sample of non-load-bearing;
  hash-diff captured stdout; verify post-state for `replayable: false`
  entries. Mismatches classify Yellow (non-load-bearing) or Red
  (load-bearing → revert + re-dispatch).
- **Review Checklist** gains new item #8 ("Sidecar verification").
  Renumbered 9-12.
- **Sprint-contract template** gains "Verification Artifact" section
  (load-bearing claim list, replayable rule, schema pointer) and two
  new Outcome fields (Sidecar verification, Replayed claims).
- **Scope note.** The behavioral "Never fabricate tool output" rule in
  project CLAUDE.md continues to govern prose drift; the sidecar is the
  mechanical gate for load-bearing evidence. Together.
- **Rollout.** Mission 01 sprints are not retrofitted. Mission 02 is
  the first mission with sidecar required.

### Added: Vercel preflight rule

- **Three-check preflight** before writing any sprint contract that
  ends in a Vercel deploy-smoke step: (1) `framework` non-null on the
  project, (2) `ssoProtection` + `protectionBypass` pairing if SSO is
  configured, (3) env-var parity across Preview ↔ Production targets.
- **Sprint-contract template** gains "Preflight" section with three
  fields + target project ID + preflight timestamp. Findings within
  Yellow → fix + disclose; findings outside Yellow → queue as Red.
- Motivating incidents: Q-4 (Vercel SSO wall + silent `framework: null`)
  and Q-5 post-merge (env-var parity drift).

### Added: Explicit `--target preview` rule

- **"What You Don't Do" rule.** Sub-agents never run `vercel deploy`
  without `--target preview` explicitly. CLI default is production
  outside a git-branch context.
- Sprint-contract template Verification Commands gain a callout.
- Motivating incident: Sprint 1 accidental prod deploy (inert scaffold
  behind 401 SSO).

### Added: Queue-wins-on-resume rule

- **"Resuming a session" step 4a.** If `for-kyle.md` header "Last
  updated" timestamp is newer than the checkpoint's session-end
  timestamp, OR any Q-[N] item has a newer Kyle response, the queue
  file wins. Process responses in full, re-evaluate checkpoint's
  "Next action on resume", void the default action if a response
  contradicts it.
- The session-resume flash heartbeat notes whether the rule fired.

### Added: `permitted_write_paths` replaces "mission directory"

- **Mission-brief template** gains "Path scope" section:
  `permitted_write_paths`, `permitted_read_paths`, `red_paths` as
  explicit glob arrays.
- **`agents/armando.md`** Tool Permissions block updated: Green =
  "within `permitted_read_paths` / `permitted_write_paths`"; Yellow =
  "outside `permitted_write_paths`"; Red = "`rm -rf` outside
  `permitted_write_paths`". Replaces the ambiguous "mission directory"
  phrasing (which was literally wrong for any mission with deliverables
  in the project repo).
- **`playbook/tool-envelope-map.md`** table headers + rm rows updated
  to reference the path variables.
- **Default behavior preserved** for mission briefs that omit the
  field: defaults to mission-folder-only, Armando flags the omission
  in heartbeat 1. 0.3.0-compatible.

### Added: ScheduleWakeup deferral (not a primitive)

- **Cadence rule.** Self-cadence is best-effort until Mission 02
  lands `sessions` / `coordination_events` + Supabase Realtime. No
  external heartbeat timer exists yet; tolerance (±10m) is policy,
  not enforcement. Guidance: do not queue time-sensitive work to a
  future self-scheduled tick; escalate to `for_kyle` with Priority:
  hard instead.
- No new tool or protocol primitive. Documentation-only change in
  `agents/armando.md` cadence rules.

### Changed: Filesystem paths to canonical location

- **Trellis workspace relocated** from `/home/kyle/trellis/` to
  `/home/kyle/projects/trellis/`. Matches Mission 01's canonical git
  repo. Mission-00 audit directory and empty handoffs tree moved;
  legacy `/home/kyle/trellis/` reduced to a pointer README.
- **22 path references updated** across 14 files: `CLAUDE.md`,
  `agents/armando.md`, `commands/spiral.md`, `playbook/rename-missions.md`,
  `templates/{mission-brief,heartbeat-log,checkpoint,for-kyle-queue}.md`,
  and all 5 `templates/handoffs/*.md`.
- **Historical references preserved as audit trail:** `CHANGELOG.md`
  0.3.0 release notes, `_ivy/reports/handoff-rootstock-2026-04-20.md`.
  Consistent with the 0.2 → 0.3 "preserve history, update current"
  pattern.
- **Versioning block** in `agents/armando.md` updated to reference
  both the 0.2 → 0.3 and 0.3.0 → 0.3.1 audit documents.

### Added: Mission 00 rename-missions playbook (carry-forward from 0.3.0 tail)

> These additions accumulated in `[Unreleased]` after 0.3.0 shipped and
> rode forward with 0.3.1.

- **`playbook/rename-missions.md`.** Completion checklist for rename missions.
  Lists every in-repo surface (agent files, commands, skills, templates,
  playbook, installers, CLAUDE.md, CHANGELOG, VERSION, mission briefs, Grove
  indexes) and every out-of-repo surface (`~/.bashrc`, `~/.zshrc`,
  `~/.profile`, `$PROFILE`, fish config, `~/.claude/agents/` symlinks, stray
  `claude --agent <old-name>` invocations, Claude Code settings.json, running
  sessions). Provides a ready-to-run grep gauntlet and five acceptance
  criteria. Includes the Mission 00 post-mortem inline so the rule is
  self-documenting: `claude --agent <unresolved-name>` silently falls back
  to plain Claude Code, which is how the Thorn to Armando rename shipped a
  silent session degradation.
- **CLAUDE.md Conventions bullet** pointing at the rename-missions playbook,
  and a corresponding line in the repo structure section.

### Changed: Residual Thorn references (carry-forward from 0.3.0 tail)

- **`REFERENCES.md`.** Three stale "Thorn" references describing current
  Armando behavior updated to "Armando" (CAID adoption note, Harness Design
  review practice, Karpathy Grove pattern).
- **`playbook/documentation.md`.** CHANGELOG enforcement line updated
  from "Enforced by Thorn in review" to "Enforced by Armando in review".
- **`templates/grove-index.md`.** Six "Thorn" references updated to
  "Armando". This template seeds every new project's Grove, so stale
  references here propagate on every project init.

### Preserved as audit trail (intentionally not rewritten)

- `CHANGELOG.md` 0.3.0 entries referencing `/home/kyle/trellis/` and Thorn
- `_ivy/reports/handoff-*.md` historical session artifacts
- `CLAUDE.md` sentence explaining the Thorn to Armando rename
- `playbook/rename-missions.md` Mission 00 post-mortem section
- `~/.claude/agents/thorn.md.bak` (inert; Claude Code does not load `.md.bak`)
- The 0.2 → 0.3 audit doc at its original path

### Carry-forward to 0.3.2

- When Mission 02 ships the `sessions` / `coordination_events` substrate
  + Supabase Realtime, revise the "Self-cadence is best-effort" rule in
  `agents/armando.md` to point at the realized backend timer rather than
  a planned one.
- After 3+ Mission 02 sprints with clean sidecar diffs, promote the
  schema from "calibration" to "stable." If any Red mismatch fires in
  the first 5 sprints, revisit the schema.
- Promote the handoff-style `build-report.md` shape from Mission 01 as
  the canonical template (Mission 01 carry-forward callout).

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
