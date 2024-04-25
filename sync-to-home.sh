#!/bin/bash
set -euo pipefail

git pull 

mkdir -p ~/.config/alacritty ~/.config/lvim ~/.config/lvim/ftdetect ~/.config/lvim/syntax

# printf "if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi\n" >> ~/.bashrc

for f in .Rprofile .bash_aliases .condarc .inputrc .tmux.conf .vimrc start.sh
do
	SRC=`realpath ${f}`
	DEST="${HOME}/."
	echo $SRC $DEST
	ln -fs $@ $SRC $DEST
done


for f in \
	.config/alacritty/alacritty.yml \
	.config/lvim/config.lua \
	.config/lvim/ftdetect/snakemake.vim \
	.config/lvim/syntax/snakemake.vim \
	.config/starship.toml 
do
	SRC=`realpath ${f}`
	DEST="${HOME}/${f}"
	echo $SRC $DEST
	ln -fs $@ $SRC $DEST
done
