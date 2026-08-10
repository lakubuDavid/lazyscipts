#!/bin/sh
# install.sh - bootstrap installer for lazyscripts
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/lakubuDavid/lazyscipts/main/install.sh | sh
#   wget -qO- https://raw.githubusercontent.com/lakubuDavid/lazyscipts/main/install.sh | sh
#   ./install.sh                    # local execution (also clones to temp)
#
# This script:
# 1. Checks for lua and git (fails if missing)
# 2. Clones the repo to a temp folder
# 3. Runs install.lua -i (interactive mode)
# 4. Cleans up the temp folder

set -eu

# Check for lua
if ! command -v lua >/dev/null 2>&1; then
    echo "error: lua not found on PATH" >&2
    echo "       install it first (e.g. brew install lua) and re-run." >&2
    exit 1
fi

# Try to determine script directory (works when run locally, fails when piped)
SCRIPT_DIR=""
if [ -n "$0" ] && [ "$0" != "-" ] && [ -f "$0" ]; then
    SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || SCRIPT_DIR=""
fi

# Check if we have local files
USE_LOCAL=false
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/install.lua" ] && [ -f "$SCRIPT_DIR/todo" ]; then
    USE_LOCAL=true
    INSTALL_DIR="$SCRIPT_DIR"
fi

# Check for git
if ! command -v git >/dev/null 2>&1; then
    echo "error: git not found on PATH" >&2
    echo "       install it first (e.g. brew install git) and re-run." >&2
    exit 1
fi

# Determine if we should use local files or clone
USE_LOCAL=false
if [ -f "$SCRIPT_DIR/install.lua" ] && [ -f "$SCRIPT_DIR/todo" ]; then
    USE_LOCAL=true
    INSTALL_DIR="$SCRIPT_DIR"
else
    # Clone to temp directory
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    echo "Cloning lazyscripts to temp directory..."
    if ! git clone --depth 1 https://github.com/lakubuDavid/lazyscipts.git "$TMPDIR/lazyscripts" 2>/dev/null; then
        echo "error: failed to clone repository" >&2
        exit 1
    fi
    INSTALL_DIR="$TMPDIR/lazyscripts"
fi

cd "$INSTALL_DIR"

echo "Running interactive install..."
lua install.lua -i

if [ "$USE_LOCAL" = "false" ]; then
    echo ""
    echo "Installation complete! Temp files cleaned up."
else
    echo ""
    echo "Installation complete!"
fi

echo "Make sure $HOME/.local/bin is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
