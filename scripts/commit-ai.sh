#!/usr/bin/env bash

# Re-execute the script with the correct Bash if needed
if [[ "$BASH_VERSION" < "5" && -x /opt/homebrew/bin/bash ]]; then
  exec /opt/homebrew/bin/bash "$0" "$@"
elif [[ "$BASH_VERSION" < "5" && -x /usr/local/bin/bash ]]; then
  exec /usr/local/bin/bash "$0" "$@"
fi

# --- Pre-checks ---
if ! command -v ollama &> /dev/null; then
    echo "Error: ollama is not installed or not in PATH." >&2
    echo "Please ensure ollama is available." >&2
    exit 1
fi

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository." >&2
    exit 1
fi

# --- Get Git Diff (truncated per file) ---
echo "Getting staged Git diff (with truncation)..."

# Get list of staged files
STAGED_FILES=$(git diff --staged --name-only)

if [ -z "$STAGED_FILES" ]; then
  echo "No changes staged for commit." >&2
  echo "Hint: Use 'git add <file>...' to stage your changes first." >&2
  exit 0
fi

# Configuration for truncation
MAX_LINES_PER_FILE=100
MAX_CHARS_PER_FILE=2000

# Build truncated diff for each file
GIT_DIFF=""
while IFS= read -r file; do
    [ -z "$file" ] && continue
    echo "Processing: $file"
    file_diff=$(git diff --staged -- "$file")
    
    if [ -n "$file_diff" ]; then
        # Count lines in the diff
        line_count=$(echo "$file_diff" | wc -l | tr -d ' ')
        char_count=$(echo "$file_diff" | wc -c)
        
        # Truncate if necessary
        if [ "$line_count" -gt "$MAX_LINES_PER_FILE" ] || [ "$char_count" -gt "$MAX_CHARS_PER_FILE" ]; then
            truncated_diff=$(echo "$file_diff" | head -n "$MAX_LINES_PER_FILE")
            truncated_chars=$(echo "$truncated_diff" | wc -c)
            if [ "$truncated_chars" -gt "$MAX_CHARS_PER_FILE" ]; then
                truncated_diff=$(printf "%.${MAX_CHARS_PER_FILE}s" "$truncated_diff")
            fi
            GIT_DIFF="${GIT_DIFF}${truncated_diff}
            
... (truncated: ${line_count} lines, ${char_count} chars total)

"
        else
            GIT_DIFF="${GIT_DIFF}${file_diff}

"
        fi
    fi
done <<< "$STAGED_FILES"

# Remove trailing newlines
GIT_DIFF=$(printf "%s" "$GIT_DIFF" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

total_char_count=$(printf "%s" "$GIT_DIFF" | wc -c)
echo "Total diff size: ${total_char_count} characters"

# --- Prepare Prompt for Cursor Agent ---
COMMIT_PROMPT="Analyze the following Git diff and generate a concise commit message following the Conventional Commits specification (e.g., 'feat:', 'fix:', 'refactor:', 'chore:', 'docs:', 'test:', 'style:', 'perf:').
in case of a version upgrade search for the improvements that this increase bring into the code

The commit message should have:
1. A short subject line (under 50 chars if possible).
2. Optionally, a blank line followed by a more detailed body explaining the 'what' and 'why' of the changes.

Output *only* the raw commit message (subject and optional body), without any introductory text like 'Here is the commit message:' or markdown formatting like \`\`\`.

Git Diff:"

FULL_REQUEST_TEXT=$(printf "%s\n\n\`\`\`diff\n%s\n\`\`\`" "$COMMIT_PROMPT" "$GIT_DIFF")

# --- Call Ollama ---
echo "Sending diff to ollama (model: gemma3n:e4b)..."
COMMIT_MESSAGE=$(echo "$FULL_REQUEST_TEXT" | ollama run gemma3n:e4b)

if [ $? -ne 0 ]; then
    echo "Error: ollama command failed." >&2
    exit 1
fi

# Check if COMMIT_MESSAGE is empty
if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: ollama returned an empty response." >&2
    exit 1
fi

# --- Display Suggestion and Ask for Confirmation ---
echo ""
echo "--- Suggested Commit Message ---"
printf "%s\n" "$COMMIT_MESSAGE"
echo "------------------------------"
echo ""

read -p "Apply this commit message? [y/N]: " user_confirm
user_confirm_lower=$(echo "$user_confirm" | tr '[:upper:]' '[:lower:]')

# --- Perform Commit if Confirmed ---
if [[ "$user_confirm_lower" == "y" || "$user_confirm_lower" == "yes" ]]; then
    echo "Applying commit..."

    subject=$(echo "$COMMIT_MESSAGE" | head -n 1)
    body=$(echo "$COMMIT_MESSAGE" | tail -n +2)

    if [ -z "$body" ]; then
      git commit -m "$subject"
    else
      git commit -m "$subject" -m "$body"
    fi

    commit_status=$?
    if [ $commit_status -eq 0 ]; then
        echo "Commit successful."
        exit 0
    else
        echo "Error: 'git commit' command failed with status $commit_status." >&2
        exit $commit_status
    fi
else
    echo "Commit skipped by user."
    exit 0
fi
