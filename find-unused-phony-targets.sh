#!/usr/bin/env bash
# Script to find unused .PHONY targets in a Makefile
# Usage: ./find-unused-phony-targets.sh [path_to_makefile]
# If no path is provided, uses ./Makefile

set -e

# Default Makefile path
MAKEFILE="${1:-./Makefile}"
DRY_RUN="${DRY_RUN:-1}"

# Check if the Makefile exists
if [ ! -f "$MAKEFILE" ]; then
  echo "Error: Makefile not found at $MAKEFILE"
  exit 1
fi

# Get all targets defined in .PHONY
phony_targets=$(grep -A1 "^\.PHONY:" "$MAKEFILE" | grep -v "^\.PHONY:" | tr -d ' ' | tr '\n' ' ')

# Check for usage of each phony target in the Makefile
unused_targets=""
for target in $phony_targets; do
  # Look for the target definition (target:)
  target_defined=$(grep -c "^$target:" "$MAKEFILE" || true)

  if [ "$target_defined" -eq 0 ]; then
    # If target isn't defined, it's unused
    unused_targets="$unused_targets $target"
  fi
done

# Display results
if [ -z "$unused_targets" ]; then
  echo "No unused .PHONY targets found in $MAKEFILE"
  exit 0
fi

echo "Found unused .PHONY targets: $unused_targets"

# If not in dry-run mode, remove the unused targets from .PHONY
if [ "$DRY_RUN" -eq 0 ]; then
  echo "Removing unused targets from .PHONY declarations..."
  temp_file=$(mktemp)

  # Process the file and remove unused targets from .PHONY
  while IFS= read -r line; do
    if [[ $line =~ ^\.PHONY: ]]; then
      new_line=".PHONY:"
      # Get the targets from the .PHONY line
      targets=$(echo "$line" | sed 's/^\.PHONY://')

      # Keep only the targets that are not in the unused list
      for t in $targets; do
        if [[ ! "$unused_targets" =~ $t ]]; then
          new_line="$new_line $t"
        fi
      done

      echo "$new_line" >> "$temp_file"
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$MAKEFILE"

  # Replace the original file with the modified one
  mv "$temp_file" "$MAKEFILE"
  echo "Unused .PHONY targets have been removed."
else
  echo "Dry run mode. To remove the unused targets, run with DRY_RUN=0"
fi
