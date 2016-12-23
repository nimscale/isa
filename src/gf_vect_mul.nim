## *
##   @file gf_vect_mul.h
##   @brief Interface to functions for vector (block) multiplication in GF(2^8).
## 
##   This file defines the interface to routines used in fast RAID rebuild and
##   erasure codes.
## 

{.deadCodeElim: on.}
when defined(windows):
  const
    libname* = "libisal.dll"
elif defined(macosx):
  const
    libname* = "libisal.dylib"
else:
  const
    libname* = "libisal.so"
## *
##  @brief GF(2^8) vector multiply by constant.
## 
##  Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
##  is a single field element in GF(2^8). Can be used for RAID6 rebuild
##  and partial write functions. Function requires pre-calculation of a
##  32-element constant array based on constant C. gftbl(C) = {C{00},
##  C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
##  and src must be aligned to 32B.
##  @requires SSE4.1
## 
##  @param len   Length of vector in bytes. Must be aligned to 32B.
##  @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
##  @param src   Pointer to src data array. Must be aligned to 32B.
##  @param dest  Pointer to destination data array. Must be aligned to 32B.
##  @returns 0 pass, other fail
## 

proc gf_vect_mul_sse*(len: cint; gftbl: ptr cuchar; src: pointer; dest: pointer): cint {.
    cdecl, importc: "gf_vect_mul_sse", dynlib: libname.}
## *
##  @brief GF(2^8) vector multiply by constant.
## 
##  Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
##  is a single field element in GF(2^8). Can be used for RAID6 rebuild
##  and partial write functions. Function requires pre-calculation of a
##  32-element constant array based on constant C. gftbl(C) = {C{00},
##  C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
##  and src must be aligned to 32B.
##  @requires AVX
## 
##  @param len   Length of vector in bytes. Must be aligned to 32B.
##  @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
##  @param src   Pointer to src data array. Must be aligned to 32B.
##  @param dest  Pointer to destination data array. Must be aligned to 32B.
##  @returns 0 pass, other fail
## 

proc gf_vect_mul_avx*(len: cint; gftbl: ptr cuchar; src: pointer; dest: pointer): cint {.
    cdecl, importc: "gf_vect_mul_avx", dynlib: libname.}
## *
##  @brief GF(2^8) vector multiply by constant, runs appropriate version.
## 
##  Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
##  is a single field element in GF(2^8). Can be used for RAID6 rebuild
##  and partial write functions. Function requires pre-calculation of a
##  32-element constant array based on constant C. gftbl(C) = {C{00},
##  C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }.
##  Len and src must be aligned to 32B.
## 
##  This function determines what instruction sets are enabled
##  and selects the appropriate version at runtime.
## 
##  @param len   Length of vector in bytes. Must be aligned to 32B.
##  @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
##  @param src   Pointer to src data array. Must be aligned to 32B.
##  @param dest  Pointer to destination data array. Must be aligned to 32B.
##  @returns 0 pass, other fail
## 

proc gf_vect_mul*(len: cint; gftbl: ptr cuchar; src: pointer; dest: pointer): cint {.cdecl,
    importc: "gf_vect_mul", dynlib: libname.}
## *
##  @brief Initialize 32-byte constant array for GF(2^8) vector multiply
## 
##  Calculates array {C{00}, C{01}, C{02}, ... , C{0f} }, {C{00}, C{10},
##  C{20}, ... , C{f0} } as required by other fast vector multiply
##  functions.
##  @param c     Constant input.
##  @param gftbl Table output.
## 

proc gf_vect_mul_init*(c: cuchar; gftbl: ptr cuchar) {.cdecl,
    importc: "gf_vect_mul_init", dynlib: libname.}
## *
##  @brief GF(2^8) vector multiply by constant, runs baseline version.
## 
##  Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
##  is a single field element in GF(2^8). Can be used for RAID6 rebuild
##  and partial write functions. Function requires pre-calculation of a
##  32-element constant array based on constant C. gftbl(C) = {C{00},
##  C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
##  and src must be aligned to 32B.
## 
##  @param len   Length of vector in bytes. Must be aligned to 32B.
##  @param a 	Pointer to 32-byte array of pre-calculated constants based on C.
##  		only use 2nd element is used.
##  @param src   Pointer to src data array. Must be aligned to 32B.
##  @param dest  Pointer to destination data array. Must be aligned to 32B.
## 

proc gf_vect_mul_base*(len: cint; a: ptr cuchar; src: ptr cuchar; dest: ptr cuchar) {.cdecl,
    importc: "gf_vect_mul_base", dynlib: libname.}