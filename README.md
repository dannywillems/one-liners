## Python 3 - One-Liners

Conversion from little (resp big) endian to big (resp. little endian):
```
s = "000000000050ab40"
rev_s = bytearray.fromhex(s)[::-1].hex()
```
