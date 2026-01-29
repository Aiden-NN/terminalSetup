# Dotfiles Setup

This repository contains my personal configuration files (dotfiles) and a setup script to automate the installation of my development environment on macOS.

## Prerequisites

*   **macOS**: This setup is designed for macOS.
*   **Git**: You need git installed to clone this repository.
    ```bash
    xcode-select --install
    ```
*   **Atlassian Account** (Optional): For Jira CLI features, you'll need an Atlassian account with access to Jira.

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
*   **Installs Dependencies**: Installs packages listed in `Brewfile` (using `brew bundle`), including:
    *   Development tools (git, gh, docker, etc.)
    *   Shell utilities (fzf, zoxide, starship, etc.)
    *   **Jira CLI tools** (`jq` for JSON processing, `acli` for Atlassian CLI)
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

### Jira CLI Functions

The `.zshrc` includes comprehensive Jira CLI integration with functions for managing projects, sprints, and tickets.

#### Project Management
*   `jiraProjects` - List all Jira projects you have access to
*   `jiraProjectsRecent` - List recently viewed projects (up to 20)
*   `jiraProjectsExport [filename]` - Export all projects to JSON file
*   `jiraProjectView <PROJECT-KEY>` - View details of a specific project

#### Sprint Management (eCom3 Team)
*   `ecom3Sprint` - View all tickets in eCom3 active sprint
*   `ecom3SprintMine` - View YOUR tickets in eCom3 active sprint
*   `ecom3SprintSummary` - Get sprint summary with counts by status
*   `ecom3SprintExport [filename]` - Export eCom3 sprint tickets to CSV

#### Hierarchical Ticket View
*   `jiraHierarchy [PROJECT-KEY]` - View sprint tickets organized by type with color coding
*   `ecom3Hierarchy` - Quick shortcut for eCom3 project hierarchy view

**Example Usage:**
```bash
# List all projects
jiraProjects

# View eCom3 sprint tickets
ecom3Sprint

# Get organized view by ticket type
ecom3Hierarchy

# Export sprint data
ecom3SprintExport sprint-$(date +%Y%m%d).csv
```

**Note:** These functions require `jq` (JSON processor) and `acli` (Atlassian CLI), which are installed automatically via the Brewfile.

### GitHub PR Notification Functions

The `.zshrc` includes an automated PR notification system that monitors your GitHub pull requests and sends macOS notifications for important events.

#### Features

- 🔔 **Automated Monitoring**: Background loop checks PRs every 2 minutes
- ✅ **Ready to Merge**: Notifies when PRs are ready to merge
- ⚠️ **Conflict Detection**: Alerts when PRs have merge conflicts
- 🚨 **CI/CD Failures**: Notifies when checks or CI/CD pipelines fail
- 🆕 **Review Requests**: Alerts when someone requests your review
- 💾 **Smart Caching**: Prevents duplicate notifications using hash-based cache

#### Available Functions

- `notify_my_prs_status` - Manually check PRs and send notifications
- `start_pr_notifications` - Start background monitoring loop (every 120 seconds)
- `stop_pr_notifications` - Stop the background monitoring loop
- `clear_pr_notification_cache` - Clear cache to force resend all notifications

#### Setup

1. **Authenticate with GitHub CLI**:
   ```bash
   gh auth login
   ```

2. **Start notifications** (optional - runs in background):
   ```bash
   start_pr_notifications
   ```

#### Notification Scenarios

The system notifies you when:

| Scenario | Icon | Description |
|----------|------|-------------|
| Ready to merge | ✅ | PR has all approvals and checks passed |
| Has conflicts | ⚠️ | PR has merge conflicts that need resolution |
| Check failed | 🚨 | Specific CI check failed (shows check name) |
| CI/CD failed | 🚨 | Overall CI/CD pipeline failed |
| Review requested | 🆕 | Someone requested your review on a PR |

#### Example Usage

```bash
# Manual check (one-time)
notify_my_prs_status

# Start automatic monitoring
start_pr_notifications
# Output: 🚀 Starting GitHub PR notifications loop (every 120 seconds)...

# Stop monitoring
stop_pr_notifications
# Output: ✅ Stopped PR notifications (PID: 12345)

# Clear cache to resend all notifications
clear_pr_notification_cache
```

**Note:** These functions require `gh` (GitHub CLI), `jq`, and optionally `terminal-notifier` for enhanced notifications. All are installed automatically via the Brewfile.

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

3.  **Jira CLI Authentication** (Optional): To use Jira CLI features, authenticate with your Atlassian account:
    ```bash
    acli auth login
    ```
    This will open your browser for OAuth authentication. Once completed, all Jira CLI functions will work seamlessly.

## Troubleshooting

*   **Brewfile not found**: Ensure `Brewfile` exists in `~/dotfiles/`.
*   **Permission denied**: If you encounter permission errors running the script, try `chmod +x setup.sh`.
*   **Jira CLI not working**: Make sure you've authenticated with `acli auth login` and have access to the Jira projects you're querying.
*   **jq command not found**: Run `brew install jq` manually if it wasn't installed via Brewfile.

