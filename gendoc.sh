#!/bin/bash

for i in raid aes erasure_code crc hash gzip; do
    nim doc --out:doc/isa/$i.html isa/$i.nim
done
