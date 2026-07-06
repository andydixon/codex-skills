#!/usr/bin/env bash
set -euo pipefail

repo="${1:-.}"
cd "$repo"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a Git repository: $repo" >&2
  exit 1
fi

echo "# Repository"
printf "Root: %s\n" "$(git rev-parse --show-toplevel)"
printf "HEAD: %s\n" "$(git log -1 --format='%h %ad %s' --date=short)"
echo

echo "# Working Tree"
git status --short || true
echo

echo "# Tags Chronological"
tags=()
while IFS= read -r tag; do
  tags+=("$tag")
done < <(git tag --sort=creatordate)
if ((${#tags[@]} == 0)); then
  echo "No tags found."
else
  for tag in "${tags[@]}"; do
    printf "%s | %s | %s\n" \
      "$tag" \
      "$(git log -1 --format='%ad' --date=short "$tag")" \
      "$(git log -1 --format='%h %s' "$tag")"
  done
fi
echo

echo "# Milestone Diff Stats"
if ((${#tags[@]} > 0)); then
  first_commit="$(git rev-list --max-parents=0 HEAD | tail -n 1)"
  prev="$first_commit"
  prev_label="first commit ${first_commit:0:7}"
  for tag in "${tags[@]}"; do
    printf "## %s -> %s\n" "$prev_label" "$tag"
    git diff --shortstat "$prev".."$tag" || true
    prev="$tag"
    prev_label="$tag"
  done
  printf "## %s -> HEAD\n" "$prev_label"
  git diff --shortstat "$prev"..HEAD || true
else
  git diff --shortstat "$(git rev-list --max-parents=0 HEAD | tail -n 1)"..HEAD || true
fi
echo

echo "# Recent Commit Timeline"
git log --date=short --pretty=format:'%h | %ad | %s' --reverse --max-count=120
echo
echo

echo "# Largest Commits By Changed Files"
git log --pretty=format:'%h' --max-count=300 |
while read -r commit; do
  files="$(git show --shortstat --format= "$commit" | awk '/files? changed/ {print $1 + 0}')"
  printf "%06d %s %s\n" "${files:-0}" "$commit" "$(git log -1 --format='%ad | %s' --date=short "$commit")"
done | sort -rn | head -n 30
echo

echo "# Largest Commits By Line Churn"
git log --pretty=format:'%h' --max-count=300 |
while read -r commit; do
  stat="$(git show --shortstat --format= "$commit")"
  inserted="$(awk '/insertions?\(\+\)/ {for (i=1;i<=NF;i++) if ($i ~ /insertions?\(\+\)/) print $(i-1)}' <<<"$stat")"
  deleted="$(awk '/deletions?\(-\)/ {for (i=1;i<=NF;i++) if ($i ~ /deletions?\(-\)/) print $(i-1)}' <<<"$stat")"
  churn="$(( ${inserted:-0} + ${deleted:-0} ))"
  printf "%08d %s %s\n" "$churn" "$commit" "$(git log -1 --format='%ad | %s' --date=short "$commit")"
done | sort -rn | head -n 30
