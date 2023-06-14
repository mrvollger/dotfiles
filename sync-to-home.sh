#!/bin/bash
mkdir -p ~/.config/alacrity ~/.config/lvim ~/.config/lvim/ftdetect ~/.config/lvim/syntax

# printf "if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi\n" >> ~/.bashrc

for f in .Rprofile .bash_aliases .condarc .inputrc .tmux.conf .vimrc 
do
	SRC=`realpath ${f}`
	DEST="${HOME}/."
	echo $SRC $DEST
	ln -s $@ $SRC $DEST
done


for f in \
	config/alacritty/alacritty.yml \
	config/lvim/config.lua \
	config/lvim/ftdetect/snakemake.vim \
	config/lvim/syntax/snakemake.vim \
	config/starship.toml 
do
	SRC=`realpath ${f}`
	DEST="${HOME}/.${f}"
	echo $SRC $DEST
	ln -s $@ $SRC $DEST
done
