#!/bin/sh
# Install the selected standalone Lua utilities from lazyscripts.
set -eu

REPO_URL=${LAZYSCRIPTS_REPO_URL:-https://github.com/lakubuDavid/lazyscipts.git}
SCRIPT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=$SCRIPT_DIR
TEMP_DIR=

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  CYAN='\033[38;2;116;141;166m'; GREEN='\033[38;2;156;180;204m'; LAVENDER='\033[38;2;211;206;223m'; YELLOW='\033[38;2;242;215;217m'; RESET='\033[0m'
else
  CYAN=; GREEN=; LAVENDER=; YELLOW=; RESET=
fi

printf '%b\n' "${CYAN}========================================${RESET}"
printf '%b\n' "${CYAN}          lazyscripts installer${RESET}"
printf '%b\n' "${CYAN}========================================${RESET}"
printf '%b\n' "${GREEN}lazyscripts provides small Lua command-line utilities.${RESET}"
printf '%b\n' "${LAVENDER}todo       Markdown-backed task manager${RESET}"
printf '%b\n' "${LAVENDER}jp         fuzzy just-recipe picker${RESET}"
printf '%b\n' "${LAVENDER}zf         Zellij floating-pane command runner${RESET}"
printf '%b\n' "${LAVENDER}fancynames name and identifier helper${RESET}"
printf '%b\n' "${LAVENDER}wiki-init  wiki/documentation initializer${RESET}"
printf '%b' "${YELLOW}Continue and choose utilities to install? [y/N] ${RESET}"

if [ "${LAZYSCRIPTS_YES:-}" != "1" ] && [ "${LAZYSCRIPTS_YES:-}" != "true" ]; then
  if [ -r /dev/tty ]; then
    read -r answer </dev/tty || answer=
    case "$answer" in y|Y|yes|YES) ;; *) printf '%s\n' 'Installation cancelled.'; exit 0 ;; esac
  else
    printf '%s\n' 'error: no interactive terminal; set LAZYSCRIPTS_YES=1 to confirm' >&2
    exit 1
  fi
fi

if ! command -v lua >/dev/null 2>&1; then
  printf '%s\n' 'error: lua not found on PATH' >&2
  printf '%s\n' '       install Lua first (for example: mise use lua@latest)' >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'error: git not found on PATH' >&2
  exit 1
fi

if [ -f "$SOURCE_DIR/install.lua" ] && [ -f "$SOURCE_DIR/todo" ]; then
  : # use the local checkout
else
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/lazyscripts-install.XXXXXX")
  trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM
  printf '%b\n' "${CYAN}Cloning lazyscripts repository...${RESET}"
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR/lazyscripts"
  SOURCE_DIR=$TEMP_DIR/lazyscripts
fi

cd "$SOURCE_DIR"
printf '%b\n' "${CYAN}Choose utilities in the next prompt.${RESET}"
# curl | sh consumes stdin; explicitly use the terminal so selection does not
# silently become an empty choice that installs zero scripts.
if [ -r /dev/tty ]; then
  lua install.lua -i </dev/tty
else
  printf '%s\n' 'error: no interactive terminal for utility selection' >&2
  printf '%s\n' '       run with a terminal or use install.lua directly' >&2
  exit 1
fi

printf '%b\n' "${GREEN}Installation complete.${RESET}"
printf '%b\n' "${YELLOW}Add to PATH if needed:${RESET}"
printf '%s\n' '  export PATH="$HOME/.local/bin:$PATH"'
