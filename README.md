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

It is recommended to compile with gc-sections (see `nim.cfg` for example configuration), so only required routines are included in the binary.
