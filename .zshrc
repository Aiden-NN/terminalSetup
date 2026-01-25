export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
# Added by Antigravity
export PATH="/Users/nam.nguyenv/.antigravity/antigravity/bin:$PATH"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

alias code="open -a \"/Users/nam.nguyenv/Apps/VisualStudioCode.app\" ."
alias shell='open ~/.zshrc'

ZSH_THEME=""

plugins=(git)

source $ZSH/oh-my-zsh.sh

if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
	eval "$(starship init zsh)"
fi

# Force Warp to use custom prompt
export WARP_USE_SSH_WRAPPER=1

export NVM_DIR="$HOME/.nvm"
source ~/.nvm/nvm.sh
alias pul="git pull"
alias dev="npm run dev"
alias grs1="git reset --soft HEAD~1"
alias grl="git reflog"
alias gbd="git branch -D"
alias lint="npm run lint"
alias grss="git reset --soft"
alias build="npm run build"
alias gsts="git stash push"
alias gsta="git stash apply"
alias gstsn="git stash save -m $1"
function gstan() { git stash apply stash@{"$1"}; }
alias test="npm run test:one-click-booking"
alias start="npm run start"
function grsho() { git reset --hard origin/"$1"; }
function grbf() {
	git checkout "$1"
	git reset --hard origin/"$1"
	git checkout -
	git rebase "$1"
}
function rune2e() {
	PWDEBUG=1 npm run test --tags=@"$1" --testbrowser="$2"
}
function gbdo() { git push origin --delete "$1"; }

function pr() {
	if [ "$#" -gt 3 ]; then
		echo "Usage: pr [target-branch] [reviewers] [label]"
		return 1
	fi

	current_branch=$(git branch --show-current)
	default_target_branch="develop"
	default_reviewers="son-tranhh-otsv,sy-nguyenv-otsv,hoang-trant-otsv,vinh-huynhx-otsv"
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

function deploy() {
	local ref="$1"
	local env="$2"
	gh workflow run deploy-test.yml --ref "$ref" --field env="$env"
}
export PATH="/Users/nam.nguyenv/Library/Python/3.11/bin:$PATH"

if [ -f '/Users/nam.nguyenv/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nam.nguyenv/google-cloud-sdk/path.zsh.inc'; fi

if [ -f '/Users/nam.nguyenv/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nam.nguyenv/google-cloud-sdk/completion.zsh.inc'; fi

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /Users/nam.nguyenv/Development/Projects/electron-quick-start/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/nam.nguyenv/Development/Projects/electron-quick-start/node_modules/tabtab/.completions/electron-forge.zsh
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/nam.nguyenv/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

function cursor() {
	open -n ~/Downloads/Apps/Cursor.app --args $PWD
}

function webstorm() {
	open -a "$HOME/Apps/WebStorm.app" "${1:-.}"
}

gpup() {
	local current_branch=$(git rev-parse --abbrev-ref HEAD)
	echo "Pushing and setting upstream for branch: $current_branch"
	git push --set-upstream origin $current_branch
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
	# We only need the URL for reviewing
	# ** CORRECTED FLAG IS USED BELOW **
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
			# Approve the PR using its URL
			# Added a generic comment body, modify if needed
			gh pr review "$pr_url" --approve
			if [[ $? -ne 0 ]]; then
				echo "Error approving PR: $pr_url. Continuing..."
				# Optional: Add more robust error handling here
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

function notify_my_prs_status() {
	command -v gh >/dev/null || return
	command -v jq >/dev/null || return

	local has_notifier=false
	if command -v terminal-notifier >/dev/null; then
		has_notifier=true
	fi

	local current_user
	current_user=$(gh api user --jq .login)
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

	local data
	data=$(gh api graphql -f query="
  query {
    myPRs: search(query: \"is:pr is:open author:@me\", type: ISSUE, first: 10) {
      nodes: edges {
        node {
          ... on PullRequest {
            number
            title
            url
            mergeStateStatus
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
  }")

	# Optional debug log
	if [[ "${DEBUG_GH_PR:-}" == "1" ]]; then
		echo "$data" | jq '.' >/tmp/github_pr_query_result.json
		echo "🔍 Saved query response to /tmp/github_pr_query_result.json"
	fi

	local timestamp=$current_time
	local count=0

	function is_new_hash() {
		local hash="$1"
		if grep -q "^$hash|" "$cache_file"; then
			local stored_ts
			stored_ts=$(grep "^$hash|" "$cache_file" | tail -1 | cut -d'|' -f2)
			local age=$((timestamp - stored_ts))
			[[ $age -gt 86400 ]] && return 0 || return 1
		else
			return 0
		fi
	}

	function store_hash() {
		echo "$1|$timestamp" >>"$cache_file"
	}

	function notify() {
		local title="$1"
		local url="$2"
		local group="$3"
		if [[ "$has_notifier" == true ]]; then
			terminal-notifier -title "$title" -message "$url" -open "$url" -group "$group" -sound "default"
		else
			osascript -e "display notification \"$url\" with title \"$title\""
		fi
	}

	## PRs authored by me
	echo "$data" | jq -c '.data.myPRs.nodes[].node' | while read -r pr; do
		local url=$(echo "$pr" | jq -r '.url')
		local number=$(echo "$pr" | jq -r '.number')
		local state=$(echo "$pr" | jq -r '.mergeStateStatus')
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
		elif [[ -n "$any_check_failed" ]]; then
			summary="#$number 🚨 Check Failed: $any_check_failed"
			notify_flag=true
		elif [[ "$ci_status" == "FAILURE" ]]; then
			summary="#$number 🚨 CI/CD failed (rollup)"
			notify_flag=true
		fi

		local hash=$(echo "$number|$state|$ci_status|$any_check_failed|$updated_at" | shasum | awk '{print $1}')

		if [[ "$notify_flag" == true ]] && is_new_hash "$hash"; then
			notify "$summary" "$url" "github-prs"
			store_hash "$hash"
			count=$((count + 1))
		fi
	done

	## PRs requesting my review
	echo "$data" | jq -c '.data.prsNeedingMyReview.nodes[].node' | while read -r pr; do
		local url=$(echo "$pr" | jq -r '.url')
		local number=$(echo "$pr" | jq -r '.number')
		local author=$(echo "$pr" | jq -r '.author.login')
		local updated_at=$(echo "$pr" | jq -r '.updatedAt')
		local review_decision=$(echo "$pr" | jq -r '.reviewDecision // "UNKNOWN"')

		local summary="#$number 🆕 Review Requested"
		local hash=$(echo "REVIEW|$number|$author|$updated_at|$review_decision" | shasum | awk '{print $1}')

		if is_new_hash "$hash"; then
			notify "$summary" "$url" "github-reviews"
			store_hash "$hash"
			count=$((count + 1))
		fi
	done

	if [[ $count -gt 0 ]]; then
		echo "🔣 $count GitHub PR notification(s) sent."
	fi
}

function start_pr_notifications() {
	if [[ -n "${PR_NOTIFY_LOOP_PID:-}" ]] && kill -0 "$PR_NOTIFY_LOOP_PID" 2>/dev/null; then
		echo "🔁 PR notifications loop already running (PID: $PR_NOTIFY_LOOP_PID)"
		return
	fi

	echo "🚀 Starting GitHub PR notifications loop (every 30 seconds)..."
	(
		while true; do
			notify_my_prs_status
			sleep 50
		done
	) &

	export PR_NOTIFY_LOOP_PID=$!
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
alias cursor="open -a ~/Apps/Cursor.app ."

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"

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

function zf() {
	local selected
	selected=$(find . -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null | fzf --preview 'if [ -d {} ]; then ls -la {}; else bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file or no preview available"; fi')

	if [ -n "$selected" ]; then
		if [ -d "$selected" ]; then
			cd "$selected"
		else
			open "$selected"
		fi
	fi
}

function zfunc() {
	local func_list
	func_list=$(grep -E '^(function [a-zA-Z_][a-zA-Z0-9_]*\(\)|function [a-zA-Z_][a-zA-Z0-9_]* \{|[a-zA-Z_][a-zA-Z0-9_]*\(\))' ~/.zshrc | sed -E 's/^function ([a-zA-Z_][a-zA-Z0-9_]*).*$/\1/; s/^([a-zA-Z_][a-zA-Z0-9_]*)\(\).*$/\1/' | sort -u | fzf --preview 'awk "/^function {}[({]/ {p=1} p {print} /^}}/ && p {exit}" ~/.zshrc | bat --color=always --language=bash --style=numbers' --preview-window=right:60%:wrap --height=80%)

	if [ -n "$func_list" ]; then
		print -z "$func_list "
	fi
}

function odsAuthConnect() {
	~/alloydb-auth-proxy projects/one-global-ods-uat/locations/asia-southeast1/clusters/sea1-uat-ods-db-cluster/instances/ods-ecomapi --port 9999 --auto-iam-authn --public-ip
}

function dockerDaemonStart() { colima start; }

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

		local input_type=$(echo "$input_section" | grep "type:" | sed 's/.*type:[[:space:]]*//' | tr -d '"')
		local input_desc=$(echo "$input_section" | grep "description:" | sed 's/.*description:[[:space:]]*//' | tr -d '"')
		local input_required=$(echo "$input_section" | grep "required:" | sed 's/.*required:[[:space:]]*//' | tr -d '"')

		if [ "$input_type" = "choice" ]; then
			local options_list
			options_list=$(echo "$input_section" | sed -n '/options:/,/^      [a-z]/p' | grep '^          -' | sed 's/^          - //' | tr -d '"')

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

function killPort() {
	kill $(lsof -t -i:$1)
}
# Neovim Configuration
export EDITOR="nvim"
alias vim="nvim"

# Added by Antigravity
function agy() {
    antigravity "${@:-.}"
}
