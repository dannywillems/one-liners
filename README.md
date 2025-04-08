# One-Liners

A collection of useful one-liners and scripts in different programming languages.

## Bash

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

## Python 3

### Endian conversion

Convert from little endian to big endian (or vice versa):

```python
s = "000000000050ab40"
rev_s = bytearray.fromhex(s)[::-1].hex()
```
