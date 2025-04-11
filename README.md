# One-Liners

A collection of useful one-liners and scripts in different programming languages.

## Bash

### Monitor GitHub Pull Requests

The repository includes scripts to monitor the status of GitHub PRs:

#### Monitor Your Own PRs

```bash
# Run the script to monitor your open PRs
./check-pr.sh
```

This script continuously checks your open PRs, showing their merge status and CI status. It uses the GitHub CLI, so make sure you have `gh` installed and authenticated.

See [check-pr.sh](./check-pr.sh) for more details.

#### Monitor PRs Targeting a Specific Branch

```bash
# Monitor PRs targeting the 'compatible' branch (default)
./check-branch-pr.sh

# Monitor PRs targeting a different branch
./check-branch-pr.sh develop
```

This script monitors all open PRs targeting a specific branch. It shows PR status including:
- Merge status (mergeable, conflicts)
- CI status (passing, running, failed)
- Review status (approved, changes requested, no reviews)
- Links to the PR and CI builds

See [check-branch-pr.sh](./check-branch-pr.sh) for more details.

### Run `cargo clean` recursively

```bash
find . -name Cargo.toml \
  -not -path "*/target/*" \
  | xargs -I {} dirname {} \
  | sort -u \
  | xargs -I {} bash -c '
      echo "Cleaning {}"
      cd "{}" && cargo clean
    '
```

### Ignore specific directories

If you want to ignore `foo` and `bar` directories in any path:

```bash
find . -name Cargo.toml \
  -not -path "*/target/*" \
  | grep -vE "foo|bar" \
  | xargs -I {} dirname {} \
  | sort -u \
  | xargs -I {} bash -c '
      echo "Cleaning {}"
      cd "{}" && cargo clean
    '
```

### Delete old Git branches

The repository includes a script to safely delete Git branches older than a specified age:

```bash
# Dry run mode (shows what would be deleted)
./delete-old-branches.sh

# Actually delete branches older than 1 month (default)
DRY_RUN=0 ./delete-old-branches.sh

# Delete branches older than 2 weeks with custom protected branches
DRY_RUN=0 BRANCH_AGE=2w PROTECTED_BRANCHES="main develop" ./delete-old-branches.sh
```

See [delete-old-branches.sh](./delete-old-branches.sh) for more details.

### List all Makefile targets

Extract all targets from a Makefile:

```bash
grep -E '^[a-zA-Z0-9_-]+:' Makefile | awk -F: '{print $1}'
```

### Find and remove unused .PHONY targets

The repository includes a script to find and optionally remove unused `.PHONY` targets in a Makefile:

```bash
# Dry run mode (only shows what would be removed)
./find-unused-phony-targets.sh [path_to_makefile]

# Actually remove unused .PHONY targets
DRY_RUN=0 ./find-unused-phony-targets.sh [path_to_makefile]
```

See [find-unused-phony-targets.sh](./find-unused-phony-targets.sh) for more details.

## Python 3

### Endian conversion

Convert from little endian to big endian (or vice versa):

```python
s = "000000000050ab40"
rev_s = bytearray.fromhex(s)[::-1].hex()
```
