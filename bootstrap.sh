#!/usr/bin/env bash
# Armando portable bootstrap.
#
# Brings Armando to a bare machine that has only curl, git, and bash.
# Installs a local Node, the Claude Code CLI, and the armando repo into a
# self-contained prefix at $ARMANDO_PORTABLE (default ~/armando-portable/).
# All Claude Code state is redirected into the prefix via CLAUDE_CONFIG_DIR.
#
# Usage:
#   bash bootstrap.sh            # install
#   bash bootstrap.sh --dry-run  # print the plan, touch no disk outside /tmp
#
# Remove with uninstall.sh from the cloned armando repo.

set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

NODE_VERSION="20.18.1"

# Known-good SHA-256 sums for the .tar.xz tarballs published by nodejs.org.
NODE_SHA_LINUX_X64="c6fa75c841cbffac851678a472f2a5bd612fff8308ef39236190e1f8dbb0e567"
NODE_SHA_DARWIN_X64="2f40325262474304101da93df9f1a0ced16fd11eabcc7aeec96c085a2e34e10f"
NODE_SHA_DARWIN_ARM64="68dbaeb8e37be25699c47788d00f2ec748ae6599e5f1696a695b1e3b4312db97"

ARMANDO_REPO_URL="${ARMANDO_REPO_URL:-https://github.com/kymorrand/armando.git}"
ARMANDO_PORTABLE="${ARMANDO_PORTABLE:-$HOME/armando-portable}"

DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "bootstrap.sh: unknown arg: $arg" >&2
            exit 2
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log()  { printf '[armando] %s\n' "$*"; }
warn() { printf '[armando] WARN: %s\n' "$*" >&2; }
die()  { printf '[armando] ERROR: %s\n' "$*" >&2; exit 1; }

require() {
    command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"
}

detect_platform() {
    local uname_s uname_m
    uname_s=$(uname -s)
    uname_m=$(uname -m)
    case "$uname_s" in
        Linux)
            case "$uname_m" in
                x86_64|amd64) echo "linux-x64" ;;
                *) die "unsupported Linux arch: $uname_m (need x86_64)" ;;
            esac
            ;;
        Darwin)
            case "$uname_m" in
                x86_64) echo "darwin-x64" ;;
                arm64|aarch64) echo "darwin-arm64" ;;
                *) die "unsupported Darwin arch: $uname_m" ;;
            esac
            ;;
        *)
            die "unsupported OS: $uname_s (Linux or Darwin only)"
            ;;
    esac
}

expected_node_sha() {
    case "$1" in
        linux-x64)    echo "$NODE_SHA_LINUX_X64" ;;
        darwin-x64)   echo "$NODE_SHA_DARWIN_X64" ;;
        darwin-arm64) echo "$NODE_SHA_DARWIN_ARM64" ;;
        *) die "no SHA pinned for platform $1" ;;
    esac
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        die "no sha256 tool found (need sha256sum or shasum)"
    fi
}

detect_rc_file() {
    local shell_name
    shell_name=$(basename "${SHELL:-bash}")
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *)    echo "$HOME/.profile" ;;
    esac
}

# ---------------------------------------------------------------------------
# Plan
# ---------------------------------------------------------------------------

PLATFORM=$(detect_platform)
NODE_DIR="$ARMANDO_PORTABLE/node"
CLAUDE_DIR="$ARMANDO_PORTABLE/claude"
REPO_DIR="$ARMANDO_PORTABLE/armando"
CLAUDE_HOME="$ARMANDO_PORTABLE/.claude-home"
RC_FILE=$(detect_rc_file)
NODE_TARBALL_NAME="node-v${NODE_VERSION}-${PLATFORM}.tar.xz"
NODE_TARBALL_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TARBALL_NAME}"

log "Armando portable bootstrap"
log "  prefix      : $ARMANDO_PORTABLE"
log "  platform    : $PLATFORM"
log "  node version: $NODE_VERSION"
log "  node dir    : $NODE_DIR"
log "  claude dir  : $CLAUDE_DIR"
log "  repo dir    : $REPO_DIR"
log "  CLAUDE_CONFIG_DIR: $CLAUDE_HOME"
log "  rc file     : $RC_FILE"
log "  node url    : $NODE_TARBALL_URL"

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY RUN: no downloads, no disk writes outside /tmp."
    log "Plan:"
    log "  1. mkdir -p $ARMANDO_PORTABLE/{node,claude,.claude-home}"
    log "  2. download + verify $NODE_TARBALL_NAME (sha256: $(expected_node_sha "$PLATFORM"))"
    log "  3. extract Node into $NODE_DIR (skip if already present)"
    log "  4. npm install --prefix $CLAUDE_DIR @anthropic-ai/claude-code (skip if already present)"
    log "  5. git clone $ARMANDO_REPO_URL $REPO_DIR (or git pull if present)"
    log "  6. CLAUDE_CONFIG_DIR=$CLAUDE_HOME bash $REPO_DIR/install.sh"
    log "  7. write sentinel-bracketed activation block into $RC_FILE"
    log "  8. print next-step instructions (claude login)"
    exit 0
fi

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------

require curl
require git
require tar
require uname

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------

mkdir -p "$ARMANDO_PORTABLE" "$NODE_DIR" "$CLAUDE_DIR" "$CLAUDE_HOME"

# ---------------------------------------------------------------------------
# Node
# ---------------------------------------------------------------------------

if [[ -x "$NODE_DIR/bin/node" ]]; then
    log "Node already installed at $NODE_DIR/bin/node ($("$NODE_DIR/bin/node" --version))"
else
    log "Downloading Node $NODE_VERSION ($PLATFORM)..."
    tmp_tarball=$(mktemp -t armando-node.XXXXXX.tar.xz)
    trap 'rm -f "$tmp_tarball"' EXIT
    if ! curl -fsSL "$NODE_TARBALL_URL" -o "$tmp_tarball"; then
        die "failed to download $NODE_TARBALL_URL"
    fi

    local_sha=$(sha256_of "$tmp_tarball")
    expected=$(expected_node_sha "$PLATFORM")
    if [[ "$local_sha" != "$expected" ]]; then
        die "Node tarball checksum mismatch. expected=$expected got=$local_sha"
    fi
    log "Node tarball checksum verified."

    log "Extracting Node into $NODE_DIR..."
    tmp_extract=$(mktemp -d -t armando-node-extract.XXXXXX)
    tar -xJf "$tmp_tarball" -C "$tmp_extract"
    extracted_root=$(find "$tmp_extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [[ -z "$extracted_root" ]]; then
        die "Node tarball extracted no directory"
    fi
    # Move contents (bin/, lib/, etc.) into $NODE_DIR, replacing any partials.
    cp -R "$extracted_root"/. "$NODE_DIR"/
    rm -rf "$tmp_extract" "$tmp_tarball"
    trap - EXIT
    log "Node installed: $("$NODE_DIR/bin/node" --version)"
fi

export PATH="$NODE_DIR/bin:$PATH"

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------

CLAUDE_BIN="$CLAUDE_DIR/node_modules/.bin/claude"
if [[ -x "$CLAUDE_BIN" ]]; then
    log "Claude Code already installed at $CLAUDE_BIN"
else
    log "Installing @anthropic-ai/claude-code into $CLAUDE_DIR..."
    if ! (cd "$CLAUDE_DIR" && npm install --silent --no-fund --no-audit --prefix "$CLAUDE_DIR" @anthropic-ai/claude-code); then
        die "npm install of @anthropic-ai/claude-code failed"
    fi
    [[ -x "$CLAUDE_BIN" ]] || die "Claude Code installed but $CLAUDE_BIN is not executable"
    log "Claude Code installed."
fi

# ---------------------------------------------------------------------------
# Armando repo
# ---------------------------------------------------------------------------

if [[ -d "$REPO_DIR/.git" ]]; then
    log "Armando repo already present at $REPO_DIR. Pulling latest..."
    (cd "$REPO_DIR" && git pull --quiet --ff-only) || warn "git pull failed; continuing with existing checkout"
else
    log "Cloning $ARMANDO_REPO_URL into $REPO_DIR..."
    git clone --quiet "$ARMANDO_REPO_URL" "$REPO_DIR" \
        || die "git clone failed: $ARMANDO_REPO_URL"
fi

# ---------------------------------------------------------------------------
# Symlink agents/commands into the portable CLAUDE_CONFIG_DIR
# ---------------------------------------------------------------------------

log "Running install.sh with CLAUDE_CONFIG_DIR=$CLAUDE_HOME..."
CLAUDE_CONFIG_DIR="$CLAUDE_HOME" bash "$REPO_DIR/install.sh" \
    || die "install.sh failed"

# ---------------------------------------------------------------------------
# Activation: write sentinel-bracketed rc block
# ---------------------------------------------------------------------------

write_activation_block() {
    local rc="$1"
    local marker_begin="# >>> armando-portable >>>"
    local marker_end="# <<< armando-portable <<<"

    if [[ -f "$rc" ]] && grep -qF "$marker_begin" "$rc"; then
        log "Activation block already present in $rc (idempotent skip)."
        return 0
    fi

    touch "$rc"
    {
        printf '\n%s\n' "$marker_begin"
        cat <<ACTIVATION
# Armando portable activation. Removable via uninstall.sh.
export ARMANDO_PORTABLE="$ARMANDO_PORTABLE"
if [ -x "\$ARMANDO_PORTABLE/node/bin/node" ]; then
    export CLAUDE_CONFIG_DIR="\$ARMANDO_PORTABLE/.claude-home"
    PATH="\$ARMANDO_PORTABLE/claude/node_modules/.bin:\$ARMANDO_PORTABLE/node/bin:\$PATH"
    export PATH
fi
armando() {
    if [ ! -x "\$ARMANDO_PORTABLE/node/bin/node" ]; then
        echo "armando: portable prefix missing at \$ARMANDO_PORTABLE" >&2
        return 1
    fi
    if [ -d "\$ARMANDO_PORTABLE/armando/.git" ]; then
        (cd "\$ARMANDO_PORTABLE/armando" && git pull --quiet 2>/dev/null) || true
    fi
    VERSION=\$(cat "\$ARMANDO_PORTABLE/armando/VERSION" 2>/dev/null || echo "dev")
    echo ""
    echo "  Armando v\${VERSION}: The Gardener (portable)"
    echo "  Let's go do it, dude."
    echo ""
    if [ -f ".venv/bin/activate" ]; then
        # shellcheck disable=SC1091
        . .venv/bin/activate
    fi
    claude --dangerously-skip-permissions --agent armando "\$@"
    if [ -d "\$ARMANDO_PORTABLE/armando/.git" ]; then
        (cd "\$ARMANDO_PORTABLE/armando" && \\
         git add -A && \\
         git diff --cached --quiet 2>/dev/null || \\
         (git commit -m "Session update from \$(hostname) on \$(date +%Y-%m-%d_%H%M)" --quiet && \\
          git push --quiet 2>/dev/null)) || true
    fi
}
ACTIVATION
        printf '%s\n' "$marker_end"
    } >> "$rc"

    log "Wrote activation block to $rc"
}

write_activation_block "$RC_FILE"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

cat <<DONE

[armando] Bootstrap complete.

Next steps:
  1. Open a new shell (or run: source "$RC_FILE")
  2. Authenticate Claude Code one time:
       claude login
  3. From any project directory, run:
       armando

To remove everything later:
       bash "$REPO_DIR/uninstall.sh"

DONE
