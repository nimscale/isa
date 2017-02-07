import isa/hash, collections

block:
  let pool = newSha1Pool()
  let hashes = pool.computeHashes(@["", "", "hello", "world"])

  assert hashes[0].encodeHex == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
  assert hashes[2].encodeHex == "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d"

  for hash in hashes:
    echo hash.encodeHex

block:
  let pool = newMd5Pool()
  let hashes = pool.computeHashes(@["", "", "hello", "world"])

  assert hashes[0].encodeHex == "d41d8cd98f00b204e9800998ecf8427e"

  for hash in hashes:
    echo hash.encodeHex

block:
  let pool = newSha256Pool()
  let hashes = pool.computeHashes(@["", "", "hello", "world"])

  assert hashes[0].encodeHex == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  for hash in hashes:
    echo hash.encodeHex

block:
  let pool = newSha512Pool()
  let hashes = pool.computeHashes(@["", "", "hello", "world"])

  assert hashes[0].encodeHex == "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"

  for hash in hashes:
    echo hash.encodeHex
