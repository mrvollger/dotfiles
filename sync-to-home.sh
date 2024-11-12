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

    # check if SRC and DEST are the same
    if [ "$SRC" == "$DEST" ]; then
        echo "$f" is already synced in the home directory
        continue
    elif [ -e "$DEST" ]; then
        echo "$f" is already in the home directory, existing file will be backed up
    else
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
