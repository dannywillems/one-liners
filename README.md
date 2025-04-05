# A collection of one-lines in different languages

## Bash

Run `cargo clean` recursively
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

## Python 3 - One-Liners

Conversion from little (resp big) endian to big (resp. little endian):
```
s = "000000000050ab40"
rev_s = bytearray.fromhex(s)[::-1].hex()
```
