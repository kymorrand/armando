# Sprint Contract: Portable Armando

## Task

- **Agent:** root
- **Linear Issue:** none
- **Dispatched At:** 2026-05-11T15:53:40-04:00
- **Mode:** interactive
- **Summary:** Add a self-contained portable install mode so Armando can be bootstrapped on a bare machine (no Node, no Claude Code) from a single curl command, and removed cleanly with one teardown command.

## Scope

### Files to Touch

- [ ] `bootstrap.sh` (NEW): one-shot bootstrap for a bare machine. Downloads a local Node into `$ARMANDO_PORTABLE/node/`, installs `@anthropic-ai/claude-code` into `$ARMANDO_PORTABLE/claude/`, clones `armando` to `$ARMANDO_PORTABLE/armando/`, sets `CLAUDE_CONFIG_DIR` to `$ARMANDO_PORTABLE/.claude-home`, writes a sentinel-bracketed rc block, and prints next-step instructions (run `claude login` once, then `armando` from any project).
- [ ] `uninstall.sh` (NEW): inverse of bootstrap. Removes the sentinel-bracketed rc block, removes symlinks in `$CLAUDE_CONFIG_DIR/agents/` and `$CLAUDE_CONFIG_DIR/commands/` whose targets point into `$ARMANDO_DIR` (do not delete symlinks pointing elsewhere — protects host installs), restores any `*.bak` files, and prompts before `rm -rf` of the portable prefix. Must work for both portable installs (rm the whole prefix) and traditional installs (leave `~/armando` alone, just unlink and unhook).
- [ ] `install.sh` (EDIT): wrap the appended `armando()` shell function in sentinel markers `# >>> armando >>>` ... `# <<< armando <<<` so `uninstall.sh` can remove it deterministically with sed. Also detect if `CLAUDE_CONFIG_DIR` is already set and respect it (so traditional and portable installs coexist).
- [ ] `CLAUDE.md` (EDIT): add a "Portable install" section under "Installation" describing the one-liner bootstrap and the teardown command. Keep the existing traditional install section intact.
- [ ] `CHANGELOG.md` (EDIT, PREPEND): new entry at the top documenting the portable install path. Preserve all existing history.
- [ ] `VERSION` (EDIT): bump to `0.3.2`.

### Files NOT to Touch

- `install.ps1`: out of scope for this sprint (Linux/Mac only). Add a TODO comment in CHANGELOG noting Windows portable bootstrap is a follow-up.
- `agents/*.md`, `commands/*.md`, `templates/*`, `playbook/*`: agent and template content unchanged.
- Anything in `_ivy/`, `_grove/` other than this sprint file.

### Dependencies

- **Depends on:** none
- **Blocks:** none

## Acceptance Criteria

1. `bootstrap.sh` runs successfully on a Linux machine with only `curl`, `git`, and `bash` available. It must not require `sudo`, `apt`, `brew`, or `npm` to be preinstalled. Node and Claude Code both end up inside `$ARMANDO_PORTABLE` (default `~/armando-portable/`).
2. The bootstrap script is idempotent: running it twice does not duplicate the rc block or re-download already-present components.
3. After bootstrap + `claude login`, running `armando` from any project directory launches the Armando agent identically to a traditional install.
4. `uninstall.sh` removes the rc block via the sentinel markers (no greedy regex; works even if the user added their own content above or below the block).
5. `uninstall.sh` only removes symlinks whose target resolves into `$ARMANDO_DIR`. Verify with `readlink -f`. Symlinks pointing to other locations are left alone.
6. `uninstall.sh` prompts the user before deleting the portable prefix. A `--yes` flag bypasses the prompt for scripted teardown.
7. `install.sh` (the existing traditional installer) continues to work unchanged for users who already have Claude Code installed. The only behavioral change is the sentinel markers around the rc block.
8. The portable install does NOT write into the host's `~/.claude/` directory. All Claude state (agents, commands, sessions, auth) lives under the portable prefix via `CLAUDE_CONFIG_DIR`.
9. Both scripts use `set -euo pipefail` and have clean error messages on failure (no raw bash errors).
10. No em dashes anywhere in script output or doc edits. Project convention.
11. CHANGELOG entry is prepended (does not replace history). VERSION bumped to 0.3.2.

## Verification Commands

```bash
# Lint shell scripts
shellcheck ~/armando/bootstrap.sh ~/armando/uninstall.sh ~/armando/install.sh

# Smoke: bootstrap into a throwaway prefix, verify structure, then uninstall
TMPDIR=$(mktemp -d)
ARMANDO_PORTABLE="$TMPDIR/armando-portable" bash ~/armando/bootstrap.sh --dry-run
# (Implement a --dry-run flag that prints the plan without executing downloads.)

# Idempotency check
ARMANDO_PORTABLE="$TMPDIR/armando-portable" bash ~/armando/bootstrap.sh --dry-run
ARMANDO_PORTABLE="$TMPDIR/armando-portable" bash ~/armando/bootstrap.sh --dry-run
# Verify rc block count == 1

# Sentinel-block removal test
echo 'before' > /tmp/fake-rc
echo '# >>> armando >>>' >> /tmp/fake-rc
echo 'armando() { :; }' >> /tmp/fake-rc
echo '# <<< armando <<<' >> /tmp/fake-rc
echo 'after' >> /tmp/fake-rc
# Run uninstall's rc-cleanup function against /tmp/fake-rc, verify 'before' and 'after' remain.

# Em-dash check
! grep -P '[–—]' ~/armando/bootstrap.sh ~/armando/uninstall.sh ~/armando/CLAUDE.md ~/armando/CHANGELOG.md
```

## Verification Artifact (sidecar)

Write to `~/armando/_grove/sprints/sprint-portable-armando.verify.json`.

**Load-Bearing Claims:**

- `shellcheck-clean`: shellcheck passes with zero errors on all three scripts
- `dry-run-bootstrap-ok`: bootstrap --dry-run prints a coherent plan and exits 0
- `idempotent-rc-block`: running bootstrap twice results in exactly one sentinel block in the target rc file
- `sentinel-removal`: uninstall removes only the bracketed block, preserves surrounding content
- `symlink-safety`: uninstall leaves non-Armando symlinks alone
- `no-em-dashes`: grep finds zero em dashes in changed files
- `version-bumped`: VERSION reads 0.3.2

## Parallelization Check

- **Other active agents:** none
- **Decision:** SINGLE AGENT (no parallelization needed)

---

## Outcome

> To be filled by Armando after review.
