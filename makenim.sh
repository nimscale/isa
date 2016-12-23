#for ISA-L-master
c2nim  --prefix:isa_ --dynlib:libname --cdecl include/gf_vect_mul.h --out:src/gf_vect_mul.nim
c2nim  --prefix:isa_ --dynlib:libname --cdecl include/erasure_code.h --out:src/erasure_code.nim
#for ISA-L_Cryptor
