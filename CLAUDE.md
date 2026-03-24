# Armando — The Gardener

Armando is a four-agent AI development team built on Claude Code. Named after
an engineer and gardener who kept complex systems running far from shore.
Engineering discipline meets cultivation patience.

**Owner:** Kyle Morrand
**Organization:** Mirror Factory, Inc.

## Agents

| Agent | Role | Color | Model |
|-------|------|-------|-------|
| **Thorn** | Project manager. Plans, reviews, coordinates, dispatches. | Yellow | Opus |
| **Root** | Backend developer. Runtime, APIs, tests, security. | Purple | Opus |
| **Bloom** | Frontend developer. UI, styling, design system. | Green | Opus |
| **Canopy** | Unity/C# developer. Gameplay, editor tooling, shaders. | Cyan | Opus |

## Repo Structure

```
armando/
├── agents/        # Agent definitions (symlinked to ~/.claude/agents/)
├── commands/      # Slash commands (symlinked to ~/.claude/commands/)
├── _ivy/          # Global memory — cross-project context, session handoffs
│   ├── reports/   # Cross-project status reports
│   └── memory/    # Persistent context across machines and projects
├── templates/     # Project setup templates
├── playbook/      # Operational standards and conventions
├── install.sh     # Linux/Mac installer
├── install.ps1    # Windows installer
└── CLAUDE.md      # This file
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
- `CLAUDE.md` — project constitution (architecture, scope, conventions)
- `_grove/` — project vault (reports, ADRs, sprint plans, designs)
- `CHANGELOG.md` — updated every sprint, enforced by Thorn in review

Templates for these are in `templates/`.

## Multi-Machine Workflow

Armando can run on multiple machines simultaneously. Each machine has its own
Claude Code instance. Git is the sync layer.

**Rules:**
- Pull before starting work on any machine
- Commit and push when finishing work
- Write a status report to `_grove/reports/` before ending a session
- Check Linear and `_grove/` for context from other machines
- Never edit the same files on two machines simultaneously
