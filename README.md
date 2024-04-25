git config --global init.defaultBranch main
git init .
git remote add origin git@github.com:mrvollger/unix-config.git
git pull origin main


printf "if [ -f ~/.bash_aliases ]; then\n\t. ~/.bash_aliases\nfi\n" >> ~/.bashrc

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -sS https://starship.rs/install.sh | sh
(curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash) || cargo install cargo-binstall



cargo binstall -y ripgrep
cargo binstall -y lsd
cargo binstall -y du-dust
cargo binstall -y fd-find
cargo binstall -y locate
cargo binstall -y tidy-viewer 
cargo binstall -y cargo-release
cargo binstall -y bat
cargo binstall -y git-delta
cargo binstall -y bottom
cargo binstall -y hyperfine
cargo binstall -y zoxide 
cargo binstall -y eza
cargo install hck

# https://alacritty.org/

# lunarvim 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh


