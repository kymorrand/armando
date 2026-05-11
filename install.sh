#!/usr/bin/env bash
# Armando: Linux/Mac Installer
# Symlinks agents and commands into Claude Code's config directories
# and adds the 'armando' command to your shell profile.
#
# Honors $CLAUDE_CONFIG_DIR (Claude Code's documented relocation env var).
# When unset, defaults to $HOME/.claude to preserve traditional behavior.

set -euo pipefail

ARMANDO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CLAUDE_AGENTS_DIR="$CLAUDE_CONFIG_DIR/agents"
CLAUDE_COMMANDS_DIR="$CLAUDE_CONFIG_DIR/commands"

echo "Installing Armando from: $ARMANDO_DIR"
echo "Target CLAUDE_CONFIG_DIR: $CLAUDE_CONFIG_DIR"
echo ""

# --- Create Claude Code directories ---
mkdir -p "$CLAUDE_AGENTS_DIR"
mkdir -p "$CLAUDE_COMMANDS_DIR"

# --- Symlink agents ---
echo "Linking agents..."
for agent in "$ARMANDO_DIR"/agents/*.md; do
    name=$(basename "$agent")
    target="$CLAUDE_AGENTS_DIR/$name"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        echo "  WARNING: $target exists and is not a symlink. Backing up to $target.bak"
        mv "$target" "$target.bak"
    fi
    ln -s "$agent" "$target"
    echo "  Linked: $name"
done

# --- Symlink commands ---
echo "Linking commands..."
for cmd in "$ARMANDO_DIR"/commands/*.md; do
    name=$(basename "$cmd")
    target="$CLAUDE_COMMANDS_DIR/$name"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        echo "  WARNING: $target exists and is not a symlink. Backing up to $target.bak"
        mv "$target" "$target.bak"
    fi
    ln -s "$cmd" "$target"
    echo "  Linked: $name"
done

# --- Add armando command to shell profile ---
# Portable installs handle their own activation block via bootstrap.sh,
# so only write the traditional block when CLAUDE_CONFIG_DIR is unset
# (or points at the default $HOME/.claude).
if [ "$CLAUDE_CONFIG_DIR" != "$HOME/.claude" ]; then
    echo ""
    echo "CLAUDE_CONFIG_DIR is non-default; skipping shell profile edit."
    echo "(The portable bootstrap manages its own activation block.)"
    echo ""
    echo "Done."
    exit 0
fi

SHELL_NAME=$(basename "${SHELL:-bash}")
if [ "$SHELL_NAME" = "zsh" ]; then
    PROFILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    PROFILE="$HOME/.bashrc"
else
    PROFILE="$HOME/.profile"
fi

# Idempotent: only one sentinel block, ever.
if grep -qF "# >>> armando >>>" "$PROFILE" 2>/dev/null; then
    echo ""
    echo "armando block already present in $PROFILE. Skipping."
    echo "Remove the block between '# >>> armando >>>' and '# <<< armando <<<' and re-run to refresh."
else
    {
        printf '\n%s\n' "# >>> armando >>>"
        cat <<'ARMANDO_FUNC'
# Armando: AI development team. Removable via uninstall.sh.
armando() {
    # Pull latest agent defs and handoffs before starting
    if [ -d "$HOME/armando/.git" ]; then
        (cd "$HOME/armando" && git pull --quiet 2>/dev/null) || true
    fi

    # Version banner
    VERSION=$(cat "$HOME/armando/VERSION" 2>/dev/null || echo "dev")
    echo ""
    echo "  Armando v${VERSION}: The Gardener"
    echo "  Let's go do it, dude."
    echo ""

    # Activate venv if present
    if [ -f ".venv/bin/activate" ]; then
        # shellcheck disable=SC1091
        . .venv/bin/activate
    fi

    # Launch Armando
    claude --dangerously-skip-permissions --agent armando "$@"

    # After session ends: commit and push any handoffs or changes
    if [ -d "$HOME/armando/.git" ]; then
        (cd "$HOME/armando" && \
         git add -A && \
         git diff --cached --quiet 2>/dev/null || \
         (git commit -m "Session update from $(hostname) on $(date +%Y-%m-%d_%H%M)" --quiet && \
          git push --quiet 2>/dev/null)) || true
    fi
}
ARMANDO_FUNC
        printf '%s\n' "# <<< armando <<<"
    } >> "$PROFILE"
    echo ""
    echo "Added armando block to $PROFILE"
fi

echo ""
echo "Done. Restart your shell or run: source $PROFILE"
echo "Then navigate to any project and type 'armando' to start."
