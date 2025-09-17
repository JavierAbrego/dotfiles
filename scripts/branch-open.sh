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

if ! command -v fzf &>/dev/null; then
  echo "Error: fzf is not installed." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required for parsing JSON responses." >&2
  exit 1
fi

# --- Select branch type ---
TYPE=$(printf "feat\nbugfix\ndocs\nrefactor\nchore\ntest\nci\nstyle\nperf\nbuild\nrevert" | fzf --prompt="Select branch type: ")

if [ -z "$TYPE" ]; then
  echo "No type selected. Aborting."
  exit 1
fi

# --- Ask for branch description ---
read -rp "Describe what you're going to do: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
  echo "You must provide a description."
  exit 1
fi

# --- Optional: ask for ticket number ---
read -rp "Optional ticket number (e.g. PROJ-123): " TICKET

# --- Build prompt for Gemini ---
PROMPT="Generate a short, lowercase, hyphen-separated git branch slug based on this description: \"$DESCRIPTION\". You can improve the text to reflect better and more technically what's going to be done — the description is probably very vague. Do not include any prefix like 'feat/' or ticket number. Only return the slug."

# Function to generate a branch slug via Gemini
generate_branch_slug() {
  local payload response http_status body cleaned slug
  payload=$(jq -n --arg text "$PROMPT" '{contents: [{parts: [{text: $text}]}]}')

  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$payload" "$API_URL")

  http_status=$(echo "$response" | tail -n1 | sed 's/HTTP_STATUS://')
  body=$(echo "$response" | sed '$d')

  if [ "$http_status" -ne 200 ]; then
    echo "Error: Gemini API request failed with HTTP status ${http_status}." >&2
    echo "$body" >&2
    return 1
  fi

  cleaned=$(echo "$body" | tr -d '\000')
  slug=$(echo "$cleaned" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null | head -n1 | tr -d '\r' | sed 's|[^a-z0-9-]||g')

  if [ -z "$slug" ] || [ "$slug" == "null" ]; then
    echo "❌ Failed to extract valid slug from Gemini response:"
    echo "$cleaned" | jq .
    return 1
  fi

  echo "$slug"
  return 0
}

# --- Loop until user accepts or exits ---
while true; do
  SLUG=$(generate_branch_slug)
  if [ $? -ne 0 ]; then
    echo "Aborting due to Gemini error."
    exit 1
  fi

  if [ -n "$TICKET" ]; then
    FINAL_NAME="${TYPE}/${TICKET}-${SLUG}"
  else
    FINAL_NAME="${TYPE}/${SLUG}"
  fi

  echo "🔧 Proposed branch name: '$FINAL_NAME'"
  read -rp "Do you want to create this branch? [y/N] (type 'n' to regenerate) " CONFIRM

  case "$CONFIRM" in
    [Yy]* )
      git checkout -b "$FINAL_NAME"
      echo "✅ Branch '$FINAL_NAME' created and checked out."
      break
      ;;
    [Nn]* )
      echo "♻️  Regenerating branch name..."
      ;;
    * )
      echo "❌ Operation cancelled."
      exit 0
      ;;
  esac
done
