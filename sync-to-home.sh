#!/usr/bin/env bash

set -euo pipefail

# --- Defaults ---
DRY_RUN=false
INTERACTIVE=false

# --- Colors ---
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# --- Usage ---
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Sync dotfiles from this repo into the home directory via symlinks.
Existing files are backed up to <file>.bak before overwriting.

Options:
  -n, --dry-run      Show what would be done without making changes
  -i, --interactive   Prompt before overwriting conflicting files
  -f, --force         Overwrite conflicts without prompting (default)
  -h, --help          Show this help message and exit
EOF
    exit 0
}

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)   DRY_RUN=true; shift ;;
        -i|--interactive) INTERACTIVE=true; shift ;;
        -f|--force)     INTERACTIVE=false; shift ;;
        -h|--help)      usage ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# --- Sync one file ---
# Arguments: SRC DEST LABEL
#   SRC   - absolute path to the source file in this repo
#   DEST  - absolute path to the target location under $HOME
#   LABEL - short display name for messages (e.g. ".vimrc")
sync_file() {
    local SRC="$1" DEST="$2" LABEL="$3"

    # Already synced?
    if [ "$(realpath "$SRC" 2>/dev/null)" == "$(realpath "$DEST" 2>/dev/null)" ]; then
        echo -e "${GREEN} ${LABEL} is already synced${RESET}"
        return
    fi

    local exists=false
    if [ -e "$DEST" ]; then
        exists=true
        echo
        echo -e "${RED} ${LABEL} already exists — will be overwritten${RESET}"
    else
        echo
        echo "${LABEL} is not in the home directory"
    fi

    # --- Dry run ---
    if [ "$DRY_RUN" = true ]; then
        if [ "$exists" = true ]; then
            echo "DRY RUN: mv $DEST ${DEST}.bak"
        fi
        echo "DRY RUN: ln -fs $SRC $DEST"
        return
    fi

    # --- Interactive conflict resolution ---
    if [ "$INTERACTIVE" = true ] && [ "$exists" = true ]; then
        while true; do
            echo -e "${YELLOW}  Conflict: ${LABEL}${RESET}"
            echo -n "  [o]verwrite / [s]kip / [d]iff / [q]uit? "
            read -r choice
            case "$choice" in
                o|O)
                    break  # fall through to overwrite below
                    ;;
                s|S)
                    echo "  Skipping ${LABEL}"
                    return
                    ;;
                d|D)
                    diff "$DEST" "$SRC" || true
                    # re-prompt after showing diff
                    ;;
                q|Q)
                    echo "Aborting."
                    exit 0
                    ;;
                *)
                    echo "  Invalid choice, try again."
                    ;;
            esac
        done
    fi

    # --- Apply ---
    mkdir -p "$(dirname "$DEST")"
    if [ "$exists" = true ]; then
        mv "$DEST" "${DEST}.bak"
    fi
    ln -fs "$SRC" "$DEST"
}

# --- Pull latest ---
git pull

# --- Ensure target directories exist ---
mkdir -p ~/.config/alacritty ~/.config/lvim ~/.config/lvim/ftdetect ~/.config/lvim/syntax \
    ~/.pixi/manifests/ ~/.config/helix ~/.claude ~/.config/git ~/.config/atuin ~/bin

# --- Main file list ---
for f in .Rprofile \
    .bash_aliases \
    .condarc \
    .inputrc \
    .tmux.conf \
    .vimrc \
    .gitconfig \
    bin/start.sh \
    bin/set-hyak-node.sh \
    .pixi/manifests/pixi-global.toml \
    .config/alacritty/alacritty.yml \
    .config/lvim/config.lua \
    .config/lvim/ftdetect/snakemake.vim \
    .config/lvim/syntax/snakemake.vim \
    .config/helix/config.toml \
    .config/starship.toml \
    .claude/settings.json \
    .claude/CLAUDE.md \
    .config/git/ignore \
    .config/atuin/config.toml; do
    sync_file "$(realpath "${f}")" "${HOME}/${f}" "${f}"
done

# --- Claude desktop config (OS-specific destination) ---
for f in .config/claude-desktop/claude_desktop_config.json; do
    SRC=$(realpath "${f}")
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DEST="${HOME}/Library/Application Support/claude/$(basename "${f}")"
    else
        DEST="${HOME}/.config/claude/$(basename "${f}")"
    fi
    sync_file "$SRC" "$DEST" "$f"
done
