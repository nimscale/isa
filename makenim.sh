#for ISA-L-master
c2nim  --prefix:isa_ --dynlib:libname --cdecl include/gf_vect_mul.h --out:src/gfvectmul.nim
c2nim  --prefix:isa_ --dynlib:libname --cdecl include/erasure_code.h --out:src/erasurecode.nim
#for ISA-L_Cryptor
