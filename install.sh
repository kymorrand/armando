#!/bin/bash
# Armando (The Gardener) — Linux/Mac Installer
# Symlinks agents and commands into Claude Code's global directories
# and adds the 'armando' command to your shell profile.

set -e

ARMANDO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

echo "Installing Armando from: $ARMANDO_DIR"
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
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
    PROFILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    PROFILE="$HOME/.bashrc"
else
    PROFILE="$HOME/.profile"
fi

# Check if armando function already exists
if grep -q "armando()" "$PROFILE" 2>/dev/null; then
    echo ""
    echo "armando command already exists in $PROFILE — skipping."
    echo "To update it, remove the existing armando() function from $PROFILE and re-run this installer."
else
    echo "" >> "$PROFILE"
    cat >> "$PROFILE" << 'ARMANDO_FUNC'

# Armando (The Gardener) — AI development team
armando() {
    # Pull latest agent defs and handoffs before starting
    if [ -d "$HOME/armando/.git" ]; then
        (cd "$HOME/armando" && git pull --quiet 2>/dev/null) || true
    fi

    # Version banner
    VERSION=$(cat "$HOME/armando/VERSION" 2>/dev/null || echo "dev")
    echo ""
    echo "  🌿 Armando v${VERSION} — The Gardener"
    echo "  Let's go do it, dude."
    echo ""

    # Activate venv if present
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
    fi

    # Launch Thorn
    claude --dangerously-skip-permissions --agent thorn

    # After session ends: commit and push any handoffs or changes
    if [ -d "$HOME/armando/.git" ]; then
        (cd "$HOME/armando" && \
         git add -A && \
         git diff --cached --quiet 2>/dev/null || \
         (git commit -m "Session update from $(hostname) — $(date +%Y-%m-%d_%H%M)" --quiet && \
          git push --quiet 2>/dev/null)) || true
    fi
}
ARMANDO_FUNC
    echo ""
    echo "Added armando command to $PROFILE"
fi

echo ""
echo "Done. Restart your shell or run: source $PROFILE"
echo "Then navigate to any project and type 'armando' to start."
