#!/bin/bash

REPO="MinaProtocol/mina"
REPO_URL="https://github.com/$REPO"

while true; do
    clear
    echo "🔍 Checking your open PRs in $REPO... ($(date))"
    echo "------------------------------------------------------------"

    gh pr list -R "$REPO" --author "@me" --state open --json number,title,mergeable,statusCheckRollup | \
    jq -r '
    .[] | {
        number,
        title,
        mergeable,
        bk_status: (
            .statusCheckRollup[]? 
            | select(.context == "buildkite/mina-o-1-labs/pr") 
            | .state // "UNKNOWN"
        )
    } | [.number, .title, .mergeable, .bk_status] | @tsv' | \
    while IFS=$'\t' read -r number title mergeable bk_status; do

        pr_url="$REPO_URL/pull/$number"

        case "$mergeable:$bk_status" in
            "MERGEABLE:SUCCESS"|"MERGEABLE:COMPLETE")
                state="🟢 Ready to merge"
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
        echo "   → $state"
        echo "   🔗 $pr_url"
        echo
    done

    sleep 10
done
