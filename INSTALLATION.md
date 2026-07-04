# Installing Armando

See [AGENTS.md](AGENTS.md) for what Armando is. This doc covers every install path in full.

## Standard install

```bash
# Linux/Mac
git clone git@github.com:kymorrand/armando.git ~/armando
cd ~/armando && chmod +x install.sh && ./install.sh

# Windows (PowerShell as Administrator)
git clone git@github.com:kymorrand/armando.git $HOME\armando
cd $HOME\armando; .\install.ps1
```

After installation, open any project directory and type `armando` to start.

### What the installer does

1. Symlinks `agents/*.md` → `~/.claude/agents/` (global agent definitions)
2. Symlinks `commands/*.md` → `~/.claude/commands/` (global slash commands)
3. Adds the `armando` shell function to your profile
4. Does NOT modify any project repos

## Portable install (Linux/Mac, no Node or Claude Code required)

For a bare machine that has only `curl`, `git`, and `bash`, use the portable bootstrap. It installs a local Node, the Claude Code CLI, and the armando repo into a single self-contained prefix (default `~/armando-portable/`). All Claude Code state lives inside the prefix via `CLAUDE_CONFIG_DIR`, so nothing leaks into the host `~/.claude/`.

```bash
# One-shot bootstrap (downloads ~80 MB of Node + Claude Code).
curl -fsSL https://raw.githubusercontent.com/kymorrand/armando/main/bootstrap.sh \
  | bash

# Authenticate Claude Code once.
claude login

# From any project directory:
armando
```

Override the install location with `ARMANDO_PORTABLE=/some/path` before running. Inspect the plan first with `bash bootstrap.sh --dry-run`.

To remove everything cleanly (symlinks, rc block, the entire prefix):

```bash
bash ~/armando-portable/armando/uninstall.sh           # interactive
bash ~/armando-portable/armando/uninstall.sh --yes     # non-interactive
```

The same `uninstall.sh` also handles the traditional install: it removes only symlinks whose targets resolve into the armando repo, strips the sentinel-bracketed rc block, and leaves `~/armando` itself alone.

## Portable install (Windows 11, no admin required)

For a fresh Windows 11 box that has only PowerShell (built in) and Git for Windows, use the PowerShell bootstrap. It lays down a local Node, the Claude Code CLI, and the armando repo into `$env:USERPROFILE\armando-portable\`. All Claude Code state lives inside the prefix via `CLAUDE_CONFIG_DIR`, so nothing leaks into `$HOME\.claude\`. No admin / no UAC: per-file links use NTFS hardlinks with a plain-copy fallback.

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

Override the install location with `$env:ARMANDO_PORTABLE = 'D:\armando'` before running. Inspect the plan first with `powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -DryRun`.

To remove everything cleanly (links, profile block, user scope `CLAUDE_CONFIG_DIR`, the entire prefix):

```powershell
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\armando-portable\armando\uninstall.ps1"            # interactive
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\armando-portable\armando\uninstall.ps1" -Yes       # non-interactive
```

The same `uninstall.ps1` also handles the traditional Windows install: it removes only links/copies whose target or content resolves into the armando repo, strips the sentinel-bracketed `$PROFILE` block, and leaves the repo itself in place.

## Updating

```bash
cd ~/armando && git pull
```

That's it — symlinks mean agents and commands update immediately.
