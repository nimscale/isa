# isa
nim bindings for https://github.com/01org/isa-l and isa-l-crypt

Wrapper for ISA, generated via c2nim.
The erasure_code.h and gf_vect_mul.h was used without any change.

crc64_example.nim: 	The sample of crccheck
perftest.nim: 		The sample of performance test
xts_128_dec_perf.nim: 	The sample of crypto

Binding works of these samplese: 
  Run "nim bulid"
Then the binary files will be generated in "bin" directory.


- check C2NIM which will do most of the work


