#!/bin/bash
mkdir -p ~/.config/alacrity ~/.config/lvim ~/.config/lvim/ftdetect ~/.config/lvim/syntax

# printf "if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi\n" >> ~/.bashrc

for f in .Rprofile .bash_aliases .condarc .inputrc .tmux.conf .vimrc; do
	ln -s `realpath $f` ~/.
done

