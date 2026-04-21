# Handoff: rootstock, 2026-04-21

**Mode:** Interactive
**Machine:** rootstock
**Project:** Armando (self-maintenance; the repo, not a downstream project)
**Agent:** Armando (lead)

## What was done

Kyle flagged a rule after noticing Mission 00's Thorn to Armando rename had
shipped a silent degradation: every agent file was updated, but the installed
shell wrapper in `~/.bashrc` still invoked `claude --agent thorn`. Because
`claude --agent <unresolved-name>` silently falls back to plain Claude Code
rather than erroring, sessions launched with the `thorn` wrapper ran with
no agent soul and nobody noticed for a while.

Codified the rule and cleaned up residual stale references.

### 1. New playbook: `playbook/rename-missions.md`

Documents the completion checklist for any rename mission. Captures:

- 19 in-repo surfaces (agents, commands, skills, templates, playbook,
  installers, CLAUDE.md, CHANGELOG, VERSION, mission briefs, Grove)
- 9 out-of-repo surfaces (`~/.bashrc`, `~/.zshrc`, `~/.profile`, `$PROFILE`,
  fish config, `~/.claude/agents/` symlinks, stray `claude --agent` calls,
  Claude Code settings.json, running sessions)
- Ready-to-run grep gauntlet with OLD/NEW variables
- Five acceptance criteria (zero unexpected hits, clean-room install
  produces working new command, smoke test confirms agent identity by
  asking "which agent are you?", users told to re-source profile,
  CHANGELOG lists every touched file)
- Mission 00 post-mortem inline so the rule is self-justifying

### 2. CLAUDE.md updates

- Added `rename-missions.md` to the `playbook/` listing in repo structure
- Added a Conventions bullet pointing at the playbook with one-line root
  cause so future Armando sessions don't need to chase the file

### 3. Grep gauntlet run against current state

Cleanup results:

- **Shell rc files, installers, agent/command symlinks:** clean (zero hits)
- **Agents, commands:** clean
- **Stale current-behavior references fixed** in three files:
  - `REFERENCES.md` (3 hits)
  - `playbook/documentation.md` (1 hit)
  - `templates/grove-index.md` (6 hits; this one was the worst because the
    stale name propagates to every new project init)
- **Historical references preserved as audit trail:** CHANGELOG entries
  documenting the rename, `_ivy/reports/handoff-*.md` session artifacts,
  `CLAUDE.md` sentence explaining the rename, `playbook/rename-missions.md`
  post-mortem section, `trellis-v1-design-brief.md`
- **`~/.claude/agents/thorn.md.bak`:** kept as archive per Kyle; inert
  (Claude Code does not load `.md.bak`)

### 4. CHANGELOG.md

Prepended an `[Unreleased]` section documenting the new playbook, the
three cleanup edits, and the preserved-as-audit-trail list. Version
bump left for Kyle.

## In progress

Nothing. Work is atomic and complete.

## Next steps

Optional follow-ups, none urgent:

- Decide whether to cut `0.3.1` for this cleanup or roll into the next
  feature release
- Consider whether `templates/grove-index.md`'s fix should trigger a
  refresh of any already-initialized downstream project Groves (likely
  not; downstream Groves are actively maintained and will self-correct)
- If Greenhouse (Mission 01) is next, nothing here blocks it

## Blockers

None.

## Rules added this session

One rule, codified in `playbook/rename-missions.md` and referenced from
`CLAUDE.md` Conventions:

> **Rename missions: run the grep gauntlet before declaring complete.**
> Installers (`install.sh`, `install.ps1`) and shell rc files (`~/.bashrc`,
> `~/.zshrc`, `$PROFILE`) are first-class rename targets, not afterthoughts.
> Mission 00 shipped a silent degradation by skipping this check.

The failure mode (silent fallback from unresolved `--agent <name>`) is the
generalizable insight. Any agent-identity change across the ecosystem needs
this check, not just renames.
