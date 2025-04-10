#!/usr/bin/env bash

# Default repository and branch
REPO="MinaProtocol/mina"
REPO_URL="https://github.com/$REPO"
TARGET_BRANCH="${1:-compatible}"  # Default to 'compatible' if no branch is provided

while true; do
    clear
    echo "🔍 Checking PRs targeting $TARGET_BRANCH branch in $REPO... ($(date))"
    echo "------------------------------------------------------------"

    gh pr list -R "$REPO" --base "$TARGET_BRANCH" --state open --json number,title,author,mergeable,statusCheckRollup,reviewDecision | \
    jq -r '
    .[] | {
        number,
        title,
        author: .author.login,
        mergeable,
        reviewDecision,
        bk_status: (
            .statusCheckRollup[]?
            | select(.context == "buildkite/mina-o-1-labs/pr")
            | .state // "UNKNOWN"
        ),
        bk_url: (
            .statusCheckRollup[]?
            | select(.context == "buildkite/mina-o-1-labs/pr")
            | .targetUrl // ""
        )
    } | [.number, .title, .author, .mergeable, .bk_status, .bk_url, .reviewDecision] | @tsv' | \
    while IFS=$'\t' read -r number title author mergeable bk_status bk_url reviewDecision; do

        pr_url="$REPO_URL/pull/$number"

        # Determine review status
        review_status=""
        if [[ "$reviewDecision" == "null" || "$reviewDecision" == "" ]]; then
            review_status="⚠️ No reviews"
        elif [[ "$reviewDecision" == "APPROVED" ]]; then
            review_status="✅ Approved by reviewer(s)"
        elif [[ "$reviewDecision" == "CHANGES_REQUESTED" ]]; then
            review_status="⚠️ Changes requested"
        elif [[ "$reviewDecision" == "REVIEW_REQUIRED" ]]; then
            review_status="⏳ Review required"
        else
            review_status="❓ Review status: $reviewDecision"
        fi

        # Determine CI/merge status
        case "$mergeable:$bk_status" in
            "MERGEABLE:SUCCESS"|"MERGEABLE:COMPLETE")
                if [[ "$reviewDecision" == "APPROVED" ]]; then
                    state="🟢 Ready to merge"
                else
                    state="🟡 CI passed, waiting for review"
                fi
                ;;
            "MERGEABLE:PENDING"|"MERGEABLE:QUEUED")
                state="🟡 Buildkite running"
                ;;
            "MERGEABLE:FAILURE"|"MERGEABLE:ERROR")
                state="🔴 Buildkite failed"
                ;;
            "CONFLICTING:"*)
                state="❌ Merge conflict"
                ;;
            *)
                state="⚪ Not ready or unknown"
                ;;
        esac

        echo "PR #$number: $title"
        echo "   👤 Author: $author"
        echo "   → $state"
        echo "   👁️ $review_status"
        echo "   🔗 $pr_url"
        if [[ -n "$bk_url" ]]; then
            echo "   🏗️ $bk_url"
        fi
        echo
    done

    # Show usage instructions at the bottom
    echo
    echo "Usage: $(basename "$0") [branch-name]"
    echo "Default branch: compatible"
    echo
    echo "Press Ctrl+C to exit"

    sleep 30
done
