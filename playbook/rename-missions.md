# Rename Missions: Completion Checklist

A **rename mission** changes the canonical name of an agent, tool, command, or
product across the Armando ecosystem (example: Thorn → Armando in the
0.2 → 0.3 cut).

Rename missions are uniquely dangerous because most of the surface area is
plain text and grep-replaceable, which creates a false sense of completeness.
The parts that bite are the ones that live *outside* the repo: shell profiles,
installed wrappers, running processes, and cached configs.

## The Rule

**A rename mission is not complete until every one of the following has been
grepped for the old name and verified clean.** If even one returns a hit, the
mission is not done.

### In-repo surface

1. All agent definitions (`agents/*.md`)
2. All slash commands (`commands/*.md`)
3. All skills (`skills/**/*.md`, including plugin skills)
4. All templates (`templates/**`)
5. All playbook files (`playbook/**`)
6. `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `REFERENCES.md`
7. **Installer templates: `install.sh` AND `install.ps1`** (both, always;
   Linux/Mac and Windows paths diverge)
8. Any `VERSION` or manifest files
9. All mission briefs and mission artifacts in `/home/kyle/projects/trellis/missions/`
10. `_grove/` indexes and reports

### Out-of-repo surface (this is what burns)

11. **`~/.bashrc`** (Linux/Mac default for bash)
12. **`~/.zshrc`** (Linux/Mac default for zsh; check even if primary shell is
    bash, since zsh may be installed)
13. **`~/.profile`** (portable fallback)
14. **`$PROFILE`** (PowerShell on Windows; resolve via `echo $PROFILE` or
    `$profile.CurrentUserAllHosts`, then grep the resolved path)
15. **`~/.config/fish/config.fish`** (if fish is present)
16. Any symlinks in `~/.claude/agents/` and `~/.claude/commands/` pointing to
    the old name
17. Any `claude --agent <old-name>` invocations anywhere on the filesystem
18. Any Claude Code `settings.json` or `settings.local.json` that references
    the old agent name in hooks, permissions, or env vars
19. Running Claude Code processes using the old agent name (tell user to
    restart their terminal)

## Required Verification Command

Before declaring a rename mission complete, run the grep gauntlet. Adjust
`OLD` and `NEW` per mission.

```bash
OLD="thorn"
NEW="armando"

# In-repo
rg -i "$OLD" ~/armando/

# Shell rc files (Linux/Mac)
rg -i "$OLD" ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null

# PowerShell (Windows; run under PowerShell)
# Select-String -Pattern $OLD -Path $PROFILE

# Installed symlinks
ls -la ~/.claude/agents/ ~/.claude/commands/ | rg -i "$OLD"

# Any loose references in home
rg -i "claude\s+.*--agent\s+$OLD" ~/ 2>/dev/null
```

**Every hit must be resolved or explicitly classified as intentional
historical reference (e.g., a CHANGELOG entry documenting the rename).**
Comment the intentional hits inline so future greps know they are expected.

## The Mission 00 Failure

Mission 00 renamed every agent file (Thorn → Armando) but left
`claude --agent thorn` in the installed shell wrapper inside `~/.bashrc`
(and the equivalent `function thorn` in `$PROFILE`). Because Claude Code
silently falls back to plain Claude Code when `--agent <name>` does not
resolve to an installed agent, sessions launched by typing `thorn` ran with
no agent soul at all. No error, no warning, just degraded output until
someone noticed responses had lost voice.

The rule above exists because this is non-obvious and silent. Treat
installers and rc files as first-class rename targets, not afterthoughts.

## Acceptance Criteria for a Rename Mission

A rename mission is complete when:

1. The grep gauntlet above returns zero unexpected hits across every listed
   surface
2. A clean-room install from the new repo produces a working
   `<new-name>` command that launches with the correct agent soul
3. A smoke test session with the new command confirms the agent identity
   (ask it "which agent are you?" and verify the answer)
4. Any user who had the old wrapper installed is told explicitly to
   re-source their shell profile or restart their terminal, with the exact
   command to run
5. The CHANGELOG entry for the rename lists every file that was touched

Until all five pass, the rename is not done. A heartbeat claim of
"rename complete" without the grep gauntlet is a false positive and a
Yellow-tier disclosure in the next heartbeat of any Horizon mission where
it happens.
