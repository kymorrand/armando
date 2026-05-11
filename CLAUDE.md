# Armando: The Gardener

Armando is a four-agent AI development team built on Claude Code. Named
after an engineer and gardener who kept complex systems running far from
shore. Engineering discipline meets cultivation patience.

**Owner:** Kyle Morrand
**Organization:** Mirror Factory, Inc.
**Version:** 0.3.3

## Agents

| Agent | Role | Color | Model |
|-------|------|-------|-------|
| **Armando** | Lead and orchestrator. Plans, reviews, coordinates, dispatches. Runs in Interactive or Horizon mode. | Yellow | Opus |
| **Root** | Backend developer. Runtime, APIs, tests, security. | Purple | Opus |
| **Bloom** | Frontend developer. UI, styling, design system. | Green | Opus |
| **Canopy** | Unity/C# developer. Gameplay, editor tooling, shaders. | Cyan | Opus |

Armando replaces the prior PM agent "Thorn" from 0.2; the role and reviewer
discipline are preserved and absorbed into Armando's voice.

## Operating modes

Armando has two modes:

- **Interactive** (default): Kyle actively prompts; Armando responds; 0.2-era
  behavior. Sprint contracts, parallelization checks, Grove updates after
  every merge.
- **Horizon** (new in 0.3): Armando operates against a mission brief for
  extended periods with Kyle as an async collaborator. Heartbeats on
  cadence, `for_kyle` queue for blockers, checkpoint state file at session
  end. Activated only by an explicit mission brief with `mode: horizon`.

See `agents/armando.md` for the full Horizon protocol.

## Repo Structure

```
armando/
├── agents/                    # Agent definitions (symlinked to ~/.claude/agents/)
│   ├── armando.md             # Lead / orchestrator
│   ├── bloom.md               # Frontend
│   ├── root.md                # Backend
│   └── canopy.md              # Unity/C#
├── commands/                  # Slash commands (symlinked to ~/.claude/commands/)
│   ├── spiral.md              # Sprint loop (Interactive + Horizon branches)
│   ├── status.md              # Status report
│   ├── test-all.md            # Quality gate
│   ├── review-all.md          # Cross-worktree review
│   └── unity-verify.md        # Unity compile / test / meta check
├── _ivy/                      # Global memory: cross-project context, session handoffs
│   ├── reports/               # Cross-machine handoffs + global notes
│   └── memory/                # Cross-project patterns (organic fill)
├── templates/                 # Project and mission templates
│   ├── sprint-contract.md     # Dispatch contract
│   ├── grove-index.md         # Project Grove index
│   ├── grove-readme.md        # Project _grove/ README
│   ├── mission-brief.md       # Horizon mission brief
│   ├── heartbeat-log.md       # Horizon heartbeat log
│   ├── for-kyle-queue.md      # Horizon for-Kyle queue
│   ├── checkpoint.md          # Horizon session checkpoint
│   └── handoffs/              # Inter-agent handoff templates
│       ├── research-brief-request.md
│       ├── critique-request.md
│       ├── build-report.md
│       ├── research-brief.md
│       └── critique.md
├── playbook/                  # Operational standards
│   ├── documentation.md
│   ├── review-checklist.md
│   ├── rename-missions.md     # Rename completion checklist (installers + rc files)
│   └── tool-envelope-map.md   # Horizon mode Green/Yellow/Red mapping
├── install.sh                 # Linux/Mac installer
├── install.ps1                # Windows installer
├── VERSION                    # Machine-readable version
├── CHANGELOG.md               # Release history (prepend-only)
├── REFERENCES.md              # Attribution for design sources
└── CLAUDE.md                  # This file
```

## Installation

Clone this repo and run the installer for your platform:

```bash
# Linux/Mac
git clone git@github.com:kymorrand/armando.git ~/armando
cd ~/armando && chmod +x install.sh && ./install.sh

# Windows (PowerShell as Administrator)
git clone git@github.com:kymorrand/armando.git $HOME\armando
cd $HOME\armando; .\install.ps1
```

After installation, open any project directory and type `armando` to start.

### Portable install (Linux/Mac, no Node or Claude Code required)

For a bare machine that has only `curl`, `git`, and `bash`, use the portable
bootstrap. It installs a local Node, the Claude Code CLI, and the armando repo
into a single self-contained prefix (default `~/armando-portable/`). All Claude
Code state lives inside the prefix via `CLAUDE_CONFIG_DIR`, so nothing leaks
into the host `~/.claude/`.

```bash
# One-shot bootstrap (downloads ~80 MB of Node + Claude Code).
curl -fsSL https://raw.githubusercontent.com/kymorrand/armando/main/bootstrap.sh \
  | bash

# Authenticate Claude Code once.
claude login

# From any project directory:
armando
```

Override the install location with `ARMANDO_PORTABLE=/some/path` before
running. Inspect the plan first with `bash bootstrap.sh --dry-run`.

To remove everything cleanly (symlinks, rc block, the entire prefix):

```bash
bash ~/armando-portable/armando/uninstall.sh           # interactive
bash ~/armando-portable/armando/uninstall.sh --yes     # non-interactive
```

The same `uninstall.sh` also handles the traditional install: it removes only
symlinks whose targets resolve into the armando repo, strips the
sentinel-bracketed rc block, and leaves `~/armando` itself alone.

### Portable install (Windows 11, no admin required)

For a fresh Windows 11 box that has only PowerShell (built in) and Git for
Windows, use the PowerShell bootstrap. It lays down a local Node, the
Claude Code CLI, and the armando repo into
`$env:USERPROFILE\armando-portable\`. All Claude Code state lives inside
the prefix via `CLAUDE_CONFIG_DIR`, so nothing leaks into
`$HOME\.claude\`. No admin / no UAC: per file links use NTFS hardlinks
with a plain-copy fallback.

```powershell
# One-shot bootstrap (downloads ~80 MB of Node + Claude Code).
$tmp = Join-Path $env:TEMP 'armando-bootstrap.ps1'
Invoke-WebRequest -UseBasicParsing `
  -Uri 'https://raw.githubusercontent.com/kymorrand/armando/main/bootstrap.ps1' `
  -OutFile $tmp
powershell -ExecutionPolicy Bypass -File $tmp

# Authenticate Claude Code once (in a new PowerShell window so $PROFILE re-runs).
claude login

# From any project directory:
armando
```

Override the install location with `$env:ARMANDO_PORTABLE = 'D:\armando'`
before running. Inspect the plan first with
`powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -DryRun`.

To remove everything cleanly (links, profile block, user scope
`CLAUDE_CONFIG_DIR`, the entire prefix):

```powershell
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\armando-portable\armando\uninstall.ps1"            # interactive
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\armando-portable\armando\uninstall.ps1" -Yes       # non-interactive
```

The same `uninstall.ps1` also handles the traditional Windows install: it
removes only links / copies whose target or content resolves into the
armando repo, strips the sentinel-bracketed `$PROFILE` block, and leaves
the repo itself in place.

## What the Installer Does

1. Symlinks `agents/*.md` → `~/.claude/agents/` (global agent definitions)
2. Symlinks `commands/*.md` → `~/.claude/commands/` (global slash commands)
3. Adds the `armando` shell function to your profile
4. Does NOT modify any project repos

## Updating

```bash
cd ~/armando && git pull
```

That's it. Symlinks mean agents and commands update immediately.

## Project Standards

Every project Armando works on should have:

- `CLAUDE.md`: project constitution (architecture, scope, conventions)
- `_grove/`: project vault (reports, ADRs, sprint plans, designs)
- `CHANGELOG.md`: updated every sprint, enforced by Armando in review

Templates for these are in `templates/`.

## Multi-Machine Workflow

Armando can run on multiple machines simultaneously. Each machine has its own
Claude Code instance. Git is the sync layer.

**Rules:**

- Pull before starting work on any machine
- Commit and push when finishing work
- Write a status report to `_grove/reports/` before ending a session
  (project-scoped), and a handoff to `~/armando/_ivy/reports/` (cross-machine)
- Check Linear and `_grove/` for context from other machines
- Never edit the same files on two machines simultaneously

## Horizon Missions

A Horizon mission lives at `/home/kyle/projects/trellis/missions/[mission-id]/` with
its own `brief.md`, `heartbeat-log.md`, `for-kyle.md`, `checkpoint.md`, and
`artifacts/` directory. Inter-agent handoffs flow through
`/home/kyle/projects/trellis/handoffs/{outgoing,incoming,archive}/`. When the
Greenhouse control plane (Mission 01 deliverable) exists, these files sync
to `library_entries` rows.

## Conventions

- **No em dashes** in any Armando output. Ever.
- **Confident builder voice.** Direct, specific, terminal-native. No
  marketing jargon.
- **CHANGELOG: prepend, never replace.** New entries at the top; all history
  preserved.
- **Rename missions: run the grep gauntlet before declaring complete.** See
  `playbook/rename-missions.md`. Installers (`install.sh`, `install.ps1`)
  and shell rc files (`~/.bashrc`, `~/.zshrc`, `$PROFILE`) are first-class
  rename targets, not afterthoughts. Mission 00 shipped a silent degradation
  by skipping this check.
