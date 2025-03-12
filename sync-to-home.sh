#!/bin/bash

# check for -d flag
if [ "$1" == "-d" ] || [ "$1" == "-n" ]; then
    DRY_RUN=true
    shift
else
    DRY_RUN=false
fi

set -euo pipefail

git pull
mkdir -p ~/.config/alacritty ~/.config/lvim ~/.config/lvim/ftdetect ~/.config/lvim/syntax
mkdir -p ~/bin

# printf "if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi\n" >> ~/.bashrc

#start.sh \
for f in .Rprofile \
    .bash_aliases \
    .condarc \
    .inputrc \
    .tmux.conf \
    .vimrc \
    .gitconfig \
    bin/start.sh \
    .config/alacritty/alacritty.yml \
    .config/lvim/config.lua \
    .config/lvim/ftdetect/snakemake.vim \
    .config/lvim/syntax/snakemake.vim \
    .config/starship.toml; do
    SRC=$(realpath ${f})
    DEST="${HOME}/${f}"

    # check if SRC and DEST are the same, and check through symlinks
    if [ "$(realpath "$SRC")" == "$(realpath "$DEST")" ]; then
        # echo using a bright green bold color
        echo -e "\033[1;32m $f is already synced in the home directory \033[0m"
        continue
    elif [ -e "$DEST" ]; then
        echo
        # echo using bright red color
        echo -e "\033[1;31m $f is already in the home directory, existing file will be backed up \033[0m"
    else
        echo
        echo "$f" is not in the home directory
    fi

    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: ln -fs $SRC $DEST"
        if [ -e "$DEST" ]; then
            echo "DRY RUN: mv $DEST ${DEST}.bak"
            echo "test diff with:\ndiff ${DEST} $SRC"
        fi
        echo
    else
        # backup existing file
        if [ -e "$DEST" ]; then
            mv "$DEST" "${DEST}.bak"
        fi

        ln -fs "$@" "$SRC" "$DEST"
    fi
done
