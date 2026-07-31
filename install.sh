#!/bin/sh
# install.sh - symlink lazyscripts (todo, jp, zf, fancynames) into ~/.local/bin
#
# Usage:
#   ./install.sh                 # link into ~/.local/bin (default)
#   ./install.sh ~/bin           # link into another directory
#   DEST=~/bin ./install.sh      # same, via env var
#
# Uses sudo only if the destination isn't writable (e.g. /usr/local/bin on
# root-owned systems); user dirs like ~/.local/bin need no sudo.

set -eu

# Directory containing this script (the repo root). Resolves relative paths
# so it works when invoked as ./install.sh or via a symlink in $PATH.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Every script in this collection is a Lua script, so lua is required.
if ! command -v lua >/dev/null 2>&1; then
    echo "error: lua not found on PATH — all lazyscripts are Lua scripts" >&2
    echo "       install it first (e.g. brew install lua) and re-run." >&2
    exit 1
fi

DEST="${1:-${DEST:-$HOME/.local/bin}}"
SCRIPTS="todo jp zf fancynames"

# Create the destination as the current user when possible; escalate to sudo
# only if it's missing and can't be created, or exists but isn't writable.
mkdir -p "$DEST" 2>/dev/null || true

SUDO=
if [ ! -w "$DEST" ]; then
    if [ -x /usr/bin/sudo ] || [ -x /bin/sudo ]; then
        SUDO=sudo
    fi
fi

# Make sure the destination is usable.
if ! $SUDO mkdir -p "$DEST" 2>/dev/null; then
    echo "error: cannot create/write $DEST" >&2
    exit 1
fi

installed=0
for s in $SCRIPTS; do
    src="$SCRIPT_DIR/$s"
    if [ ! -f "$src" ]; then
        echo "skip: $s (not found in $SCRIPT_DIR)" >&2
        continue
    fi
    # -n: don't follow an existing symlink (avoids the "is a directory" trap)
    # -f: replace any existing target
    $SUDO ln -sfn "$src" "$DEST/$s"
    echo "linked: $DEST/$s -> $src"
    installed=$((installed + 1))
done

echo "done: $installed script(s) linked into $DEST"
