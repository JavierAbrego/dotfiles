#!/bin/bash

# Function to count lines of code for a specific commit
count_lines_for_commit() {
  local commit=$1
  git show --stat $commit | grep 'changed' | awk '{add+=$4; del+=$6} END {print add, del}'
}

# Get the date of one month ago
one_month_ago=$(date -d "1 month ago" +%Y-%m-%d)

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
  for (d in added) {
    net[d] = added[d] - deleted[d]
    if (net[d] > max) max = net[d]
    dates[++i] = d
  }
  asort(dates)
  for (j = 1; j <= i; j++) {
    d = dates[j]
    scaled_value = int((net[d] / max) * max_width)
    printf "%s |", d
    for (k = 0; k < scaled_value; k++) {
      printf "#"
    }
    printf " %d\n", net[d]
  }
}'