#!/usr/bin/env bash

# Re-execute the script with the correct Bash if needed
if [[ "$BASH_VERSION" < "5" && -x /opt/homebrew/bin/bash ]]; then
  exec /opt/homebrew/bin/bash "$0" "$@"
elif [[ "$BASH_VERSION" < "5" && -x /usr/local/bin/bash ]]; then
  exec /usr/local/bin/bash "$0" "$@"
fi

# Function to count lines of code for a specific commit
count_lines_for_commit() {
  local commit=$1
  git show --stat $commit | grep 'changed' | awk '{add+=$4; del+=$6} END {print add, del}'
}

# Get the date of one month ago (compatible with both GNU and BSD date)
if date -d "3 month ago" +%Y-%m-%d >/dev/null 2>&1; then
  # GNU date (Linux)
  one_month_ago=$(date -d "3 month ago" +%Y-%m-%d)
else
  # BSD date (macOS)
  one_month_ago=$(date -v-3m +%Y-%m-%d)
fi

# Get the list of commits with dates and process them
git log --since="$one_month_ago" --pretty=format:"%H %ad" --date=short | while read commit date; do
  lines=$(count_lines_for_commit $commit)
  echo "$date $lines"
done | awk '
{
  date=$1
  added[date] += $2
  deleted[date] += $3
}
END {
  max_width = 50
  max = 0
  count = 0
  for (d in added) {
    net[d] = added[d] - deleted[d]
    if (net[d] > max) max = net[d]
    dates[++count] = d
  }
  # Simple bubble sort for dates (YYYY-MM-DD format sorts lexicographically)
  for (i = 1; i <= count; i++) {
    for (j = 1; j < count; j++) {
      if (dates[j] > dates[j+1]) {
        temp = dates[j]
        dates[j] = dates[j+1]
        dates[j+1] = temp
      }
    }
  }
  for (j = 1; j <= count; j++) {
    d = dates[j]
    scaled_value = int((net[d] / max) * max_width)
    printf "%s |", d
    for (k = 0; k < scaled_value; k++) {
      printf "#"
    }
    printf " %d\n", net[d]
  }
}'