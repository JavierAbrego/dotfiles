#!/usr/bin/env bash

# Re-execute the script with the correct Bash if needed
if [[ "$BASH_VERSION" < "5" && -x /opt/homebrew/bin/bash ]]; then
  exec /opt/homebrew/bin/bash "$0" "$@"
elif [[ "$BASH_VERSION" < "5" && -x /usr/local/bin/bash ]]; then
  exec /usr/local/bin/bash "$0" "$@"
fi

# --- Configuration ---
API_KEY="$GEMINI_API_KEY"
MODEL_NAME="gemini-2.5-flash"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"

# --- Pre-checks ---
if [ -z "$API_KEY" ]; then
  echo "Error: GEMINI_API_KEY environment variable is not set." >&2
  echo "Please set it before running the script:" >&2
  echo "export GEMINI_API_KEY='YourApiKeyHere'" >&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it (e.g., 'sudo apt install jq' or 'brew install jq')." >&2
    exit 1
fi

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository." >&2
    exit 1
fi

# --- Get Git Diff ---
echo "Getting staged Git diff..."
GIT_DIFF=$(git diff --staged)

if [ -z "$GIT_DIFF" ]; then
  echo "No changes staged for commit." >&2
  echo "Hint: Use 'git add <file>...' to stage your changes first." >&2
  exit 0
fi

char_count=$(echo "$GIT_DIFF" | wc -c)
max_chars=15000
if [ "$char_count" -gt "$max_chars" ]; then
    echo "Warning: Staged diff is very large (${char_count} characters). Proceeding, but API might truncate or reject." >&2
fi

# --- Prepare Prompt for Gemini ---
COMMIT_PROMPT="Analyze the following Git diff and generate a concise commit message following the Conventional Commits specification (e.g., 'feat:', 'fix:', 'refactor:', 'chore:', 'docs:', 'test:', 'style:', 'perf:').
in case of a version upgrade search for the improvements that this increase bring into the code

The commit message should have:
1. A short subject line (under 50 chars if possible).
2. Optionally, a blank line followed by a more detailed body explaining the 'what' and 'why' of the changes.

Output *only* the raw commit message (subject and optional body), without any introductory text like 'Here is the commit message:' or markdown formatting like \`\`\`.

Git Diff:"

FULL_REQUEST_TEXT=$(printf "%s\n\n\`\`\`diff\n%s\n\`\`\`" "$COMMIT_PROMPT" "$GIT_DIFF")

# --- Construct JSON Payload using jq ---
JSON_PAYLOAD=$(jq -n --arg text "$FULL_REQUEST_TEXT" \
  '{contents: [{parts: [{text: $text}]}]}')

if [ $? -ne 0 ]; then
    echo "Error: Failed to construct JSON payload using jq." >&2
    exit 1
fi

# --- Call Gemini API ---
echo "Sending diff to Gemini (${MODEL_NAME})..."
GEMINI_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "$API_URL")

HTTP_STATUS=$(echo "$GEMINI_RESPONSE" | tail -n1 | sed 's/HTTP_STATUS://')
RESPONSE_BODY=$(echo "$GEMINI_RESPONSE" | sed '$d')

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error: Gemini API request failed with HTTP status ${HTTP_STATUS}." >&2
    echo "Response:" >&2
    echo "$RESPONSE_BODY" >&2
    exit 1
fi

# --- Parse Response ---
# Remove null bytes from response body before parsing with jq, as they can cause errors
CLEANED_RESPONSE_BODY=$(echo "$RESPONSE_BODY" | tr -d '\000')

# Extract the text using jq from the cleaned response. Handle cases where the expected path doesn't exist.
COMMIT_MESSAGE=$(echo "$CLEANED_RESPONSE_BODY" | jq -r '.candidates[0].content.parts[0].text // empty')

# Check if COMMIT_MESSAGE is empty AFTER attempting to parse
if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: Failed to extract commit message from Gemini response or response was empty." >&2
    echo "Raw Response Body (first 500 chars):" >&2
    # Print only the beginning of the potentially large/problematic raw body
    printf "%.500s\n" "$RESPONSE_BODY" >&2 # Show original body for debugging

    # Also try parsing the block reason from the cleaned response
    BLOCK_REASON=$(echo "$CLEANED_RESPONSE_BODY" | jq -r '.promptFeedback.blockReason // empty')
    if [ -n "$BLOCK_REASON" ]; then
        echo "Block Reason: $BLOCK_REASON" >&2
    fi
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