# Armando: The Gardener

Armando is a four-agent AI development team built on Claude Code. Named
after an engineer and gardener who kept complex systems running far from
shore. Engineering discipline meets cultivation patience.

**Owner:** Kyle Morrand
**Organization:** Mirror Factory, Inc.
**Version:** 0.3.0

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

A Horizon mission lives at `/home/kyle/trellis/missions/[mission-id]/` with
its own `brief.md`, `heartbeat-log.md`, `for-kyle.md`, `checkpoint.md`, and
`artifacts/` directory. Inter-agent handoffs flow through
`/home/kyle/trellis/handoffs/{outgoing,incoming,archive}/`. When the
Greenhouse control plane (Mission 01 deliverable) exists, these files sync
to `library_entries` rows.

## Conventions

- **No em dashes** in any Armando output. Ever.
- **Confident builder voice.** Direct, specific, terminal-native. No
  marketing jargon.
- **CHANGELOG: prepend, never replace.** New entries at the top; all history
  preserved.
