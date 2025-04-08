#!/usr/bin/env bash

# Default to dry run unless DRY_RUN is explicitly 0
if [[ "$DRY_RUN" != "0" ]]; then
  echo "[INFO] Running in DRY RUN mode. Set DRY_RUN=0 to actually delete branches."
  DRY=true
else
  echo "[INFO] Running in DELETE mode. Branches will be permanently removed."
  DRY=false
fi

# Default protected branches (can be overridden)
PROTECTED_BRANCHES=${PROTECTED_BRANCHES:-"main master develop compatible"}
read -ra PROTECTED <<< "$PROTECTED_BRANCHES"

# Default age threshold (can be overridden)
BRANCH_AGE=${BRANCH_AGE:-"1m"}

# Convert age threshold to `date -d` format
case "$BRANCH_AGE" in
  *d) AGE_STRING="${BRANCH_AGE%d} days ago" ;;
  *w) AGE_STRING="$(( ${BRANCH_AGE%w} * 7 )) days ago" ;;
  *m) AGE_STRING="${BRANCH_AGE%m} month ago" ;;  # best-effort, "1 month ago"
  *)  echo "[ERROR] Invalid BRANCH_AGE format. Use something like 10d, 2w, or 1m."; exit 1 ;;
esac

CUTOFF_TIMESTAMP=$(date -d "$AGE_STRING" +%s)

# Function to check if a branch is protected
is_protected() {
  local b="$1"
  for protected in "${PROTECTED[@]}"; do
    if [[ "$b" == "$protected" ]]; then
      return 0
    fi
  done
  return 1
}

echo "[INFO] Removing branches older than: $AGE_STRING"

# Get all local branches with last commit date, sorted most recent first
git for-each-ref --format="%(committerdate:iso8601)%09%(refname:short)" refs/heads/ | \
  sort -r | \
  while IFS=$'\t' read -r date branch; do
    if is_protected "$branch"; then
      continue
    fi

    if [[ $(date -d "$date" +%s) -lt $CUTOFF_TIMESTAMP ]]; then
      if $DRY; then
        echo "[DRY RUN] Would delete branch: $branch (last commit: $date)"
      else
        echo "[DELETE] Deleting branch: $branch (last commit: $date)"
        git branch -D "$branch"
      fi
    fi
  done
