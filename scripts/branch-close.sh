#!/usr/bin/env bash

# Re-execute the script with the correct Bash if needed
if [[ "$BASH_VERSION" < "5" && -x /opt/homebrew/bin/bash ]]; then
  exec /opt/homebrew/bin/bash "$0" "$@"
elif [[ "$BASH_VERSION" < "5" && -x /usr/local/bin/bash ]]; then
  exec /usr/local/bin/bash "$0" "$@"
fi

# Ensure we're inside a Git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "❌ You are not inside a Git repository."
  exit 1
fi

# Get the current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Detect default branch: main or master
if git show-ref --verify --quiet refs/heads/main; then
  DEFAULT_BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
  DEFAULT_BRANCH="master"
else
  echo "❌ Could not find 'main' or 'master' as the default branch."
  exit 1
fi

# Show selection menu using fzf if available
if command -v fzf &>/dev/null; then
  echo "Select the branch to merge into (default: $DEFAULT_BRANCH):"
  SELECTED_BRANCH=$(git branch --format='%(refname:short)' | grep -v "$CURRENT_BRANCH" | fzf --prompt="Target branch: " --height=10)  
else
  echo "fzf is not installed. Using default branch: $DEFAULT_BRANCH"
  SELECTED_BRANCH=$DEFAULT_BRANCH
fi

# Use default branch if none selected
if [ -z "$SELECTED_BRANCH" ]; then
  SELECTED_BRANCH=$DEFAULT_BRANCH
fi

# Exit if still no branch is selected (very rare case)
if [ -z "$SELECTED_BRANCH" ]; then
  echo "⚠️ No branch selected. Aborting."
  exit 0
fi

# Confirm the merge and delete
echo "You are about to merge branch '$CURRENT_BRANCH' into '$SELECTED_BRANCH' and then delete '$CURRENT_BRANCH'. Proceed? [y/N]"
read -r CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  git checkout "$SELECTED_BRANCH" || exit 1
  git merge "$CURRENT_BRANCH" || exit 1
  git branch -d "$CURRENT_BRANCH" || exit 1
  echo "✅ Branch '$CURRENT_BRANCH' merged into '$SELECTED_BRANCH' and deleted."
else
  echo "❌ Operation cancelled."
fi
