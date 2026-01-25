# Dotfiles Setup

This repository contains my personal configuration files (dotfiles) and a setup script to automate the installation of my development environment on macOS.

## Prerequisites

*   **macOS**: This setup is designed for macOS.
*   **Git**: You need git installed to clone this repository.
    ```bash
    xcode-select --install
    ```

## Installation

1.  **Clone the repository**:
    Clone this repository to your home directory. The setup script assumes the directory is named `dotfiles` and is located at `$HOME/dotfiles`.

    ```bash
    git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Run the setup script**:
    Make sure the script is executable and then run it.

    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

### What `setup.sh` does:

*   **Installs Homebrew**: Checks if Homebrew is installed; if not, it installs it.
*   **Installs Dependencies**: Installs packages listed in `Brewfile` (using `brew bundle`).
*   **Installs Hyper Terminal**: Installs Hyper.app to `~/Apps/Hyper.app`.
*   **Installs Oh My Zsh**: Sets up the Zsh framework.
*   **Installs Zsh Plugins**: Installs `zsh-autocomplete` and other plugins.
*   **Installs Fonts**: Downloads and installs the **Cartograph** font to `~/Library/Fonts/`.
*   **Sets up Binaries**: Copies custom binaries (like `alloydb-auth-proxy`).
*   **Links Configurations**: 
    *   For `.zshrc`: If you have an existing `.zshrc` file, the script will **append** a command to source the dotfiles configuration, preserving your existing settings. Passing a symlink or no file will fallback to creating a symlink.
    *   For `.hyper.js`: Symlinks the file, backing up any existing one.
*   **Sets up FZF**: Installs fzf key bindings and completion.

## Configuration & Features

### Shell (Zsh)
*   **Theme**: Starship (if installed/configured).
*   **Plugins**: `git`, `zsh-autocomplete`.
*   **Custom Aliases**:
    *   `pul`: `git pull`
    *   `dev`: `npm run dev`
    *   `build`: `npm run build`
    *   `pr`: Custom function to create GitHub PRs via CLI.
    *   `cursor`: Opens the current directory in Cursor AI editor.
    *   `webstorm`: Opens the current directory in WebStorm.
    *   See `.zshrc` for the full list.

### Hyper Terminal
*   **Theme**: Configured in `.hyper.js`.
*   **Plugins**: Includes a local `hyper-tab-search` plugin.

## Manual Steps Required

1.  **Restart Terminal**: After the script finishes, restart your terminal or run:
    ```bash
    source ~/.zshrc
    ```
2.  **Fonts**: The script installs **Cartograph**. Ensure your terminal (Hyper/Warp/iTerm2) is configured to use it.
    *   *Note*: The script also mentions `JetBrains Mono NF`. If you prefer that, you may need to install it manually or ensure it's in your fonts.

## Troubleshooting

*   **Brewfile not found**: Ensure `Brewfile` exists in `~/dotfiles/`.
*   **Permission denied**: If you encounter permission errors running the script, try `chmod +x setup.sh`.
