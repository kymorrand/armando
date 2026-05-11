# Sprint Contract: Portable Armando (Windows 11 native)

## Task

- **Agent:** root
- **Linear Issue:** none
- **Dispatched At:** 2026-05-11T16:08:00-04:00
- **Mode:** interactive
- **Summary:** Add native PowerShell bootstrap + uninstall for Windows 11, mirroring the Linux/Mac portable design. Same prefix structure, same teardown discipline, same auth flow.

## Scope

### Files to Touch

- [ ] `bootstrap.ps1` (NEW): Windows equivalent of `bootstrap.sh`. Downloads Node `win-x64.zip` from nodejs.org (same pinned 20 LTS version as bootstrap.sh, with the win-x64 SHA-256 added), extracts into `$env:USERPROFILE\armando-portable\node\`, runs `npm install --prefix` to install Claude Code CLI locally, clones the armando repo, sets `CLAUDE_CONFIG_DIR` via `[Environment]::SetEnvironmentVariable(..., 'User')`, writes a sentinel-bracketed block into the user's PowerShell `$PROFILE`, prints next-step instructions.
- [ ] `uninstall.ps1` (EDIT or REPLACE): full uninstall mirror. Strips sentinel block from `$PROFILE`, removes only symlinks/junctions in `$CLAUDE_CONFIG_DIR\agents` and `\commands` whose targets resolve into `$ARMANDO_DIR`, removes the user-scope `CLAUDE_CONFIG_DIR` env var if it points into the portable prefix, prompts before removing the prefix (`-Yes` flag bypasses). Inspect the existing `install.ps1` first to see what's there and decide whether to extend or replace.
- [ ] `install.ps1` (EDIT): wrap its `$PROFILE` append in the SAME sentinel markers used by Linux (`# >>> armando >>>` / `# <<< armando <<<`) so the same uninstall logic can strip either. Teach it to honor `$env:CLAUDE_CONFIG_DIR` (fall back to `$HOME\.claude` when unset) so bootstrap.ps1 can chain into it.
- [ ] `CLAUDE.md` (EDIT): expand the "Portable install" section with a Windows 11 subsection. Same shape as the Linux/Mac block: one-liner, auth step, run command, override, dry-run, teardown.
- [ ] `CHANGELOG.md` (EDIT, PREPEND): new 0.3.3 entry covering Windows 11 portable. Preserve all history (including the 0.3.2 entry just added).
- [ ] `VERSION` (EDIT): bump to `0.3.3`.

### Files NOT to Touch

- `bootstrap.sh`, `uninstall.sh`: Linux/Mac is done and verified; leave alone.
- `agents/*.md`, `commands/*.md`, `templates/*`, `playbook/*`: unchanged.
- `_grove/sprints/sprint-portable-armando.md` or its `.verify.json`: prior sprint, frozen.

### Repo State at Dispatch

**Working tree has uncommitted changes from the Linux portable sprint** (bootstrap.sh, uninstall.sh, install.sh edits, CLAUDE.md, CHANGELOG.md, VERSION at 0.3.2). They are reviewed and PASS. Do not revert or modify them. Stack the Windows work on top: VERSION goes 0.3.2 to 0.3.3, CHANGELOG prepends a new entry above the 0.3.2 one, CLAUDE.md gets a Windows subsection added below the existing Linux/Mac portable section.

## Acceptance Criteria

1. `bootstrap.ps1` runs successfully on a fresh Windows 11 box with only PowerShell 5.1+ (built-in) and an internet connection. Optionally Git for Windows — bootstrap should attempt to detect git and bail with a clear install hint (link to git-scm.com) if absent rather than silently failing.
2. No admin / no UAC elevation required. Everything lands under `$env:USERPROFILE\armando-portable\`. Symlinks specifically must NOT require admin: use **directory junctions** (`New-Item -ItemType Junction`) for directories, and either junctions, file copies, or `cmd /c mklink /H` hardlinks for individual agent/command files. Whatever works without admin. Document the chosen approach in a comment block at the top of the script.
3. The bootstrap script is idempotent: running it twice does not duplicate the `$PROFILE` block, does not re-download Node if the archive is already present, does not re-clone the repo if it exists (use `git pull` instead).
4. After bootstrap + `claude login` (run once in a fresh PowerShell), running `armando` from any project directory launches the Armando agent identically to a Linux portable install.
5. `uninstall.ps1` removes the sentinel block from `$PROFILE` using the same `# >>> armando >>>` / `# <<< armando <<<` markers. Surrounding content preserved. Backup file `.armando-bak` written next to `$PROFILE`.
6. `uninstall.ps1` removes only symlinks/junctions/hardlinks/copies in `$CLAUDE_CONFIG_DIR\agents` and `\commands` whose contents or target resolves into `$ARMANDO_DIR`. For copies (no link metadata), use a content-hash compare against the source file. Anything not matching: left alone.
7. `uninstall.ps1` clears `CLAUDE_CONFIG_DIR` (user scope) only if its current value points into the portable prefix being removed. If it points elsewhere (user customized it), leave it.
8. `uninstall.ps1` prompts before `Remove-Item -Recurse` of the prefix; `-Yes` flag bypasses.
9. Both PowerShell scripts use `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`. Clean error messages on failure (no raw PowerShell tracebacks for expected errors like "git not found" or "network unreachable").
10. The portable install does NOT write into `$HOME\.claude\`. All Claude state lives under the portable prefix via `CLAUDE_CONFIG_DIR`.
11. No em dashes anywhere. Project rule.
12. CHANGELOG entry is prepended above the 0.3.2 entry. VERSION reads `0.3.3`.
13. `--dry-run` (PowerShell convention: `-DryRun` switch parameter) prints the plan without downloads or disk writes outside `$env:TEMP`.

## Verification Commands

Run on Linux (lint + structural checks; full smoke requires Kyle on Windows):

```bash
# PowerShell syntax check via pwsh if installed; otherwise skip with a note
command -v pwsh && pwsh -NoProfile -Command "
  \$ErrorActionPreference='Stop';
  \$null = [System.Management.Automation.Language.Parser]::ParseFile('/home/kyle/armando/bootstrap.ps1', [ref]\$null, [ref]\$null);
  \$null = [System.Management.Automation.Language.Parser]::ParseFile('/home/kyle/armando/uninstall.ps1', [ref]\$null, [ref]\$null);
  \$null = [System.Management.Automation.Language.Parser]::ParseFile('/home/kyle/armando/install.ps1', [ref]\$null, [ref]\$null);
  Write-Output 'parse-ok'
"

# PSScriptAnalyzer if available (install with: pwsh -Command "Install-Module PSScriptAnalyzer -Scope CurrentUser -Force")
command -v pwsh && pwsh -NoProfile -Command "
  Invoke-ScriptAnalyzer -Path /home/kyle/armando/bootstrap.ps1,/home/kyle/armando/uninstall.ps1,/home/kyle/armando/install.ps1 -Severity Warning
"

# Em-dash sweep
! grep -P '[–—]' /home/kyle/armando/bootstrap.ps1 /home/kyle/armando/uninstall.ps1 /home/kyle/armando/install.ps1 /home/kyle/armando/CLAUDE.md /home/kyle/armando/CHANGELOG.md

# Sentinel marker presence
grep -q '# >>> armando >>>' /home/kyle/armando/bootstrap.ps1
grep -q '# <<< armando <<<' /home/kyle/armando/bootstrap.ps1
grep -q '# >>> armando >>>' /home/kyle/armando/install.ps1

# VERSION
[ "$(cat /home/kyle/armando/VERSION)" = "0.3.3" ]
```

Smoke testing on Windows is Kyle's job after the sprint lands. Document in the status report what Kyle should run on his Win11 box to verify.

## Verification Artifact (sidecar)

Write to `/home/kyle/armando/_grove/sprints/sprint-portable-armando-windows.verify.json` per the schema in `~/armando/agents/armando.md` "Fabrication hardening" section.

**Load-Bearing Claims:**

- `pwsh-parse-ok`: all three .ps1 files parse without syntax errors (or, if pwsh unavailable on dev host, mark `replayable: false` and note this gap in status report)
- `psscriptanalyzer-clean`: PSScriptAnalyzer reports zero Warning+ findings (or mark replayable:false if module unavailable)
- `no-em-dashes`: grep finds zero em dashes across .ps1 files + CLAUDE.md + CHANGELOG.md changes
- `sentinel-present`: sentinel markers present in bootstrap.ps1 and install.ps1
- `version-bumped`: VERSION reads 0.3.3

For each load-bearing claim that can't be mechanically verified on Linux (e.g. you don't have pwsh installed and can't install it), set `replayable: false` and explain in `stdout_tail` what Kyle should verify on the Win11 box. Don't fabricate.

## Parallelization Check

- **Other active agents:** none
- **Decision:** SINGLE AGENT

## Design notes (read before starting)

**Symlink strategy on Windows without admin:**
- Directory symlinks require admin OR Developer Mode. Don't rely on Developer Mode being on.
- **Directory junctions** (`New-Item -ItemType Junction`) do NOT require admin and behave like directory symlinks for most read use cases. They work for the agents/ and commands/ symlink targets if you junction the directories rather than individual files.
- **File hardlinks** (`New-Item -ItemType HardLink`) do NOT require admin on the same volume. This is likely the cleanest fit for per-file agent symlinks.
- **Plain copies** are a safe fallback. The downside is updates to the source don't propagate without re-running install — acceptable for the portable-install use case where users don't typically `git pull` the armando repo inside the prefix often.

Pick the simplest approach that works (likely hardlinks for individual files, with copy fallback). Document the choice in `bootstrap.ps1` comments.

**`$PROFILE` discovery:**
- `$PROFILE` is a string. The real targets are `$PROFILE.CurrentUserAllHosts` (preferred) and `$PROFILE.CurrentUserCurrentHost`. Write to `CurrentUserAllHosts` so both Windows PowerShell 5.1 and PowerShell 7+ pick it up.
- Create the parent directory if it doesn't exist (`$PROFILE`'s parent often doesn't on a fresh user).

**Auth:** do not automate `claude login`. Tell the user to run it once.

---

## Outcome

> To be filled by Armando after review.
