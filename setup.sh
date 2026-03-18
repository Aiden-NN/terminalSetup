#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${GREEN}Starting Dotfiles Setup...${NC}"
echo "Dotfiles directory: $DOTFILES_DIR"

# 1. Install Dependencies
echo -e "${YELLOW} Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

echo -e "${YELLOW} Installing dependencies from Brewfile...${NC}"
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
else
    echo -e "${RED}Brewfile not found! Skipping bundle install.${NC}"
fi

# Install Hyper Terminal (Custom Location)
echo -e "${YELLOW} Checking Hyper Terminal...${NC}"
HYPER_APP_PATH="$HOME/Apps/Hyper.app"
if [ -d "$HYPER_APP_PATH" ]; then
    echo "Hyper is already installed at $HYPER_APP_PATH. Skipping."
else
    echo "Hyper not found at $HYPER_APP_PATH. Installing..."
    mkdir -p "$HOME/Apps"
    brew install --cask hyper --appdir="$HOME/Apps"
fi

# Install Oh My Zsh
echo -e "${YELLOW} Checking Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Install zsh-autocomplete plugin
echo -e "${YELLOW} Checking zsh-autocomplete plugin...${NC}"
ZSH_AUTOCOMPLETE_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"
if [ ! -d "$ZSH_AUTOCOMPLETE_DIR" ]; then
    echo "Installing zsh-autocomplete..."
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_AUTOCOMPLETE_DIR"
else
    echo "zsh-autocomplete is already installed."
fi

# Install pnpm
echo -e "${YELLOW} Checking pnpm...${NC}"
if ! command -v pnpm &> /dev/null; then
    echo "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
else
    echo "pnpm is already installed."
fi

# 2. Fonts
echo -e "${YELLOW} Installing Cartograph font...${NC}"
TEMP_DIR=$(mktemp -d)
git clone https://github.com/g5becks/Cartograph "$TEMP_DIR/Cartograph"
find "$TEMP_DIR/Cartograph" -name "*Cartograph*.otf" -o -name "*Cartograph*.ttf" | while read fontfile; do
    cp "$fontfile" ~/Library/Fonts/
done
rm -rf "$TEMP_DIR"
echo "Cartograph fonts installed to ~/Library/Fonts"

# 3. Binaries
echo -e "${YELLOW} Setting up binaries...${NC}"
if [ -f "$DOTFILES_DIR/bin/alloydb-auth-proxy" ]; then
    cp "$DOTFILES_DIR/bin/alloydb-auth-proxy" "$HOME/alloydb-auth-proxy"
    chmod +x "$HOME/alloydb-auth-proxy"
    echo "alloydb-auth-proxy installed to $HOME/"
else
    echo -e "${RED}alloydb-auth-proxy binary not found in dotfiles/bin!${NC}"
fi

# 4. Backup & Symlink
echo -e "${YELLOW} Linking configurations...${NC}"

backup_and_link() {
    local file=$1
    local source="$DOTFILES_DIR/$file"
    local dest="$HOME/$file"

    if [ -f "$dest" ] || [ -d "$dest" ]; then
        if [ -L "$dest" ]; then
             echo "$file is already a symlink. Skipping backup."
        else
             echo "Backing up existing $file to $file.backup"
             mv "$dest" "${dest}.backup"
        fi
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    fi
    
    ln -s "$source" "$dest"
    echo "$file linked."
}

# Handle .zshrc specifically
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "Found existing .zshrc (regular file). Appending source command..."
    if grep -q "source $DOTFILES_DIR/.zshrc" "$HOME/.zshrc"; then
        echo "Dotfiles configuration already sourced. Skipping."
    else
        # Create a backup just in case
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup_before_dotfiles"
        echo "Backed up .zshrc to .zshrc.backup_before_dotfiles"
        
        echo "" >> "$HOME/.zshrc"
        echo "# Load dotfiles configuration" >> "$HOME/.zshrc"
        echo "source $DOTFILES_DIR/.zshrc" >> "$HOME/.zshrc"
        echo "Appended source command to ~/.zshrc"
    fi
else
    backup_and_link ".zshrc"
fi
backup_and_link ".hyper.js"

# Link local Hyper plugins
mkdir -p "$HOME/.hyper_plugins/local"
if [ -d "$DOTFILES_DIR/.hyper_plugins/local/hyper-tab-search" ]; then
    rm -rf "$HOME/.hyper_plugins/local/hyper-tab-search"
    ln -s "$DOTFILES_DIR/.hyper_plugins/local/hyper-tab-search" "$HOME/.hyper_plugins/local/hyper-tab-search"
    echo "hyper-tab-search plugin linked."
fi

# Setup fzf
if [ -f "$HOME/.fzf.zsh" ]; then
    echo "Backing up existing .fzf.zsh"
    mv "$HOME/.fzf.zsh" "$HOME/.fzf.zsh.backup"
fi
echo -e "${YELLOW} Setting up fzf...${NC}"
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

echo -e "${GREEN}Setup Complete!${NC}"
echo "Please restart your terminal or run 'source ~/.zshrc'."
echo "Note: Ensure you have 'JetBrains Mono NF' font installed as well if needed."
