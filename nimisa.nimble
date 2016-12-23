[Package]
name          = "nimisa"
version       = "0.1.0"
author        = "Andrzej Slomski"
description   = "nim bindings for isa"
license       = "Apache License"

srcDir        = "src"
binDir        = "bin"

bin = "crc64_example, perftest, xts_128_dec_perf"

[Deps]
Requires: "nim >= 0.15.2, compiler >= 0.15.2"

