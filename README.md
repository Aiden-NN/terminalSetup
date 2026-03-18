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
    Clone this repository to any directory on your machine.

    ```bash
    git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Run the setup** (one command):
    ```bash
    npm run install
    ```
    Or directly:
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

### What `setup.sh` does:

*   **Installs Homebrew**: Checks if Homebrew is installed; if not, it installs it.
*   **Installs Dependencies**: Installs packages listed in `Brewfile` (using `brew bundle`), including:
    *   Development tools (git, gh, docker, neovim, etc.)
    *   Shell utilities (fzf, zoxide, starship, ripgrep, bat, etc.)
    *   **Jira CLI tools** (`jq` for JSON processing, `acli` for Atlassian CLI)
*   **Installs Hyper Terminal**: Installs Hyper.app to `~/Apps/Hyper.app`.
*   **Installs Oh My Zsh**: Sets up the Zsh framework.
*   **Installs Zsh Plugins**: Installs `zsh-autocomplete` plugin.
*   **Installs pnpm**: Installs the pnpm package manager.
*   **Installs Fonts**: Downloads and installs the **Cartograph** font to `~/Library/Fonts/`.
*   **Sets up Binaries**: Copies custom binaries (like `alloydb-auth-proxy`).
*   **Links Configurations**:
    *   For `.zshrc`: If you have an existing `.zshrc` file, the script will **append** a command to source the dotfiles configuration, preserving your existing settings. Passing a symlink or no file will fallback to creating a symlink.
    *   For `.hyper.js`: Symlinks the file, backing up any existing one.
*   **Sets up FZF**: Installs fzf key bindings and completion.

## Highlighted Features

These are the most powerful and frequently useful commands in this setup — great starting points for getting productive fast.

| Command | Category | Description |
|---------|----------|-------------|
| [`myPRs`](#github--pr-utilities) | GitHub | Personal PR dashboard — see all your open PRs with approval status, CI results, merge state, and unresolved comments at a glance |
| [`reviewNeeded`](#github--pr-utilities) | GitHub | Review queue dashboard — all PRs requesting your review with author, CI status, and merge state |
| [`jbranch`](#branch--commit-utilities) | Git | Pick an in-progress Jira ticket via fuzzy search and auto-create a correctly named `feature/` or `bugfix/` branch |
| [`gcmm`](#branch--commit-utilities) | Git | Auto-generate a conventional commit message from your branch name (e.g. `feat(NE-123): ...`), with Jira scope lookup and inline editing before committing |
| [`ghrepo`](#github-repository-management) | GitHub | Interactively create a GitHub repo for work or personal account, set visibility, and wire up the remote origin with the correct SSH host |
| [`killPort <port>`](#devops--work) | DevOps | Kill whatever process is occupying a given port — e.g. `killPort 3000` |
| [`zfunc`](#branch--commit-utilities) | Shell | Fuzzy-search all your custom shell functions and aliases with a live preview, then paste the selected one directly into your prompt |
| [`zgco`](#branch--commit-utilities) | Git | Fuzzy-find and checkout any local branch, with recent branches shown first |
| [`goto`](#github--pr-utilities) | GitHub | Open the current repo's GitHub page in your browser instantly |
| [`sshCheck`](#git-profile-check-sshcheck) | Git | Print the repo's remote URL, git user config, and test SSH connectivity — useful when switching between work and personal accounts |
| [`fs`](#file-finder-with-actions-fs) | Shell | Interactive file finder with preview (`fzf` + `bat`) — open, navigate to, or copy path/content of any file |
| [`gpup`](#git-utilities) | Git | Push the current branch and set upstream tracking in one command — supports custom remote targets |

---

## Configuration & Features

### Shell (Zsh)
*   **Theme**: Starship (if installed/configured).
*   **Plugins**: `git`, `zsh-autocomplete`.

---

## Aliases

### Editors

| Alias | Command | Description |
|-------|---------|-------------|
| `code` | `open -a "VisualStudioCode.app" .` | Open current directory in VS Code |
| `shell` | `agy ~/.zshrc` | Open shell config in Antigravity editor |
| `vim` | `nvim` | Use Neovim as the default vim |
| `copyPath` | `echo -n $PWD \| pbcopy` | Copy current directory path to clipboard |
| `clc` | `claude` | Shortcut for Claude CLI |

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `pul` | `git pull` | Pull latest changes from remote |
| `grs1` | `git reset --soft HEAD~1` | Soft reset last commit (keeps changes staged) |
| `grl` | `git reflog` | Show git reference log |
| `gbd` | `git branch -D` | Force delete a local branch |
| `grss` | `git reset --soft` | Soft reset to a specific commit |
| `gsts` | `git stash push` | Stash current changes |
| `gsta` | `git stash apply` | Apply the most recent stash |

### Node / NPM

| Alias | Command | Description |
|-------|---------|-------------|
| `dev` | `npm run dev` | Start development server |
| `lint` | `npm run lint` | Run linter |
| `build` | `npm run build` | Build the project |
| `test` | `npm run test:one-click-booking` | Run one-click-booking tests |
| `start` | `npm run start` | Start the application |

### File Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `fo` | `open $(fzf)` | Fuzzy-find a file and open it |
| `fd` | `open "$(dirname "$(fzf)")"` | Fuzzy-find a file and open its parent directory |

---

## Functions

### Git Utilities

| Function | Usage | Description |
|----------|-------|-------------|
| `gstsn <message>` | `gstsn "WIP feature"` | Stash changes with a named message |
| `gstan <index>` | `gstan 2` | Apply a specific stash by index |
| `grsho <branch>` | `grsho main` | Hard reset current branch to match `origin/<branch>` |
| `grbf <branch>` | `grbf develop` | Checkout a branch, hard reset it to origin, switch back, and rebase current branch onto it |
| `gbdo <branch>` | `gbdo old-feature` | Delete a remote branch on origin |
| `gpup [remote]` | `gpup` or `gpup upstream` | Push current branch and set upstream tracking (defaults to `origin`) |

### File Finder with Actions (`fs`)

Interactive file search using `fzf` with file preview (via `bat`). After selecting a file, choose an action:

1. Open the file
2. Open its directory
3. Navigate terminal to its directory
4. Copy the file's absolute path to clipboard
5. Copy the file's content to clipboard

```bash
fs
```

### Text Search with Actions (`ts`)

Interactive text search using `ripgrep` + `fzf` with syntax-highlighted preview. After selecting a match, choose an action:

1. Open file at the matching line (in VS Code or Neovim)
2. Open the file
3. Open its directory
4. Navigate terminal to its directory
5. Copy the file path to clipboard

```bash
ts
```

### Git Profile Check (`sshCheck`)

Displays the current repository's remote URL, git user config, and tests SSH connectivity. Useful for verifying you're using the correct SSH key and git identity.

```bash
sshCheck
```

### GitHub / PR Utilities

| Function | Usage | Description |
|----------|-------|-------------|
| `pr [target] [reviewers] [label]` | `pr develop` | Create a GitHub PR from current branch. Uses last commit as title, pushes branch, assigns default reviewers, and copies PR URL to clipboard |
| `approve_prs_by_author <username>` | `approve_prs_by_author john-doe` | Bulk-approve all open PRs by a specific author that are requesting your review (with confirmation prompt) |
| `goto` | `goto` | Open the current repository's GitHub page in your browser |
| `goto_pr` | `goto_pr` | Open the GitHub PR for the current branch, or the "create PR" page if none exists |
| `myPRs` | `myPRs` | Dashboard of all your open PRs across repos — shows approvals, CI status, merge state, unresolved comments, and quick-action commands |
| `reviewNeeded` | `reviewNeeded` | Dashboard of all open PRs requesting your review — shows author, CI status, merge state, and quick-action commands |
| `workflowRun` | `workflowRun` | Interactively select and trigger a GitHub Actions workflow. Prompts for inputs if the workflow accepts them, shows running workflows, and lets you pick a branch |

### PR Notification System

Automated background monitoring of your GitHub PRs with macOS notifications.

| Function | Description |
|----------|-------------|
| `notify_my_prs_status` | Manually check all your PRs and PRs requesting your review, send macOS notifications for actionable states |
| `start_pr_notifications` | Start background loop that checks PRs every 120 seconds |
| `stop_pr_notifications` | Stop the background monitoring loop |
| `clear_pr_notification_cache` | Clear notification cache to force re-sending all notifications |

**Notification scenarios:**

| Scenario | Description |
|----------|-------------|
| Ready to merge | PR has all approvals and checks passed |
| Has conflicts | PR has merge conflicts that need resolution |
| Check failed | A specific CI check failed (shows check name) |
| CI/CD failed | Overall CI/CD pipeline failed |
| Review requested | Someone requested your review on a PR |

### Branch & Commit Utilities

| Function | Usage | Description |
|----------|-------|-------------|
| `zgco` | `zgco` | Fuzzy-find and checkout a git branch (recent branches shown first) |
| `zfunc` | `zfunc` | Fuzzy-find and preview all custom shell functions/aliases from `.zshrc`, then paste the selected one into your prompt |
| `jbranch` | `jbranch` | Fetch your in-progress Jira tickets, pick one via fzf, and auto-create a `feature/` or `bugfix/` branch named from the ticket |
| `gcmm` | `gcmm` | Generate a conventional commit message from the current branch name (e.g., `feat(NE-123): add user login`). Fetches parent ticket from Jira for the scope. Lets you edit before committing |

### GitHub Repository Management

| Function | Usage | Description |
|----------|-------|-------------|
| `ghrepo` | `ghrepo` | Interactively create a new GitHub repo (work or personal account), set visibility, and optionally `git init` + set remote origin with the correct SSH host |
| `delRepo` | `delRepo` | Fuzzy-find from your GitHub repos and delete the selected one (with confirmation) |

### DevOps / Work

| Function | Usage | Description |
|----------|-------|-------------|
| `odsAuthConnect` | `odsAuthConnect` | Connect to AlloyDB via auth proxy for the ODS UAT environment on port 9999 |
| `dockerDaemonStart` | `dockerDaemonStart` | Start the Docker daemon using Colima |
| `killPort <port>` | `killPort 3000` | Kill any process running on the specified port |
| `killPid <pid>` | `killPid 12345` | Force kill a process by its PID |
| `rune2e <tag> <browser>` | `rune2e smoke chrome` | Run E2E tests with Playwright debug mode for a specific tag and browser |

### Editors & IDEs

| Function | Usage | Description |
|----------|-------|-------------|
| `cursor` | `cursor` | Open current directory in Cursor AI editor |
| `webstorm [path]` | `webstorm` or `webstorm ./src` | Open a path (or current directory) in WebStorm |
| `agy [path]` | `agy` or `agy ~/.zshrc` | Open a path (or current directory) in Antigravity editor |

### Jira CLI Functions

#### Project Management

| Function | Usage | Description |
|----------|-------|-------------|
| `jiraProjects` | `jiraProjects` | List all Jira projects you have access to |
| `jiraProjectsRecent` | `jiraProjectsRecent` | List recently viewed projects |
| `jiraProjectsExport [filename]` | `jiraProjectsExport out.json` | Export all projects to a JSON file (defaults to `jira-projects.json`) |
| `jiraProjectView <KEY>` | `jiraProjectView NE` | View details of a specific project |

#### Sprint Management (eCom3 Team)

| Function | Usage | Description |
|----------|-------|-------------|
| `ecom3Sprint` | `ecom3Sprint` | View all tickets in the eCom3 active sprint |
| `ecom3SprintMine` | `ecom3SprintMine` | View only your tickets in the eCom3 active sprint |
| `ecom3SprintSummary` | `ecom3SprintSummary` | Get sprint summary with ticket counts grouped by status |
| `ecom3SprintExport [filename]` | `ecom3SprintExport sprint.csv` | Export eCom3 sprint tickets to CSV |

#### Hierarchical Ticket View

| Function | Usage | Description |
|----------|-------|-------------|
| `jiraHierarchy [PROJECT-KEY]` | `jiraHierarchy NE` | View active sprint tickets organized by type (Epic, Story, Task, Bug, Sub-task) with color-coded status and priority indicators |
| `ecom3Hierarchy` | `ecom3Hierarchy` | Shortcut for `jiraHierarchy NE` |

### Hyper Terminal
*   **Theme**: Configured in `.hyper.js`.
*   **Plugins**: Includes a local `hyper-tab-search` plugin for searching through open tabs/sessions.

## Manual Steps Required

1.  **Restart Terminal**: After the script finishes, restart your terminal or run:
    ```bash
    source ~/.zshrc
    ```
2.  **Fonts**: The script installs **Cartograph**. Ensure your terminal (Hyper/Warp/iTerm2) is configured to use it.
    *   *Note*: The script also installs `JetBrains Mono NF` and `Fira Code NF` via Homebrew casks.

3.  **GitHub CLI Authentication**: To use PR and repo functions:
    ```bash
    gh auth login
    ```

4.  **Jira CLI Authentication** (Optional): To use Jira CLI features:
    ```bash
    acli auth login
    ```

## Troubleshooting

*   **Brewfile not found**: Ensure `Brewfile` exists in the dotfiles directory.
*   **Permission denied**: If you encounter permission errors running the script, try `chmod +x setup.sh`.
*   **Jira CLI not working**: Make sure you've authenticated with `acli auth login` and have access to the Jira projects you're querying.
*   **jq command not found**: Run `brew install jq` manually if it wasn't installed via Brewfile.
*   **ripgrep not found**: The `ts` function requires ripgrep. Run `brew install ripgrep`.
