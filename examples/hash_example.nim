import isa/hash, collections

let pool = newSha1Pool()
let hashes = pool.computeHashes(@["", "", "hello", "world"])

assert hashes[0].encodeHex == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
assert hashes[2].encodeHex == "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d"

for hash in hashes:
  echo hash.encodeHex
