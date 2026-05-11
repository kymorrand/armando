#!/usr/bin/env bash
# Armando uninstall.
#
# Removes:
#   1. Symlinks under $CLAUDE_CONFIG_DIR/agents/ and $CLAUDE_CONFIG_DIR/commands/
#      that resolve into this armando repo. Non-Armando symlinks are left alone.
#   2. The sentinel-bracketed activation block from the user's rc file
#      (.zshrc, .bashrc, .profile). Surrounding content is preserved.
#   3. (Portable installs only.) The portable prefix at $ARMANDO_PORTABLE
#      after prompting the user. Use --yes to skip the prompt.
#
# Modes:
#   Portable install : ARMANDO_PORTABLE exists and contains node/, claude/, armando/
#   Traditional install : repo lives at $HOME/armando (default), prefix is untouched
#
# Usage:
#   bash uninstall.sh           # interactive
#   bash uninstall.sh --yes     # do not prompt before deleting the portable prefix
#   bash uninstall.sh --dry-run # report what would happen; touch nothing

set -euo pipefail

ARMANDO_DIR="$(cd "$(dirname "$0")" && pwd)"
ARMANDO_PORTABLE="${ARMANDO_PORTABLE:-$HOME/armando-portable}"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

YES=0
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --yes|-y) YES=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "uninstall.sh: unknown arg: $arg" >&2
            exit 2
            ;;
    esac
done

log()  { printf '[armando] %s\n' "$*"; }
warn() { printf '[armando] WARN: %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# 1. Symlink removal
# ---------------------------------------------------------------------------

remove_armando_symlinks() {
    local dir="$1"
    [[ -d "$dir" ]] || return 0
    local removed=0 kept=0
    local f target
    for f in "$dir"/*; do
        [[ -L "$f" ]] || continue
        target=$(readlink -f "$f" 2>/dev/null || true)
        if [[ -z "$target" ]]; then
            continue
        fi
        case "$target" in
            "$ARMANDO_DIR"/*)
                if [[ "$DRY_RUN" -eq 1 ]]; then
                    log "DRY-RUN: would remove symlink $f -> $target"
                else
                    rm -f "$f"
                    log "Removed symlink: $f"
                fi
                removed=$((removed + 1))
                ;;
            *)
                kept=$((kept + 1))
                ;;
        esac
    done
    log "$dir: removed $removed armando symlink(s), preserved $kept non-armando entr(ies)"
}

log "Scanning $CLAUDE_CONFIG_DIR for armando symlinks (repo: $ARMANDO_DIR)..."
remove_armando_symlinks "$CLAUDE_CONFIG_DIR/agents"
remove_armando_symlinks "$CLAUDE_CONFIG_DIR/commands"

# ---------------------------------------------------------------------------
# 2. RC-block cleanup
# ---------------------------------------------------------------------------

# Removes any block bounded by either sentinel pair from the given file.
# Supports both the traditional installer (# >>> armando >>>) and the
# portable bootstrap (# >>> armando-portable >>>).
strip_rc_block() {
    local rc="$1"
    [[ -f "$rc" ]] || return 0

    local before_lines after_lines
    before_lines=$(wc -l < "$rc" | tr -d ' ')

    if ! grep -qE '^# >>> armando(-portable)? >>>' "$rc"; then
        log "$rc: no armando block found, skipping."
        return 0
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: would strip armando sentinel block(s) from $rc"
        return 0
    fi

    # Portable and OS-X-friendly: use a temp file rather than sed -i quirks.
    local tmp
    tmp=$(mktemp -t armando-rc.XXXXXX)
    awk '
        /^# >>> armando(-portable)? >>>$/ { skip=1; next }
        /^# <<< armando(-portable)? <<<$/ { skip=0; next }
        skip != 1 { print }
    ' "$rc" > "$tmp"

    # Sanity: ensure file is still non-empty if it had non-block content before.
    after_lines=$(wc -l < "$tmp" | tr -d ' ')
    if [[ "$before_lines" -gt 0 && "$after_lines" -eq 0 ]]; then
        warn "rc cleanup would leave $rc empty; refusing. Backup at $tmp"
        return 1
    fi

    cp "$rc" "$rc.armando-bak"
    mv "$tmp" "$rc"
    log "Stripped armando block from $rc (backup at $rc.armando-bak)"
}

for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    strip_rc_block "$rc"
done

# Honor an explicit override too (e.g. fish users sourcing a custom file).
if [[ -n "${ARMANDO_RC:-}" ]]; then
    strip_rc_block "$ARMANDO_RC"
fi

# ---------------------------------------------------------------------------
# 3. Portable prefix removal (only when running from inside the portable prefix)
# ---------------------------------------------------------------------------

case "$ARMANDO_DIR" in
    "$ARMANDO_PORTABLE"/armando)
        log "Detected portable install (repo lives at $ARMANDO_DIR)."
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log "DRY-RUN: would rm -rf $ARMANDO_PORTABLE"
        else
            if [[ "$YES" -ne 1 ]]; then
                printf '[armando] Remove entire portable prefix at %s? [y/N] ' "$ARMANDO_PORTABLE"
                read -r reply < /dev/tty || reply=""
                case "$reply" in
                    y|Y|yes|YES) ;;
                    *) log "Skipped prefix removal. Re-run with --yes to force."; exit 0 ;;
                esac
            fi
            # Guard against catastrophic values.
            case "$ARMANDO_PORTABLE" in
                ""|"/"|"$HOME") warn "refusing to rm -rf $ARMANDO_PORTABLE"; exit 1 ;;
            esac
            rm -rf "$ARMANDO_PORTABLE"
            log "Removed $ARMANDO_PORTABLE"
        fi
        ;;
    *)
        log "Traditional install detected; leaving $ARMANDO_DIR in place."
        ;;
esac

log "Uninstall complete."
