#for ISA-L-master
c2nim  --prefix:isa_ --dynlib:libname --cdecl gf_vect_mul.h --out:gf_vect_mul.nim
c2nim  --prefix:isa_ --dynlib:libname --cdecl erasure_code.h --out:erasure_code.nim

#for ISA-L_Cryptor
