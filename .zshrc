# =============================================================================
# SYSTEM & PATH CONFIGURATION
# =============================================================================

# -- Environment Variables --
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"
export EDITOR="nvim"
export WARP_USE_SSH_WRAPPER=1 # Force Warp to use custom prompt

# -- PATH --
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Users/nam.nguyenv/.antigravity/antigravity/bin:$PATH" # Added by Antigravity
export PATH="/Users/nam.nguyenv/Library/Python/3.11/bin:$PATH"
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/nam.nguyenv/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

ZSH_THEME=""
plugins=(git)

source $ZSH/oh-my-zsh.sh

# -- Prompts & Tools --
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
	eval "$(starship init zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"

# =============================================================================
# TOOL INITIALIZATION
# =============================================================================

# -- NVM --
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# -- Google Cloud SDK --
if [ -f '/Users/nam.nguyenv/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nam.nguyenv/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/nam.nguyenv/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nam.nguyenv/google-cloud-sdk/completion.zsh.inc'; fi

# -- Tabtab (Electron Forge) --
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /Users/nam.nguyenv/Development/Projects/electron-quick-start/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/nam.nguyenv/Development/Projects/electron-quick-start/node_modules/tabtab/.completions/electron-forge.zsh

# =============================================================================
# ALIASES
# =============================================================================

# -- Editors --
alias code="open -a \"/Users/nam.nguyenv/Apps/VisualStudioCode.app\" ."
alias shell='code ~/.zshrc'
alias claudeFolder='agy ~/.claude'
alias vim="nvim"
alias copyPath='echo -n $PWD | pbcopy'
alias clc=claude

# -- Git --
alias pul="git pull"
alias grs1="git reset --soft HEAD~1"
alias grl="git reflog"
alias gbd="git branch -D"
alias grss="git reset --soft"
alias gsts="git stash push --include-untracked"
alias gsta="git stash apply"
function gstsn() { git stash save --include-untracked -m "$1"; }

# -- Node / NPM --
alias dev="npm run dev"
alias lint="npm run lint"
alias build="npm run build"
alias test="npm run test:one-click-booking"
alias start="npm run start"
alias fo='open $(fzf)'
alias fd='open "$(dirname "$(fzf)")"'

# =============================================================================
# FUNCTIONS
# =============================================================================

# --------------------------
# File Utilities
# --------------------------

function copyfile() { cat "$1" | pbcopy && echo "Copied: $1"; }

# --------------------------
# Git Utilities
# --------------------------

function gstan() { git stash apply stash@{"$1"}; }

function grsho() { git reset --hard origin/"$1"; }

function grbf() {
	git checkout "$1"
	git reset --hard origin/"$1"
	git checkout -
	git rebase "$1"
}

function checkVMSpace() {
	colima ssh -- df -h / | tail -1
}

function gbdo() { git push origin --delete "$1"; }

function gpup() {
	local remote="${1:-origin}"
	local current_branch=$(git rev-parse --abbrev-ref HEAD)
	echo "Pushing and setting upstream for branch: $current_branch to remote: $remote"
	git push --set-upstream "$remote" "$current_branch"
}

# --------------------------
# File Finder with Actions
# --------------------------

function fs() {
	# Use fzf to search for a file (excluding ~/Library)
	local selected_file
	# Set FZF_DEFAULT_COMMAND to use find and exclude Library folders
	FZF_DEFAULT_COMMAND="find . -type f -not -path '*/Library/*' -not -path '$HOME/Library/*' 2>/dev/null" \
		selected_file=$(fzf --prompt="Search for file: " --height=100% --preview="bat --color=always --style=numbers {}" 2>/dev/null || fzf --prompt="Search for file: " --height=60%)
	
	# Exit if no file was selected
	if [ -z "$selected_file" ]; then
		echo "No file selected"
		return 0
	fi
	
	# Get the directory containing the file
	local file_dir=$(dirname "$selected_file")
	
	# Prompt user for action
	echo "\nSelected: $selected_file"
	echo "\nChoose an action:"
	echo "  1) Open file"
	echo "  2) Open directory"
	echo "  3) Navigate terminal"
	echo "  4) Copy file path"
	echo "  5) Copy file content"
	echo "  q) Quit"

	# Read user choice
	read -k 1 "choice?"
	echo "\n"

	case "$choice" in
		1)
			echo "Opening file: $selected_file"
			if command -v open >/dev/null 2>&1; then
				# macOS
				open "$selected_file"
			elif command -v xdg-open >/dev/null 2>&1; then
				# Linux
				xdg-open "$selected_file"
			else
				# Fallback to default editor
				${EDITOR:-vim} "$selected_file"
			fi
			;;
		2)
			echo "Opening directory: $file_dir"
			if command -v open >/dev/null 2>&1; then
				# macOS
				open "$file_dir"
			elif command -v xdg-open >/dev/null 2>&1; then
				# Linux
				xdg-open "$file_dir"
			else
				echo "Cannot open directory in file manager"
			fi
			;;
		3)
			echo "Navigating to: $file_dir"
			cd "$file_dir"
			;;
		4)
			local abs_path
			abs_path="$(cd "$(dirname "$selected_file")" && pwd)/$(basename "$selected_file")"
			echo "Copying path to clipboard: $abs_path"
			if command -v pbcopy >/dev/null 2>&1; then
				printf '%s' "$abs_path" | pbcopy
				echo "✓ Path copied to clipboard"
			elif command -v xclip >/dev/null 2>&1; then
				printf '%s' "$abs_path" | xclip -selection clipboard
				echo "✓ Path copied to clipboard"
			else
				echo "Clipboard command not found. Path: $abs_path"
			fi
			;;
		5)
			echo "Copying file content to clipboard: $selected_file"
			if command -v pbcopy >/dev/null 2>&1; then
				cat "$selected_file" | pbcopy
				echo "✓ File content copied to clipboard"
			elif command -v xclip >/dev/null 2>&1; then
				cat "$selected_file" | xclip -selection clipboard
				echo "✓ File content copied to clipboard"
			else
				echo "Clipboard command not found"
			fi
			;;
		q|Q)
			echo "Cancelled"
			;;
		*)
			echo "Invalid choice"
			;;
	esac
}

# --------------------------
# Text Search with Actions
# --------------------------

function ts() {
	# Check if ripgrep is installed
	if ! command -v rg >/dev/null 2>&1; then
		echo "Error: ripgrep (rg) is not installed. Install it with: brew install ripgrep"
		return 1
	fi
	
	# Prompt for search term
	echo "Enter search term:"
	read -r search_term
	
	# Exit if no search term provided
	if [ -z "$search_term" ]; then
		echo "No search term provided"
		return 0
	fi
	
	echo "Searching for: '$search_term'"
	echo ""
	
	# Use ripgrep with fzf for interactive selection (excluding ~/Library)
	local selected
	selected=$(rg --line-number --color=always --smart-case --glob='!Library/' --glob="!$HOME/Library/**" "$search_term" 2>/dev/null | \
		fzf --ansi \
		    --height=100% \
		    --delimiter=: \
		    --preview='bat --color=always --style=numbers --highlight-line {2} {1}' \
		    --preview-window=right:60%:wrap \
		    --prompt="Select match: " \
		    --bind="enter:accept")
	
	# Exit if no selection made
	if [ -z "$selected" ]; then
		echo "No match selected"
		return 0
	fi
	
	# Parse the selected line (format: filename:line:content)
	local file_path=$(echo "$selected" | cut -d: -f1)
	local line_number=$(echo "$selected" | cut -d: -f2)
	local file_dir=$(dirname "$file_path")
	
	# Prompt user for action
	echo "\nSelected: $file_path:$line_number"
	echo "\nChoose an action:"
	echo "  1) Open file at line"
	echo "  2) Open file"
	echo "  3) Open directory"
	echo "  4) Navigate terminal"
	echo "  5) Copy file path"
	echo "  q) Quit"
	
	# Read user choice
	read -k 1 "choice?"
	echo "\n"
	
	case "$choice" in
		1)
			echo "Opening file at line $line_number: $file_path"
			if command -v code >/dev/null 2>&1; then
				# VS Code
				code -g "$file_path:$line_number"
			elif [ "$EDITOR" = "nvim" ] || [ "$EDITOR" = "vim" ]; then
				# Neovim/Vim
				$EDITOR "+$line_number" "$file_path"
			else
				# Fallback
				${EDITOR:-vim} "$file_path"
			fi
			;;
		2)
			echo "Opening file: $file_path"
			if command -v open >/dev/null 2>&1; then
				# macOS
				open "$file_path"
			elif command -v xdg-open >/dev/null 2>&1; then
				# Linux
				xdg-open "$file_path"
			else
				# Fallback to editor
				${EDITOR:-vim} "$file_path"
			fi
			;;
		3)
			echo "Opening directory: $file_dir"
			if command -v open >/dev/null 2>&1; then
				# macOS
				open "$file_dir"
			elif command -v xdg-open >/dev/null 2>&1; then
				# Linux
				xdg-open "$file_dir"
			else
				echo "Cannot open directory in file manager"
			fi
			;;
		4)
			echo "Navigating to: $file_dir"
			cd "$file_dir"
			;;
		5)
			echo "Copying path to clipboard: $file_path"
			if command -v pbcopy >/dev/null 2>&1; then
				# macOS
				echo "$file_path" | pbcopy
				echo "✓ Path copied to clipboard"
			elif command -v xclip >/dev/null 2>&1; then
				# Linux
				echo "$file_path" | xclip -selection clipboard
				echo "✓ Path copied to clipboard"
			else
				echo "Clipboard command not found. Path: $file_path"
			fi
			;;
		q|Q)
			echo "Cancelled"
			;;
		*)
			echo "Invalid choice"
			;;
	esac
}

# --------------------------
# Git Profile Check
# --------------------------

function sshCheck() {
    # 1. Get the remote URL
    local remote_url=$(git remote get-url origin 2>/dev/null)
    if [ -z "$remote_url" ]; then
        echo "❌ Not a git repository or no remote 'origin' found."
        return 1
    fi
    echo "📦 Remote: $remote_url"

    # 2. Extract the hostname
    # Handles: git@github.com:user/repo, ssh://git@github.com/..., https://github.com/...
    local host=""
    if [[ "$remote_url" =~ "^http" ]]; then
        echo "⚠️  Using HTTPS, not SSH. Credential helper is used instead of SSH keys."
        host=$(echo "$remote_url" | awk -F/ '{print $3}')
    else
        # Extract host from SCP-like syntax (user@host:path) or SSH syntax (ssh://user@host/path)
        host=$(echo "$remote_url" | sed -E 's/.*@//' | sed -E 's/:.*//' | sed -E 's/\/.*//')
    fi

    # 3. Check Git Config signature
    echo "👤 Git Config: $(git config user.name) <$(git config user.email)>"

    # 4. Test SSH Connection
    if [[ "$remote_url" =~ "^http" ]]; then
        return 0
    fi

    echo "🔑 Testing SSH connection to '$host'..."
    # ssh -vT will show the exact key file being offered
    # We grep for "Offering public key" or the final identity message
    ssh -vT "git@$host" 2>&1 | grep -E "Offering public key|Authenticated to|Hi" | head -n 5
}

# --------------------------
# GitHub / PR Utilities
# --------------------------

function pr() {
	if [ "$#" -gt 3 ]; then
		echo "Usage: pr [target-branch] [reviewers] [label]"
		return 1
	fi

	current_branch=$(git branch --show-current)
	default_target_branch="develop"
	default_reviewers="son-tranhh-otsv,sy-nguyenv-otsv,hoang-trant-otsv,anh-nguyenpn-otsv,khiem-let-otsv"
	default_label=""

	if [ -z "$current_branch" ]; then
		echo "Error: Not currently on a branch"
		return 1
	fi

	target_branch=${1:-$default_target_branch}
	reviewers=${2:-$default_reviewers}

	# Push and set upstream
	echo "Pushing and setting upstream for branch: $current_branch"
	git push --set-upstream origin "$current_branch" || echo "Push failed (possibly branch exists), proceeding with PR creation..."

	# Use last commit message as PR title and empty body
	pr_title="$(git log --oneline -1 --pretty=format:'%s')"

	# Capture the output of gh pr create
	pr_output=$(gh pr create --title "$pr_title" \
		--body "" \
		--base "$target_branch" \
		--head "$current_branch" \
		--repo "$(git remote get-url origin)" \
		--reviewer "$reviewers" \
		--label "${3:-$default_label}")

	# Display the output
	echo "$pr_output"

	# Extract the PR URL (last line of output) and copy to clipboard
	pr_url=$(echo "$pr_output" | tail -n 1)
	echo "$pr_url" | pbcopy
	echo "✓ PR link copied to clipboard!"
}

function addReviewers() {
	local default_reviewers="son-tranhh-otsv,sy-nguyenv-otsv,hoang-trant-otsv,anh-nguyenpn-otsv,khiem-let-otsv,dung-buin-otsv"
	local reviewers=${1:-$default_reviewers}

	local prs=$(gh search prs --author=@me --state=open --json repository,number --jq '.[] | "\(.repository.nameWithOwner) \(.number)"')

	if [[ -z "$prs" ]]; then
		echo "No open PRs found."
		return 0
	fi

	echo "$prs" | while read -r repo pr_number; do
		echo "Adding reviewers to $repo#$pr_number..."
		gh pr edit "$pr_number" --repo "$repo" --add-reviewer "$reviewers"
	done
}

approve_prs_by_author() {
	# Check if username argument is provided
	if [[ -z "$1" ]]; then
		echo "Usage: approve_prs_by_author <github_username>"
		echo "Error: Please provide the GitHub username of the PR author."
		return 1
	fi

	# Check for dependencies
	if ! command -v gh &>/dev/null; then
		echo "Error: GitHub CLI 'gh' not found. Please install it."
		return 1
	fi
	if ! command -v jq &>/dev/null; then
		echo "Error: 'jq' not found. Please install it (e.g., 'brew install jq')."
		return 1
	fi

	local author_username=$1
	local current_user=$(gh api user --jq .login) # Get current logged-in user

	echo "Searching for open PRs authored by '$author_username' requesting a review from '$current_user'..."

	# Search for PRs using gh search and format output as JSON
	local pr_list_json
	pr_list_json=$(gh search prs --author="$author_username" --review-requested=@me --state=open --limit=100 --json url 2>&1)

	# Check if gh search command was successful
	if [[ $? -ne 0 ]]; then
		echo "Error searching for PRs:"
		echo "$pr_list_json" # Print the error message from gh
		return 1
	fi

	# Check if any PRs were found
	if [[ -z "$pr_list_json" ]] || [[ "$(echo "$pr_list_json" | jq 'length')" -eq 0 ]]; then
		echo "No open PRs found authored by '$author_username' requesting your review."
		return 0
	fi

	echo "Found the following PRs to approve:"
	# List PR URLs found
	echo "$pr_list_json" | jq -r '.[] | .url'

	# --- SAFETY CONFIRMATION ---
	echo "\n⚠️ WARNING: This will approve ALL listed PRs without individual review."
	local pr_count
	pr_count=$(echo "$pr_list_json" | jq 'length')
	read -q "choice?REALLY approve all $pr_count PR(s) by $author_username? (y/N): "
	echo # Add a newline after the prompt

	if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
		echo "Approval cancelled."
		return 0
	fi
	# --- END SAFETY CONFIRMATION ---

	echo "\nProceeding with approvals..."

	# Iterate through each PR URL found and approve it
	echo "$pr_list_json" | jq -r '.[] | .url' | while read -r pr_url; do
		if [[ -n "$pr_url" ]]; then
			echo "Approving PR: $pr_url"
			gh pr review "$pr_url" --approve
			if [[ $? -ne 0 ]]; then
				echo "Error approving PR: $pr_url. Continuing..."
			fi
		fi
	done

	echo "\nApproval process finished."
}

goto() { gh repo view --json url --jq '.url' | xargs open; }

myPRs() {
	gh api graphql -f query='
query {
  search(query: "is:pr is:open author:@me", type: ISSUE, first: 100) {
    edges {
      node {
        ... on PullRequest {
          number
          title
          url
          headRefName
          baseRefName
          repository {
            nameWithOwner
          }
          reviews(first: 100) {
            totalCount
            nodes {
              state
            }
          }
          commits(last: 1) {
            nodes {
              commit {
                statusCheckRollup {
                  state
                  contexts(first: 100) {
                    totalCount
                    nodes {
                      ... on StatusContext {
                        state
                        context
                      }
                      ... on CheckRun {
                        status
                        conclusion
                        name
                      }
                    }
                  }
                }
              }
            }
          }
          reviewThreads(first: 100) {
            totalCount
            nodes {
              isResolved
              comments(first: 10) {
                totalCount
              }
            }
          }
          mergeStateStatus
        }
      }
    }
  }
}' | jq -r '
.data.search.edges[] | 
(
  # Calculate CI stats first
  . as $pr |
  ($pr.node.commits.nodes[0].commit.statusCheckRollup.contexts.nodes // []) as $contexts |
  ([$contexts[] | (if has("conclusion") then select(.conclusion == "SUCCESS") else select(.state == "SUCCESS") end)] | length) as $success |
  ([$contexts[] | (if has("conclusion") then select(.conclusion == "FAILURE") else select(.state == "FAILURE") end)] | length) as $failure |
  ([$contexts[] | (if has("status") then select(.status == "IN_PROGRESS" or .status == "QUEUED" or .status == "PENDING") else select(.state == "PENDING") end)] | length) as $pending |
  (($pr.node.commits.nodes[0].commit.statusCheckRollup.contexts.totalCount) // 0) as $total |
  
  # Calculate comment stats
  ($pr.node.reviewThreads.nodes // []) as $threads |
  ([$threads[] | select(.isResolved == false)] | length) as $unresolvedThreads |
  ($pr.node.reviewThreads.totalCount // 0) as $totalThreads |
  
  # Output formatted PR info
  "\n\n ==================================== \n \u001b[1m#\($pr.node.number): \($pr.node.title)\u001b[0m
  
  📁 \u001b[1mRepo:\u001b[0m \($pr.node.repository.nameWithOwner)
  
  🌿 \u001b[1mBranch:\u001b[0m \($pr.node.headRefName) → \($pr.node.baseRefName)
  
  🔗 \u001b[1mURL:\u001b[0m \($pr.node.url)
  
  👍 \u001b[1mApprovals:\u001b[0m \([($pr.node.reviews.nodes // [])[] | select(.state == "APPROVED")] | length)/\($pr.node.reviews.totalCount // 0)
  
  💬 \u001b[1mComments:\u001b[0m \u001b[" + (if $unresolvedThreads > 0 then "31" else "32" end) + "m\($unresolvedThreads) unresolved\u001b[0m / \($totalThreads) total
  
  🔄 \u001b[1mCI Status:\u001b[0m " + (
    if ($pr.node.commits.nodes[0].commit.statusCheckRollup // null) == null then
      "No CI checks"
    else
      "✅ \($success) / ❌ \($failure) / ⏳ \($pending) (Total: \($total))"
    end
  ) + "
  📊 \u001b[1mMerge Status:\u001b[0m " + (
    if $pr.node.mergeStateStatus == "CLEAN" then
      "\u001b[32m✓ Ready to merge\u001b[0m"
    elif $pr.node.mergeStateStatus == "BEHIND" then
      "\u001b[33m⟲ Needs update from base branch\u001b[0m"
    elif $pr.node.mergeStateStatus == "BLOCKED" then
      "\u001b[31m🚫 Blocked from merging\u001b[0m"
    elif $pr.node.mergeStateStatus == "DIRTY" then
      "\u001b[31m⚠️ Has conflicts\u001b[0m"
    elif $pr.node.mergeStateStatus == "DRAFT" then
      "\u001b[36m📝 Draft PR, not ready\u001b[0m"
    elif $pr.node.mergeStateStatus == "HAS_HOOKS" then
      "\u001b[33m⏱️ Waiting for hooks\u001b[0m"
    elif $pr.node.mergeStateStatus == "UNKNOWN" then
      "\u001b[90m❓ Status unknown\u001b[0m"
    elif $pr.node.mergeStateStatus == "UNSTABLE" then
      "\u001b[31m❗ Checks failing\u001b[0m"
    else
      $pr.node.mergeStateStatus
    end
  ) + "
  ⚡ \u001b[1mCommands:\u001b[0m
    \u001b[36m gh pr update-branch \($pr.node.number) --repo \($pr.node.repository.nameWithOwner)\u001b[0m
    \u001b[36m gh pr update-branch \($pr.node.number) --repo \($pr.node.repository.nameWithOwner) --rebase\u001b[0m
    \u001b[36m gh pr merge \($pr.node.number) --repo \($pr.node.repository.nameWithOwner) --squash --delete-branch --auto\u001b[0m
    \u001b[36m gh pr close \($pr.node.number) --repo \($pr.node.repository.nameWithOwner)\u001b[0m
    \u001b[36m gh pr comment \($pr.node.number) --repo \($pr.node.repository.nameWithOwner) --body \"Your comment here\"\u001b[0m
  \n--------------------------------------------------\n\n\n"
)'
}

function reviewNeeded() {
	gh api graphql -f query='
query {
  search(query: "is:pr is:open review-requested:@me sort:updated-asc", type: ISSUE, first: 100) {
    edges {
      node {
        ... on PullRequest {
          number
          title
          url
          headRefName
          baseRefName
          author {
            login
          }
          repository {
            nameWithOwner
          }
          reviews(first: 100) {
            totalCount
            nodes {
              state
            }
          }
          reviewThreads(first: 100) {
            totalCount
            nodes {
              isResolved
              comments(first: 10) {
                totalCount
              }
            }
          }
          commits(last: 1) {
            nodes {
              commit {
                statusCheckRollup {
                  state
                  contexts(first: 100) {
                    totalCount
                    nodes {
                      ... on StatusContext {
                        state
                        context
                      }
                      ... on CheckRun {
                        status
                        conclusion
                        name
                      }
                    }
                  }
                }
              }
            }
          }
          mergeStateStatus
        }
      }
    }
  }
}' | jq -r '
.data.search.edges[] | 
(
  # Calculate CI stats first
  . as $pr |
  ($pr.node.commits.nodes[0].commit.statusCheckRollup.contexts.nodes // []) as $contexts |
  ([$contexts[] | (if has("conclusion") then select(.conclusion == "SUCCESS") else select(.state == "SUCCESS") end)] | length) as $success |
  ([$contexts[] | (if has("conclusion") then select(.conclusion == "FAILURE") else select(.state == "FAILURE") end)] | length) as $failure |
  ([$contexts[] | (if has("status") then select(.status == "IN_PROGRESS" or .status == "QUEUED" or .status == "PENDING") else select(.state == "PENDING") end)] | length) as $pending |
  (($pr.node.commits.nodes[0].commit.statusCheckRollup.contexts.totalCount) // 0) as $total |
  
  # Calculate comment stats
  ($pr.node.reviewThreads.nodes // []) as $threads |
  ([$threads[] | select(.isResolved == false)] | length) as $unresolvedThreads |
  ($pr.node.reviewThreads.totalCount // 0) as $totalThreads |
  
  # Output formatted PR info
  "\n\n \u001b[1m#\($pr.node.number): \($pr.node.title)\u001b[0m
  
  👤 \u001b[1mAuthor:\u001b[0m \($pr.node.author.login)
  
  📁 \u001b[1mRepo:\u001b[0m \($pr.node.repository.nameWithOwner)
  
  🌿 \u001b[1mBranch:\u001b[0m \($pr.node.headRefName) → \($pr.node.baseRefName)
  
  🔗 \u001b[1mURL:\u001b[0m \($pr.node.url)
  
  👍 \u001b[1mApprovals:\u001b[0m \([($pr.node.reviews.nodes // [])[] | select(.state == "APPROVED")] | length)/\($pr.node.reviews.totalCount // 0)
  
  💬 \u001b[1mComments:\u001b[0m \u001b[" + (if $unresolvedThreads > 0 then "31" else "32" end) + "m\($unresolvedThreads) unresolved\u001b[0m / \($totalThreads) total
  
  🔄 \u001b[1mCI Status:\u001b[0m " + (
    if ($pr.node.commits.nodes[0].commit.statusCheckRollup // null) == null then
      "No CI checks"
    else
      "✅ \($success) / ❌ \($failure) / ⏳ \($pending) (Total: \($total))"
    end
  ) + "
  📊 \u001b[1mMerge Status:\u001b[0m " + (
    if $pr.node.mergeStateStatus == "CLEAN" then
      "\u001b[32m✓ Ready to merge\u001b[0m"
    elif $pr.node.mergeStateStatus == "BEHIND" then
      "\u001b[33m⟲ Needs update from base branch\u001b[0m"
    elif $pr.node.mergeStateStatus == "BLOCKED" then
      "\u001b[31m🚫 Blocked from merging\u001b[0m"
    elif $pr.node.mergeStateStatus == "DIRTY" then
      "\u001b[31m⚠️ Has conflicts\u001b[0m"
    elif $pr.node.mergeStateStatus == "DRAFT" then
      "\u001b[36m📝 Draft PR, not ready\u001b[0m"
    elif $pr.node.mergeStateStatus == "HAS_HOOKS" then
      "\u001b[33m⏱️ Waiting for hooks\u001b[0m"
    elif $pr.node.mergeStateStatus == "UNKNOWN" then
      "\u001b[90m❓ Status unknown\u001b[0m"
    elif $pr.node.mergeStateStatus == "UNSTABLE" then
      "\u001b[31m❗ Checks failing\u001b[0m"
    else
      $pr.node.mergeStateStatus
    end
  ) + "
  ⚡ \u001b[1mRemote Commands:\u001b[0m
    \u001b[36m gh pr review \($pr.node.number) --approve --repo \($pr.node.repository.nameWithOwner)\u001b[0m
    \u001b[36m gh pr review \($pr.node.number) --comment --repo \($pr.node.repository.nameWithOwner)\u001b[0m
    \u001b[36m gh pr review \($pr.node.number) --request-changes --repo \($pr.node.repository.nameWithOwner)\u001b[0m
    \u001b[36m gh pr merge \($pr.node.number) --repo \($pr.node.repository.nameWithOwner) --squash --delete-branch --auto\u001b[0m
  \n--------------------------------------------------\n\n\n"
)'
}

# --------------------------
# PR Notification Helpers
# --------------------------

function _gh_pr_is_new_hash() {
	local hash="$1"
	local cache_file="$2"
	local timestamp="$3"
	
	if grep -q "^$hash|" "$cache_file"; then
		local stored_ts
		stored_ts=$(grep "^$hash|" "$cache_file" | tail -1 | cut -d'|' -f2)
		local age=$((timestamp - stored_ts))
		[[ $age -gt 86400 ]] && return 0 || return 1
	else
		return 0
	fi
}

function _gh_pr_store_hash() {
	local hash="$1"
	local cache_file="$2"
	local timestamp="$3"
	echo "$hash|$timestamp" >>"$cache_file"
}

function _gh_pr_notify() {
	local title="$1"
	local url="$2"
	local group="$3"
	local has_notifier="$4"
	
	if [[ "$has_notifier" == true ]]; then
		terminal-notifier -title "$title" -message "$url" -open "$url" -group "$group" -sound "default"
	else
		osascript -e "display notification \"$url\" with title \"$title\""
	fi
}

function notify_my_prs_status() {
	command -v gh >/dev/null || return
	command -v jq >/dev/null || return

	local has_notifier=false
	if command -v terminal-notifier >/dev/null; then
		has_notifier=true
	fi

	# Get current GitHub user with error handling
	local current_user
	if ! current_user=$(gh api user --jq .login 2>/dev/null); then
		echo "⚠️  Failed to get GitHub user. Check 'gh auth status'" >&2
		return 1
	fi
	
	local cache_file="$HOME/.gh_pr_notify_cache"
	touch "$cache_file"

	local current_time=$(date +%s)
	local expiry_seconds=$((24 * 60 * 60))

	# Clean up cache older than 24 hours
	if command -v gawk >/dev/null; then
		local temp_file=$(mktemp)
		gawk -F'|' -v now="$current_time" -v expiry="$expiry_seconds" '
      /^[0-9a-f]{40}\|[0-9]+$/ {
        if (now - $2 < expiry) print $0
      }
      !/^[0-9a-f]{40}\|[0-9]+$/ {
        print $0
      }
    ' "$cache_file" >"$temp_file" && mv "$temp_file" "$cache_file"
	else
		if [[ $(wc -l <"$cache_file") -gt 1000 ]]; then
			tail -n 500 "$cache_file" >"${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
		fi
	fi

	# Fetch PR data with error handling
	local data
	if ! data=$(gh api graphql -f query="
  query {
    myPRs: search(query: \"is:pr is:open author:@me\", type: ISSUE, first: 10) {
      nodes: edges {
        node {
          ... on PullRequest {
            number
            title
            url
            mergeStateStatus
            mergeable
            updatedAt
            commits(last: 1) {
              nodes {
                commit {
                  statusCheckRollup {
                    state
                  }
                  checkSuites(first: 10) {
                    nodes {
                      checkRuns(first: 20) {
                        nodes {
                          name
                          conclusion
                          status
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    prsNeedingMyReview: search(query: \"is:pr is:open review-requested:$current_user\", type: ISSUE, first: 10) {
      nodes: edges {
        node {
          ... on PullRequest {
            title
            url
            number
            author { login }
            baseRefName
            headRefName
            updatedAt
            reviewDecision
          }
        }
      }
    }
  }" 2>/dev/null); then
		echo "⚠️  Failed to fetch PR data from GitHub" >&2
		return 1
	fi

	# Optional debug log
	if [[ "${DEBUG_GH_PR:-}" == "1" ]]; then
		echo "$data" | jq '.' >/tmp/github_pr_query_result.json
		echo "🔍 Saved query response to /tmp/github_pr_query_result.json"
	fi

	local timestamp=$current_time
	local count=0

	## PRs authored by me
	while read -r pr; do
		local url=$(echo "$pr" | jq -r '.url')
		local number=$(echo "$pr" | jq -r '.number')
		local state=$(echo "$pr" | jq -r '.mergeStateStatus')
		local mergeable=$(echo "$pr" | jq -r '.mergeable')
		local updated_at=$(echo "$pr" | jq -r '.updatedAt')
		local ci_status=$(echo "$pr" | jq -r '.commits.nodes[0].commit.statusCheckRollup.state // "NO_CI"')

		local any_check_failed=$(echo "$pr" | jq -r '
      .commits.nodes[0].commit.checkSuites.nodes? // [] 
      | map(.checkRuns.nodes? // []) 
      | flatten 
      | map(select(.conclusion == "FAILURE")) 
      | .[0].name // ""')

		local summary=""
		local notify_flag=false

		if [[ "$state" == "CLEAN" ]]; then
			summary="#$number ✅ Ready to merge"
			notify_flag=true
		elif [[ "$mergeable" == "CONFLICTING" ]]; then
			summary="#$number ⚠️ Has conflicts"
			notify_flag=true
		elif [[ -n "$any_check_failed" ]]; then
			summary="#$number 🚨 Check Failed: $any_check_failed"
			notify_flag=true
		elif [[ "$ci_status" == "FAILURE" ]]; then
			summary="#$number 🚨 CI/CD failed (rollup)"
			notify_flag=true
		fi

		local hash=$(echo "$number|$state|$mergeable|$ci_status|$any_check_failed|$updated_at" | shasum | awk '{print $1}')

		if [[ "$notify_flag" == true ]] && _gh_pr_is_new_hash "$hash" "$cache_file" "$timestamp"; then
			_gh_pr_notify "$summary" "$url" "github-prs" "$has_notifier"
			_gh_pr_store_hash "$hash" "$cache_file" "$timestamp"
			count=$((count + 1))
		fi
	done < <(echo "$data" | jq -c '.data.myPRs.nodes[].node')

	## PRs requesting my review
	while read -r pr; do
		local url=$(echo "$pr" | jq -r '.url')
		local number=$(echo "$pr" | jq -r '.number')
		local author=$(echo "$pr" | jq -r '.author.login')
		local updated_at=$(echo "$pr" | jq -r '.updatedAt')
		local review_decision=$(echo "$pr" | jq -r '.reviewDecision // "UNKNOWN"')

		local summary="#$number 🆕 Review Requested"
		local hash=$(echo "REVIEW|$number|$author|$updated_at|$review_decision" | shasum | awk '{print $1}')

		if _gh_pr_is_new_hash "$hash" "$cache_file" "$timestamp"; then
			_gh_pr_notify "$summary" "$url" "github-reviews" "$has_notifier"
			_gh_pr_store_hash "$hash" "$cache_file" "$timestamp"
			count=$((count + 1))
		fi
	done < <(echo "$data" | jq -c '.data.prsNeedingMyReview.nodes[].node')

	if [[ $count -gt 0 ]]; then
		echo "🔣 $count GitHub PR notification(s) sent."
	fi
}

function start_pr_notifications() {
	if [[ -n "${PR_NOTIFY_LOOP_PID:-}" ]] && kill -0 "$PR_NOTIFY_LOOP_PID" 2>/dev/null; then
		echo "🔁 PR notifications loop already running (PID: $PR_NOTIFY_LOOP_PID)"
		return
	fi

	echo "🚀 Starting GitHub PR notifications loop (every 120 seconds)..."
	(
		while true; do
			notify_my_prs_status
			sleep 120
		done
	) &

	export PR_NOTIFY_LOOP_PID=$!
}

function stop_pr_notifications() {
	if [[ -z "${PR_NOTIFY_LOOP_PID:-}" ]]; then
		echo "⚠️  No PR notification loop is running"
		return 1
	fi
	
	if kill -0 "$PR_NOTIFY_LOOP_PID" 2>/dev/null; then
		kill "$PR_NOTIFY_LOOP_PID"
		echo "✅ Stopped PR notifications (PID: $PR_NOTIFY_LOOP_PID)"
		unset PR_NOTIFY_LOOP_PID
	else
		echo "⚠️  Process $PR_NOTIFY_LOOP_PID is not running"
		unset PR_NOTIFY_LOOP_PID
	fi
}

function clear_pr_notification_cache() {
	local cache_file="$HOME/.gh_pr_notify_cache"
	if [[ -f "$cache_file" ]]; then
		cp "$cache_file" "${cache_file}.bak"
		>"$cache_file"
		echo "✅ Cache cleared. You will receive notifications for all current PR states."
	else
		echo "⚠ No cache file found at $cache_file."
	fi
}

function goto_pr() {
	# Advanced script to open GitHub Pull Request for current branch
	# This version tries to find the specific PR for the current branch

	# Get current branch name
	CURRENT_BRANCH=$(git branch --show-current)

	if [ -z "$CURRENT_BRANCH" ]; then
		echo "Error: Not on any branch or not in a git repository"
		return 1
	fi

	# Get remote URL
	REMOTE_URL=$(git remote get-url origin)

	if [ -z "$REMOTE_URL" ]; then
		echo "Error: No origin remote found"
		return 1
	fi

	# Extract GitHub repository info from remote URL
	if [[ $REMOTE_URL == git@github.com:* ]]; then
		# SSH format: git@github.com:owner/repo.git
		REPO_INFO=$(echo "$REMOTE_URL" | sed 's/git@github.com://' | sed 's/\.git$//')
	elif [[ $REMOTE_URL == https://github.com/* ]]; then
		# HTTPS format: https://github.com/owner/repo.git
		REPO_INFO=$(echo "$REMOTE_URL" | sed 's|https://github.com/||' | sed 's/\.git$//')
	else
		echo "Error: Unsupported remote URL format: $REMOTE_URL"
		return 1
	fi

	echo "Current branch: $CURRENT_BRANCH"
	echo "Repository: $REPO_INFO"

	# Try to find specific PR using GitHub CLI if available
	if command -v gh >/dev/null 2>&1; then
		echo "Searching for PR with branch: $CURRENT_BRANCH"

		# Search for PR with current branch as head
		PR_URL=$(gh pr list --head "$CURRENT_BRANCH" --json url --jq '.[0].url' 2>/dev/null || echo "")

		if [ -n "$PR_URL" ] && [ "$PR_URL" != "null" ]; then
			echo "Found PR: $PR_URL"
			GITHUB_URL="$PR_URL"
		else
			echo "No existing PR found for branch '$CURRENT_BRANCH'"
			echo "Opening general PR page to create new PR..."
			GITHUB_URL="https://github.com/$REPO_INFO/compare/$CURRENT_BRANCH?expand=1"
		fi
	else
		echo "GitHub CLI (gh) not found. Opening general PR page..."
		GITHUB_URL="https://github.com/$REPO_INFO/pulls"
	fi

	echo "Opening: $GITHUB_URL"

	# Open URL in default browser
	if command -v open >/dev/null 2>&1; then
		# macOS
		open "$GITHUB_URL"
	elif command -v xdg-open >/dev/null 2>&1; then
		# Linux
		xdg-open "$GITHUB_URL"
	elif command -v start >/dev/null 2>&1; then
		# Windows (Git Bash/WSL)
		start "$GITHUB_URL"
	else
		echo "Could not detect how to open browser. Please open this URL manually:"
		echo "$GITHUB_URL"
	fi
}

function workflowRun() {
	if [ ! -d ".github/workflows" ]; then
		echo "Error: .github/workflows directory not found"
		return 1
	fi

	local temp_map_file=$(mktemp)

	setopt local_options nullglob
	for file in .github/workflows/*.{yml,yaml}; do
		[ -f "$file" ] || continue
		local filename=$(basename "$file")
		local display_name=$(grep -m 1 '^name:' "$file" | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")

		if [ -z "$display_name" ]; then
			display_name="${filename%.yml}"
			display_name="${display_name%.yaml}"
		fi

		echo "${display_name}|||${filename}" >>"$temp_map_file"
	done

	local selected_name
	selected_name=$(cat "$temp_map_file" | cut -d'|' -f1 | fzf --prompt="Select workflow: " --height=60% --preview "grep -F '{}' '$temp_map_file' | cut -d'|' -f4 | xargs -I {} bat --color=always --style=numbers .github/workflows/{}")

	if [ -z "$selected_name" ]; then
		echo "No workflow selected"
		rm -f "$temp_map_file"
		return 0
	fi

	local workflow=$(grep -F "${selected_name}|||" "$temp_map_file" | cut -d'|' -f4)
	rm -f "$temp_map_file"

	if [ -z "$workflow" ]; then
		echo "Error: Could not find workflow file"
		return 1
	fi

	local workflow_file=".github/workflows/$workflow"
	local workflow_name="${workflow%.yml}"
	workflow_name="${workflow_name%.yaml}"

	local has_workflow_dispatch
	has_workflow_dispatch=$(grep -A 1 "^on:" "$workflow_file" | grep -q "workflow_dispatch" && echo "yes" || echo "no")

	if [ "$has_workflow_dispatch" = "no" ]; then
		echo "Error: Workflow $workflow_name does not support workflow_dispatch"
		return 1
	fi

	local inputs
	inputs=$(grep -A 100 "inputs:" "$workflow_file" | grep "^      [a-z_-]*:$" | sed 's/^      //' | sed 's/://')

	if [ -z "$inputs" ]; then
		echo "No inputs found for workflow $workflow_name. Running without inputs..."
		local recent_branches
		recent_branches=$(git reflog --date=local --all 2>/dev/null | grep checkout | grep -o "checkout: moving from .* to .*" | sed 's/checkout: moving from //g' | awk '{print $NF}' | awk '!seen[$0]++' | head -n 15)

		local all_branches
		all_branches=$(git branch -a | sed 's/^[ *]*//' | sed 's/remotes\/origin\///')

		local sorted_branches
		sorted_branches=$(echo "$recent_branches\n$all_branches" | awk '!seen[$0]++')

		local selected_branch
		selected_branch=$(echo "$sorted_branches" | fzf --prompt="Select branch for --ref: " --height=40%)

		if [ -z "$selected_branch" ]; then
			echo "Error: No branch selected"
			return 1
		fi

		gh workflow run "$workflow" --ref "$selected_branch"
		return 0
	fi

	local input_args=()

	for input_key in $(echo "$inputs"); do
		local input_section
		input_section=$(sed -n "/^      ${input_key}:/,/^      [a-z]/p" "$workflow_file" | sed '$d')

		local input_type=$(echo "$input_section" | grep "type:" | sed 's/.*type:[[:space:]]*//' | tr -d '"' | tr -d "'")
		local input_desc=$(echo "$input_section" | grep "description:" | sed 's/.*description:[[:space:]]*//' | tr -d '"' | tr -d "'")
		local input_required=$(echo "$input_section" | grep "required:" | sed 's/.*required:[[:space:]]*//' | tr -d '"' | tr -d "'")

		if [ "$input_type" = "choice" ]; then
			local options_list
			options_list=$(echo "$input_section" | sed -n '/options:/,/^      [a-z]/p' | grep '^          -' | sed 's/^          - //' | tr -d '"' | tr -d "'")

			if [ -n "$options_list" ]; then
				local selected_option
				selected_option=$(echo "$options_list" | fzf --prompt="Select $input_key ($input_desc): " --height=40%)

				if [ -z "$selected_option" ] && [ "$input_required" = "true" ]; then
					echo "Error: $input_key is required"
					return 1
				fi

				if [ -n "$selected_option" ]; then
					input_args+=("-f" "$input_key=$selected_option")
				fi
			fi
		else
			local selected_value
			echo -n "Enter value for $input_key ($input_desc): "
			read selected_value

			if [ -z "$selected_value" ] && [ "$input_required" = "true" ]; then
				echo "Error: $input_key is required"
				return 1
			fi

			if [ -n "$selected_value" ]; then
				input_args+=("-f" "$input_key=$selected_value")
			fi
		fi
	done

	echo "\nChecking for running workflows..."
	local running_workflows
	running_workflows=$(gh run list --workflow="$selected_name" --status in_progress --json databaseId,status,createdAt,headBranch --limit 5 2>/dev/null)

	local running_count=$(echo "$running_workflows" | jq '. | length' 2>/dev/null || echo "0")

	if [ "$running_count" -gt 0 ]; then
		echo "⚠️  Found $running_count running workflow(s) with name: $selected_name"

		echo "$running_workflows" | jq -r '.[] | .databaseId' | while read -r run_id; do
			local actor=$(gh api "repos/:owner/:repo/actions/runs/$run_id" 2>/dev/null | jq -r '.triggering_actor.login // "Unknown"')
			local branch=$(echo "$running_workflows" | jq -r ".[] | select(.databaseId == $run_id) | .headBranch")
			local created=$(echo "$running_workflows" | jq -r ".[] | select(.databaseId == $run_id) | .createdAt")
			echo "  - Run ID: $run_id, User: $actor, Branch: $branch, Started: $created"
		done

		echo -n "\nDo you want to continue and trigger a new run? (y/N): "
		read continue_choice

		if [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]]; then
			echo "Cancelled. No new workflow triggered."
			return 0
		fi
		echo "Continuing..."
	fi

	local recent_branches
	recent_branches=$(git reflog --date=local --all 2>/dev/null | grep checkout | grep -o "checkout: moving from .* to .*" | sed 's/checkout: moving from //g' | awk '{print $NF}' | awk '!seen[$0]++' | head -n 15)

	local all_branches
	all_branches=$(git branch -a | sed 's/^[ *]*//' | sed 's/remotes\/origin\///')

	local sorted_branches
	sorted_branches=$(echo "$recent_branches\n$all_branches" | awk '!seen[$0]++')

	local selected_branch
	selected_branch=$(echo "$sorted_branches" | fzf --prompt="Select branch for --ref: " --height=40%)

	if [ -z "$selected_branch" ]; then
		echo "Error: No branch selected"
		return 1
	fi

	echo "\nRunning workflow: $workflow"
	echo "Branch: $selected_branch"
	echo "Inputs: ${input_args[@]}"

	gh workflow run "$workflow" --ref "$selected_branch" "${input_args[@]}"

	if [ $? -eq 0 ]; then
		echo "\n✅ Workflow triggered successfully!"
		echo "View at: $(gh repo view --json url -q .url)/actions"
	fi
}

function workflowCheck() {
	if [ ! -d ".github/workflows" ]; then
		echo "Error: .github/workflows directory not found"
		return 1
	fi

	local selected_name
	if [ -n "$1" ]; then
		selected_name="$1"
	else
		selected_name=$(gh run list --json workflowName --jq '.[].workflowName' | sort -u | \
			fzf --prompt="Select workflow to check: " --height=60%)

		if [ -z "$selected_name" ]; then
			echo "No workflow selected"
			return 0
		fi
	fi

	echo "\nFetching last 10 runs for: $selected_name\n"

	local workflow_id
	workflow_id=$(gh api "repos/{owner}/{repo}/actions/workflows?per_page=100" \
		--jq ".workflows[] | select(.name == \"$selected_name\") | .id")

	if [ -z "$workflow_id" ]; then
		echo "Error: Could not find workflow ID for '$selected_name'"
		return 1
	fi

	local runs
	runs=$(gh api "repos/{owner}/{repo}/actions/workflows/$workflow_id/runs?per_page=10" \
		--jq '.workflow_runs[] | [.head_branch, .created_at, .triggering_actor.login, .status, (.conclusion // "-")] | @tsv')

	if [ -z "$runs" ]; then
		echo "No runs found for workflow: $selected_name"
		return 0
	fi

	printf "%-35s %-30s %-18s %-22s %s\n" "WORKFLOW NAME" "BRANCH" "TIME" "AUTHOR" "STATUS"
	printf "%-35s %-30s %-18s %-22s %s\n" "$(printf '%0.s-' {1..35})" "$(printf '%0.s-' {1..30})" "$(printf '%0.s-' {1..18})" "$(printf '%0.s-' {1..22})" "--------"

	local wf_name="${selected_name:0:33}"

	while IFS=$'\t' read -r branch created author run_status conclusion; do
		local formatted_time
		formatted_time=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created" "+%m-%d %H:%M" 2>/dev/null || echo "$created")

		local display_status
		if [ "$run_status" = "completed" ]; then
			display_status="$conclusion"
		else
			display_status="$run_status"
		fi

		printf "%-35s %-30s %-18s %-22s %s\n" "$wf_name" "${branch:0:28}" "$formatted_time" "${author:0:20}" "$display_status"
	done <<< "$runs"
}

# --------------------------
# Navigation & Search Utilities
# --------------------------

function zgco() {
	local recent_branches
	recent_branches=$(git reflog --date=local --all 2>/dev/null | grep checkout | grep -o "checkout: moving from .* to .*" | sed 's/checkout: moving from //g' | awk '{print $NF}' | awk '!seen[$0]++' | head -n 15)

	local all_branches
	all_branches=$(git branch -a | sed 's/^[ *]*//' | sed 's/remotes\/origin\///')

	local sorted_branches
	sorted_branches=$(echo "$recent_branches\n$all_branches" | awk '!seen[$0]++')

	local selected_branch
	selected_branch=$(echo "$sorted_branches" | fzf --prompt="Select branch: " --height=40%)

	if [ -n "$selected_branch" ]; then
		git checkout "$selected_branch"
	fi
}

function zfunc() {
	local funcs aliases selected

	funcs=$(grep -E '^(function [a-zA-Z_][a-zA-Z0-9_]*(\(\))? \{|function [a-zA-Z_][a-zA-Z0-9_]*\(\)|[a-zA-Z_][a-zA-Z0-9_]*\(\))' ~/.zshrc | \
		sed -E 's/^function ([a-zA-Z_][a-zA-Z0-9_]*).*$/\1/; s/^([a-zA-Z_][a-zA-Z0-9_]*)\(\).*$/\1/')

	aliases=$(grep -E '^alias [a-zA-Z_][a-zA-Z0-9_]*=' ~/.zshrc | \
		sed -E 's/^alias ([a-zA-Z_][a-zA-Z0-9_]*)=.*/\1/')

	selected=$(printf '%s\n%s' "$funcs" "$aliases" | sort -u | \
		fzf --preview 'item={}; result=$(awk -v fname="$item" '\''$0 ~ "^function " fname || $0 ~ "^" fname "\\(\\)" {p=1} p {print} /^}$/ && p {exit}'\'' ~/.zshrc); [ -z "$result" ] && result=$(grep -E "^alias $item=" ~/.zshrc); printf "%s" "$result" | bat --color=always --language=bash --style=numbers' \
		    --preview-window=right:80%:wrap \
		    --height=80%)

	if [ -n "$selected" ]; then
		print -z "$selected "
	fi
}

# --------------------------
# DevOps / Work
# --------------------------

function odsAuthConnect() {
	~/alloydb-auth-proxy projects/one-global-ods-uat/locations/asia-southeast1/clusters/sea1-uat-ods-db-cluster/instances/ods-ecomapi --port 9999 --auto-iam-authn --public-ip
}

function dockerDaemonStart() { colima start; }

function killPort() {
	lsof -ti :$1 | xargs kill -9
}

# --------------------------
# Editors & IDEs
# --------------------------

function cursor() {
	open -n ~/Downloads/Apps/Cursor.app --args $PWD
}

function webstorm() {
	open -a "$HOME/Apps/WebStorm.app" "${1:-.}"
}

# Added by Antigravity
function agy() {
    antigravity "${@:-.}"
}

function rune2e() {
	PWDEBUG=1 npm run test --tags=@"$1" --testbrowser="$2"
}

# =============================================================================
# JIRA CLI FUNCTIONS
# =============================================================================

# Get all Jira projects
function jiraProjects() {
    echo "📋 Fetching all Jira projects..."
    acli jira project list --paginate
}

# Get recent Jira projects
function jiraProjectsRecent() {
    echo "🕐 Recently viewed projects:"
    acli jira project list --recent
}

# Export all projects to JSON
function jiraProjectsExport() {
    local output="${1:-jira-projects.json}"
    echo "📊 Exporting all projects to $output..."
    acli jira project list --paginate --json > "$output"
    echo "✓ Exported to $output"
}

# View specific project details
function jiraProjectView() {
    if [ -z "$1" ]; then
        echo "Usage: jiraProjectView PROJECT-KEY"
        return 1
    fi
    acli jira project view --key "$1"
}

# --------------------------
# eCom3 Sprint Functions
# --------------------------

# Get all tickets in eCom3 active sprint
function ecom3Sprint() {
    echo "🏃 Fetching eCom3 active sprint tickets..."
    acli jira workitem search --jql "sprint in openSprints() AND project = NE" --fields "key,summary,assignee,status,priority" --paginate
}

# Get eCom3 active sprint tickets and export to CSV
function ecom3SprintExport() {
    local output="${1:-ecom3-sprint-$(date +%Y%m%d).csv}"
    echo "📊 Exporting eCom3 active sprint to $output..."
    acli jira workitem search --jql "sprint in openSprints() AND project = NE" --csv --paginate > "$output"
    echo "✓ Exported to $output"
}

# Get YOUR tickets in eCom3 active sprint
function ecom3SprintMine() {
    echo "🏃 Your tickets in eCom3 active sprint:"
    acli jira workitem search --jql "sprint in openSprints() AND project = NE AND assignee = currentUser()" --fields "key,summary,status,priority"
}

# Get eCom3 sprint summary by status
function ecom3SprintSummary() {
    echo "📊 eCom3 Active Sprint Summary"
    echo "=============================="
    echo ""
    
    local jql="sprint in openSprints() AND project = NE"
    
    # Total count
    local total=$(acli jira workitem search --jql "$jql" --count 2>/dev/null | grep -o '[0-9]*' | head -1)
    echo "Total Tickets: $total"
    echo ""
    
    # By status
    echo "By Status:"
    for status in "TO DO" "IN PROGRESS" "IN REVIEW" "DONE"; do
        local status_jql="$jql AND status = '$status'"
        local count=$(acli jira workitem search --jql "$status_jql" --count 2>/dev/null | grep -o '[0-9]*' | head -1)
        printf "  %-15s %s\n" "$status:" "$count"
    done
}

# --------------------------
# Jira Hierarchy View
# --------------------------

# View sprint tickets organized by type with color coding
function jiraHierarchy() {
    local project="${1:-}"
    local jql="sprint in openSprints()"
    
    if [ -n "$project" ]; then
        jql="$jql AND project = $project"
    fi
    
    echo "🔍 Fetching tickets from active sprint${project:+ (Project: $project)}..."
    
    # Fetch tickets as JSON
    local tickets_json=$(acli jira workitem search --jql "$jql" --fields "key,summary,issuetype,status,assignee,priority" --paginate --json 2>/dev/null)
    
    if [ -z "$tickets_json" ] || [ "$tickets_json" = "[]" ]; then
        echo "No tickets found in active sprint."
        return 1
    fi
    
    # Count total tickets
    local total=$(echo "$tickets_json" | jq 'length' 2>/dev/null)
    echo "✓ Found $total tickets"
    echo ""
    
    # Print summary
    echo "================================================================================"
    echo "📊 SPRINT SUMMARY"
    echo "================================================================================"
    echo "Total Tickets: $total"
    echo ""
    
    # Count by type
    echo "By Type:"
    echo "$tickets_json" | jq -r '[.[] | .fields.issuetype.name] | group_by(.) | map({type: .[0], count: length}) | sort_by(-.count) | .[] | "  \(.type | tostring | .[0:20])  \(.count)"' 2>/dev/null
    
    echo ""
    echo "By Status:"
    echo "$tickets_json" | jq -r '[.[] | .fields.status.name] | group_by(.) | map({status: .[0], count: length}) | sort_by(-.count) | .[] | "  \(.status | tostring | .[0:25])  \(.count)"' 2>/dev/null
    
    echo "================================================================================"
    echo ""
    
    # Print organized by type
    echo "📋 TICKETS BY TYPE"
    echo "================================================================================"
    
    # Color codes
    local BOLD="\033[1m"
    local BLUE="\033[94m"
    local GREEN="\033[92m"
    local YELLOW="\033[93m"
    local GRAY="\033[90m"
    local RESET="\033[0m"
    
    # Function to print tickets of a specific type
    print_type_group() {
        local type="$1"
        local icon="$2"
        
        local type_tickets=$(echo "$tickets_json" | jq -c "[.[] | select(.fields.issuetype.name == \"$type\")]" 2>/dev/null)
        local count=$(echo "$type_tickets" | jq 'length' 2>/dev/null)
        
        if [ "$count" -gt 0 ]; then
            echo ""
            echo "${type}S ($count):"
            echo "--------------------------------------------------------------------------------"
            
            echo "$type_tickets" | jq -r '.[] | 
                .key as $key |
                .fields.summary as $summary |
                .fields.status.name as $status |
                (.fields.assignee.displayName // "Unassigned") as $assignee |
                (.fields.priority.name // "Medium") as $priority |
                "\($key)|\($status)|\($summary)|\($assignee)|\($priority)"
            ' 2>/dev/null | while IFS='|' read -r key status summary assignee priority; do
                # Status color
                local status_color="$GRAY"
                if [[ "$status" =~ "DONE" ]] || [[ "$status" =~ "Done" ]]; then
                    status_color="$GREEN"
                elif [[ "$status" =~ "PROGRESS" ]] || [[ "$status" =~ "REVIEW" ]]; then
                    status_color="$YELLOW"
                fi
                
                # Priority indicator
                local priority_icon="🟡"
                case "$priority" in
                    "Highest") priority_icon="🔴" ;;
                    "High") priority_icon="🟠" ;;
                    "Medium") priority_icon="🟡" ;;
                    "Low") priority_icon="🟢" ;;
                    "Lowest") priority_icon="⚪" ;;
                esac
                
                # Truncate summary
                local summary_short="${summary:0:50}"
                if [ ${#summary} -gt 50 ]; then
                    summary_short="${summary_short}..."
                fi
                
                echo -e "${icon} ${BOLD}${BLUE}${key}${RESET} ${priority_icon} ${status_color}[${status}]${RESET} ${summary_short} ${GRAY}(${assignee})${RESET}"
            done
        fi
    }
    
    # Print each type
    print_type_group "Epic" "📦"
    print_type_group "Story" "📖"
    print_type_group "Task" "✓"
    print_type_group "Bug" "🐛"
    print_type_group "Sub-task" "↳"
    
    # Print other types
    local other_types=$(echo "$tickets_json" | jq -r '[.[] | .fields.issuetype.name] | unique | .[] | select(. != "Epic" and . != "Story" and . != "Task" and . != "Bug" and . != "Sub-task")' 2>/dev/null)
    
    if [ -n "$other_types" ]; then
        echo "$other_types" | while read -r type; do
            print_type_group "$type" "•"
        done
    fi
    
    echo ""
}

# View eCom3 sprint tickets organized by type
function ecom3Hierarchy() {
    jiraHierarchy NE
}

function killPid() {

# Check if a PID was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <PID>"
  echo "Example: $0 12345"
  exit 1
fi

PID=$1

# Try to kill the process
if kill -0 "$PID" >/dev/null 2>&1; then
    kill -9 "$PID"
    if [ $? -eq 0 ]; then
        echo "Successfully killed process $PID"
    else
        echo "Failed to kill process $PID"
    fi
else
    echo "Process $PID does not exist"
fi

}

# --------------------------
# Jira / ACLI Utilities
# --------------------------

function jbranch() {
	echo "🔍 Fetching your in-progress Jira tickets..."

	# Fetch tickets assigned to current user with status "In Progress"
	local tickets_json
	tickets_json=$(acli jira workitem search \
		--jql "assignee = currentUser() AND statusCategory = 'In Progress'" \
		--fields "issuetype,key,summary" \
		--json 2>&1)

	if [[ $? -ne 0 ]]; then
		echo "❌ Failed to fetch tickets. Make sure you're authenticated with acli."
		echo "$tickets_json"
		return 1
	fi

	# Check if any tickets were found
	local count
	count=$(echo "$tickets_json" | jq 'length')
	if [[ "$count" -eq 0 ]]; then
		echo "📭 No in-progress tickets found assigned to you."
		return 0
	fi

	# Build a list for fzf: "KEY | TYPE | SUMMARY"
	local ticket_list
	ticket_list=$(echo "$tickets_json" | jq -r '.[] | select(.fields.issuetype.name != "Story") | "\(.key) | \(.fields.issuetype.name) | \(.fields.summary)"')

	# Let user pick a ticket with fzf
	local selected
	selected=$(echo "$ticket_list" | fzf --prompt="Select ticket: " --height=40% --reverse)

	if [[ -z "$selected" ]]; then
		echo "❌ No ticket selected."
		return 0
	fi

	# Parse the selected ticket
	local ticket_key ticket_type ticket_summary
	ticket_key=$(echo "$selected" | awk -F' \\| ' '{print $1}')
	ticket_type=$(echo "$selected" | awk -F' \\| ' '{print $2}')
	ticket_summary=$(echo "$selected" | awk -F' \\| ' '{print $3}')

	# Extract ticket number from key (e.g., NE-36809 -> 36809)
	local ticket_number
	ticket_number=$(echo "$ticket_key" | sed 's/NE-//')

	# Slugify the summary: lowercase, strip brackets/special chars, replace spaces with hyphens
	local slug
	slug=$(echo "$ticket_summary" | \
		sed 's/\[//g; s/\]//g' | \
		tr '[:upper:]' '[:lower:]' | \
		sed 's/[^a-z0-9 -]//g' | \
		sed 's/  */ /g; s/^ //; s/ $//' | \
		sed 's/ /-/g')

	# Determine branch prefix based on issue type
	local branch_name
	case "${ticket_type:l}" in
		bug)
			branch_name="bugfix/NE-${ticket_number}-${slug}"
			;;
		*)
			branch_name="feature/NE-${ticket_number}-${slug}"
			;;
	esac

	echo ""
	echo "📋 Ticket:  $ticket_key - $ticket_summary"
	echo "🏷️  Type:    $ticket_type"
	echo "🌿 Branch:  $branch_name"
	echo ""

	# Confirm and create the branch
	read "confirm?Create branch '$branch_name'? [Enter to confirm / any text to cancel]: "

	if [[ -z "$confirm" ]]; then
		git checkout -b "$branch_name"
		if [[ $? -eq 0 ]]; then
			echo "✅ Branch '$branch_name' created and checked out!"
		else
			echo "❌ Failed to create branch. It may already exist."
		fi
	else
		echo "❌ Cancelled."
	fi
}

# Generate a conventional commit message from the current branch name
# Usage: gcmm [--no-verify]
function gcmm() {
	local no_verify=0
	for arg in "$@"; do
		[[ "$arg" == "--no-verify" ]] && no_verify=1
	done

	local branch
	branch=$(git branch --show-current 2>/dev/null)
	if [[ -z "$branch" ]]; then
		echo "❌ Not in a git repository or no branch checked out."
		return 1
	fi

	# Determine branch type
	local branch_type
	if [[ "$branch" == feature/* ]]; then
		branch_type="feature"
	elif [[ "$branch" == bugfix/* ]]; then
		branch_type="bugfix"
	elif [[ "$branch" == chore/* ]]; then
		branch_type="chore"
	else
		echo "❌ Branch '$branch' doesn't match feature/*, bugfix/*, or chore/* patterns."
		return 1
	fi

	# Strip the type prefix and build description (hyphens → spaces, lowercase)
	local branch_desc
	branch_desc=$(echo "$branch" | sed 's|^[^/]*/||' | sed 's|^[A-Za-z]*-[0-9]*-||' | tr '-' ' ' | tr '[:upper:]' '[:lower:]')

	local commit_msg
	if [[ "$branch_type" == "chore" ]]; then
		commit_msg="chore: $branch_desc"
	else
		# Extract ticket ID from branch (e.g., NE-62584)
		local ticket_id
		ticket_id=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)

		if [[ -z "$ticket_id" ]]; then
			echo "❌ Could not extract ticket ID from branch: $branch"
			return 1
		fi

		echo "🔍 Fetching parent ticket for $ticket_id..."
		local parent_id
		parent_id=$(acli jira workitem view "$ticket_id" --fields "parent" --json 2>/dev/null | \
			python3 -c "import json,sys; d=json.load(sys.stdin); print(d['fields']['parent']['key'])" 2>/dev/null)

		if [[ -z "$parent_id" ]]; then
			echo "⚠️  Could not fetch parent ticket ID. Using ticket ID itself."
			parent_id="$ticket_id"
		fi



		if [[ "$branch_type" == "feature" ]]; then
			commit_msg="feat($parent_id): $branch_desc"
		else
			commit_msg="fix($parent_id): $branch_desc"
		fi
	fi

	# Use fzf to allow editing before committing (ESC cancels)
	local fzf_out
	fzf_out=$(echo "$commit_msg" | fzf \
		--print-query \
		--query "$commit_msg" \
		--prompt "✏️  " \
		--header "Edit commit message and press Enter to commit (ESC to cancel)" \
		--no-info \
		--height 5 \
		2>/dev/null)
	local fzf_exit=$?

	if [[ $fzf_exit -eq 130 ]]; then
		echo "❌ Commit cancelled."
		return 0
	fi

	local final_msg
	final_msg=$(echo "$fzf_out" | head -1)

	if [[ -z "$final_msg" ]]; then
		echo "❌ Commit message is empty. Aborting."
		return 1
	fi

	echo ""
	echo "📝 Committing: $final_msg"
	if [[ $no_verify -eq 1 ]]; then
		git commit -m "$final_msg" --no-verify
	else
		git commit -m "$final_msg"
	fi
}

function createRepo() {
  local name visibility description account gh_user ssh_host init_local

  echo -n "Account [work/personal] (default: work): "
  read account
  account="${account:-work}"
  if [[ "$account" == "work" ]]; then
    gh_user="nam-nguyenv-otsv"
    ssh_host="github.com-work"
  elif [[ "$account" == "personal" ]]; then
    gh_user="NolanNamNguyen"
    ssh_host="github.com-personal"
  else
    echo "Must be 'work' or 'personal'."; return 1
  fi

  echo -n "Repo name: "
  read name
  [[ -z "$name" ]] && { echo "Repo name is required."; return 1; }

  echo -n "Visibility [public/private] (default: private): "
  read visibility
  visibility="${visibility:-private}"
  [[ "$visibility" != "public" && "$visibility" != "private" ]] && { echo "Must be 'public' or 'private'."; return 1; }

  echo -n "Description (optional): "
  read description

  gh auth switch --user "$gh_user" 2>/dev/null

  local args=("$gh_user/$name" "--$visibility")
  [[ -n "$description" ]] && args+=("--description" "$description")

  gh repo create "${args[@]}" || return 1

  echo -n "Init current directory and set remote origin? [y/N]: "
  read init_local
  if [[ "$init_local" =~ ^[Yy]$ ]]; then
    git init
    git remote add origin "git@${ssh_host}:${gh_user}/${name}.git"
    echo "Remote origin set to git@${ssh_host}:${gh_user}/${name}.git"
  fi
}

function delRepo() {
  local selected
  selected=$(gh repo list --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | fzf --prompt="Delete repo > ")

  if [[ -z "$selected" ]]; then
    echo "No repo selected."
    return 0
  fi

  read -r "confirm?Delete '$selected'? This cannot be undone. Type repo name to confirm: "

  if [[ "$confirm" == "$selected" || "$confirm" == "${selected##*/}" ]]; then
    gh repo delete "$selected" --yes
    echo "Deleted $selected"
  else
    echo "Confirmation mismatch. Aborted."
    return 1
  fi
}

# pnpm
export PNPM_HOME="/Users/nam.nguyenv/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# DOCKER HELPERS
# =============================================================================

shellInto() {
  local container shell

  if [[ -n "$1" ]]; then
    container="$1"
  else
    container=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | fzf --header="Select container" | awk '{print $1}')
  fi

  [[ -z "$container" ]] && return 0

  for shell in bash sh ash; do
    if docker exec "$container" which "$shell" &>/dev/null; then
      docker exec -it "$container" "$shell"
      return 0
    fi
  done

  echo "No shell found in container '$container'"
  return 1
}


dockerStorage() {
  echo "=== Docker disk usage ==="
  docker system df -v 2>/dev/null || { echo "Docker is not running."; return 1; }
}

mergeBack() {
  git fetch origin --prune || return 1

  local branches
  branches=$(git branch -r --format='%(refname:short)' | sed 's|^origin/||' | sort -u)

  local source
  source=$(echo "$branches" | fzf --header="Select FROM branch (source)")
  [[ -z "$source" ]] && echo "Cancelled." && return 0

  local target
  target=$(echo "$branches" | fzf --header="Select TO branch (target)")
  [[ -z "$target" ]] && echo "Cancelled." && return 0

  local use_fork
  use_fork=$(printf 'No\nYes\n' | fzf --header="Create forked branch?")
  [[ -z "$use_fork" ]] && echo "Cancelled." && return 0

  echo "From:   $source"
  echo "To:     $target"
  echo "Forked: $use_fork"

  local head_branch="$source"

  if [[ "$use_fork" == "Yes" ]]; then
    head_branch="merge-back/${source}-to-${target}"
    if git show-ref --verify --quiet "refs/heads/$head_branch" || git show-ref --verify --quiet "refs/remotes/origin/$head_branch"; then
      local i=2
      while git show-ref --verify --quiet "refs/heads/${head_branch}-${i}" || git show-ref --verify --quiet "refs/remotes/origin/${head_branch}-${i}"; do
        ((i++))
      done
      head_branch="${head_branch}-${i}"
    fi
    git checkout -b "$head_branch" "origin/$source" || return 1
    git push -u origin "$head_branch" || return 1
  fi

  gh pr create \
    --title "Merge back $source to $target" \
    --base "$target" \
    --head "$head_branch" \
    --body "Merge back \`$source\` to \`$target\`"
}

# =============================================================================
# GCLOUD HELPERS
# =============================================================================

gcProSwitch() {
  local project
  project=$(gcloud projects list --format="value(projectId)" 2>/dev/null | fzf --header="Select GCP project")
  [[ -z "$project" ]] && return 0
  gcloud config set project "$project" 2>/dev/null
  gcloud auth application-default set-quota-project "$project" 2>/dev/null
  echo "Switched to project: $project"
}

gcBrowse() {
  local project bucket path input

  project=$(gcloud config list --format="value(core.project)" 2>/dev/null)
  [[ -z "$project" || "$project" == "(unset)" ]] && echo "No active project. Run gcProSwitch first." && return 1

  bucket=$(gsutil ls 2>/dev/null | sed 's|gs://||;s|/||' | fzf --header="Select bucket (project: $project)")
  [[ -z "$bucket" ]] && return 0

  path=""
  while true; do
    echo "\n📂 gs://$bucket/$path"
    echo "---"

    local items=()
    while IFS= read -r line; do
      [[ -n "$line" ]] && items+=("$line")
    done < <(gsutil ls "gs://$bucket/$path" 2>/dev/null | sed "s|gs://$bucket/||")

    [[ ${#items[@]} -eq 0 ]] && echo "(empty)" && break

    input=$(printf '%s\n' "${items[@]}" | fzf \
      --header="Navigate: Enter=open | Ctrl-C=quit | ../ to go back" \
      --print-query \
      --expect=ctrl-d \
      --prompt="gs://$bucket/$path > ")

    local query key selected
    query=$(echo "$input" | sed -n '1p')
    key=$(echo "$input" | sed -n '2p')
    selected=$(echo "$input" | sed -n '3p')

    [[ -z "$selected" && -z "$query" ]] && break

    if [[ "$selected" == "../" || "$query" == ".." ]]; then
      path=$(echo "$path" | sed 's|[^/]*/$||')
      continue
    fi

    if [[ -n "$selected" ]]; then
      if [[ "$selected" == */ ]]; then
        path="$selected"
      else
        echo "\n📄 gs://$bucket/$selected"
        echo "[d]ownload | [c]at (view) | [b]ack | [q]uit"
        read -r "action?Action: "
        case "$action" in
          d) gsutil cp "gs://$bucket/$selected" "./${selected##*/}" && echo "Downloaded to ./${selected##*/}" ;;
          c) gsutil cat "gs://$bucket/$selected" ;;
          b) ;;
          q) break ;;
        esac
      fi
    fi
  done
}
