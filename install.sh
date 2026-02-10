#!/usr/bin/env bash
set -euo pipefail

echo "=== Vollger Lab Dotfiles Install ==="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "Detected: macOS"
else
    OS="linux"
    echo "Detected: Linux"
fi

# -----------------------------------------------
# 1. Pixi (primary package manager)
# -----------------------------------------------
if ! command -v pixi &>/dev/null; then
    echo ""
    echo "--- Installing pixi ---"
    curl -fsSL https://pixi.sh/install.sh | sh
    export PATH="$HOME/.pixi/bin:$PATH"
else
    echo "pixi already installed"
fi

# -----------------------------------------------
# 2. Sync dotfiles (needs to happen early so pixi manifest is in place)
# -----------------------------------------------
echo ""
echo "--- Syncing dotfiles ---"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
./sync-to-home.sh

# -----------------------------------------------
# 3. Pixi global environments (CLI tools, bioinfo, R, Python, etc.)
# -----------------------------------------------
echo ""
echo "--- Installing pixi global environments ---"
echo "This installs: samtools, bedtools, bcftools, minimap2, starship, zoxide,"
echo "  bat, eza, fd, rg, hck, delta, dust, nvim, helix, R, Python, snakemake, etc."
pixi global sync

# -----------------------------------------------
# 4. Rust (via rustup)
# -----------------------------------------------
if ! command -v rustup &>/dev/null; then
    echo ""
    echo "--- Installing Rust ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust already installed ($(rustc --version))"
fi

# -----------------------------------------------
# 4. Cargo tools (not available via pixi)
# -----------------------------------------------
echo ""
echo "--- Installing cargo tools ---"
CARGO_TOOLS=(
    cargo-binstall
)
# Use binstall for faster binary installs after bootstrapping
if ! command -v cargo-binstall &>/dev/null; then
    cargo install cargo-binstall
fi

BINSTALL_TOOLS=(
    cargo-edit
    cargo-release
    cargo-udeps
    cargo-msrv
    cross
    flamegraph
    samply
    mdbook
    mdbook-toc
)
for tool in "${BINSTALL_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "Installing $tool..."
        cargo binstall -y "$tool" || echo "  (skipped $tool)"
    else
        echo "$tool already installed"
    fi
done

# -----------------------------------------------
# 5. uv (fast Python package manager)
# -----------------------------------------------
if ! command -v uv &>/dev/null; then
    echo ""
    echo "--- Installing uv ---"
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv already installed"
fi

# -----------------------------------------------
# 6. Atuin (shell history sync)
# -----------------------------------------------
if ! command -v atuin &>/dev/null; then
    echo ""
    echo "--- Installing atuin ---"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    echo "atuin already installed"
fi

# -----------------------------------------------
# 7. Claude Code
# -----------------------------------------------
if ! command -v claude &>/dev/null; then
    echo ""
    echo "--- Installing Claude Code ---"
    if command -v uv &>/dev/null; then
        uv tool install claude-code
    else
        echo "  (skipping — uv not available)"
    fi
else
    echo "Claude Code already installed"
fi

# -----------------------------------------------
# 8. Tmux Plugin Manager
# -----------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo ""
    echo "--- Installing tmux plugin manager ---"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "  NOTE: Run 'prefix + I' in tmux to install plugins"
else
    echo "tmux plugin manager already installed"
fi

# -----------------------------------------------
# 9. Alacritty themes (macOS only, or if alacritty is present)
# -----------------------------------------------
ALACRITTY_THEMES="$HOME/.config/alacritty/themes"
if [ ! -d "$ALACRITTY_THEMES" ]; then
    echo ""
    echo "--- Cloning alacritty themes ---"
    mkdir -p "$HOME/.config/alacritty"
    git clone https://github.com/alacritty/alacritty-theme "$ALACRITTY_THEMES"
else
    echo "Alacritty themes already present"
fi

# -----------------------------------------------
# 10. Conda/Mamba (optional — prompted)
# -----------------------------------------------
if ! command -v conda &>/dev/null; then
    echo ""
    read -p "Install miniconda? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "--- Installing miniconda ---"
        if [[ "$OS" == "macos" ]]; then
            curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o /tmp/miniconda.sh
        else
            curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
        fi
        bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
        rm /tmp/miniconda.sh
        eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"
        conda init zsh bash
        echo "  Conda installed. Restart shell or source your RC file."
    fi
else
    echo "Conda already installed"
fi

# -----------------------------------------------
# 11. macOS-specific: Homebrew
# -----------------------------------------------
if [[ "$OS" == "macos" ]]; then
    if ! command -v brew &>/dev/null; then
        echo ""
        read -p "Install Homebrew? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    else
        echo "Homebrew already installed"
    fi
fi

echo ""
echo "=== Install complete! ==="
echo ""
echo "Remaining manual steps:"
echo "  1. Run 'conda init zsh bash' if you installed conda"
echo "  2. Open tmux and press 'C-a I' to install tmux plugins"
echo "  3. Run 'atuin login' to sync shell history"
echo "  4. Run 'claude' to set up Claude Code"
echo "  5. Restart your shell: exec zsh (or exec bash)"
echo ""
echo "============================================"
echo "Add the following lines to your shell RC file"
echo "(.zshrc or .bashrc as appropriate):"
echo "============================================"

SHELL_NAME="zsh"
if [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
fi

cat <<'RCEOF'

# ---- PATH ----
export PATH="$HOME/.pixi/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# ---- Environment ----
export VISUAL=nvim
export EDITOR="$VISUAL"
export SNAKEMAKE_CONDA_PREFIX="$HOME/snakemake-conda-envs/"
export APPTAINER_CACHEDIR="$HOME/snakemake-conda-envs/apptainer-cache"

# ---- Cargo/Rust ----
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ---- Aliases ----
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"

# ---- FZF ----
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

RCEOF

echo "# ---- Tool Evals ----"
echo "# (adjust --shell flag for bash vs zsh)"
if [[ "$SHELL_NAME" == "zsh" ]]; then
cat <<'RCEOF'
command -v pixi &>/dev/null && eval "$(pixi completion --shell zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

# zoxide — skip in Claude Code sessions to avoid conflicts
if [[ -n "$PS1" ]] && [[ -z "$CLAUDECODE" ]]; then
    command -v zoxide &>/dev/null && eval "$(zoxide init --cmd cd zsh)"
fi
RCEOF
else
cat <<'RCEOF'
command -v pixi &>/dev/null && eval "$(pixi completion --shell bash)"
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v atuin &>/dev/null && eval "$(atuin init bash --disable-up-arrow)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion bash)"

# zoxide — skip in Claude Code sessions to avoid conflicts
if [[ -n "$PS1" ]] && [[ -z "$CLAUDECODE" ]]; then
    command -v zoxide &>/dev/null && eval "$(zoxide init --cmd cd bash)"
fi
RCEOF
fi

cat <<'RCEOF'

# ---- ZSH-specific (skip if using bash) ----
# Completions
autoload -Uz compinit && compinit
# History search with arrow keys
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "\e[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end

# ---- Conda (auto-added by 'conda init zsh/bash') ----
# Run: conda init zsh  (or conda init bash)

# ---- macOS only: Homebrew ----
# eval "$(/opt/homebrew/bin/brew shellenv)"

RCEOF

echo "============================================"
