# isa

nim bindings for https://github.com/01org/isa-l and https://github.com/01org/isa-l-crypt

## Dependencies

This library contains isa-l and isa-l_crypto bundled, but requires assembler (Yasm) to be installed.

On Ubuntu:

```
apt-get install yasm
```

On macOS:

```
brew install yasm
```

## Using the library

The easiest way to install this library is to use [nimble](https://github.com/nim-lang/nimble):

```
nimble install isa
```

It is recommended to compile with gc-sections (see `nim.cfg` for example configuration), so only required routines are included in the binary.

## Functionality

  * Erasure codes ([API docs](https://rawgit.com/nimscale/isa/master/doc/isa/erasure_code.html), [example](examples/erasure_code_example.nim))
  * Deflate/GZIP compression ([API docs](https://rawgit.com/nimscale/isa/master/doc/isa/gzip.html), [example](examples/gzip_compress_example.nim))
  * CRC ([API docs](https://rawgit.com/nimscale/isa/master/doc/isa/crc.html))
  * AES compression ([API docs](https://rawgit.com/nimscale/isa/master/doc/isa/aes.html), [example](examples/aes_example.nim))
  * Batch hash computation (MD5, SHA1, SHA256, SHA512) ([API docs](https://rawgit.com/nimscale/isa/master/doc/isa/hash.html), [example](examples/hash_example.nim))
