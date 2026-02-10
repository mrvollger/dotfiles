
# install pixi
curl -fsSL https://pixi.sh/install.sh | sh

# see the sync script
Move things to their proper spots with the sync script

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install all my common tools using pixi
pixi global install


# intall conda/mamba
this changes all the time, see the latest instructions


# maybe things

## lunarvim 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install --lts
# Check https://www.lunarvim.org/docs/installation for latest install instructions
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)



