# isa
nim bindings for https://github.com/01org/isa-l

Wrapper for ISA, generated via c2nim.
The erasure_code.h and gf_vect_mul.h was used without any change.
Binding works of performance test for isa-l:
  Run "nim c -r perftest.nim"
Binding works for crypto sample for isa-l-crypt:
  Run "nim c -r xts_128_dec_perf.nim"

- check C2NIM which will do most of the work


