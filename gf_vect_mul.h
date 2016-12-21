#ifndef _GF_VECT_MUL_H
#define _GF_VECT_MUL_H

/**
 *  @file gf_vect_mul.h
 *  @brief Interface to functions for vector (block) multiplication in GF(2^8).
 *
 *  This file defines the interface to routines used in fast RAID rebuild and
 *  erasure codes.
 */

#ifdef C2NIM
#  dynlib libname
#  cdecl
#  prefix isa_
#  if defined(windows)
#    define libname "libisal.dll"
#  elif defined(macosx)
#    define libname "libisal.dylib"
#  else
#    define libname "libisal.so"
#  endif
#mangle uint16_t uint16
#mangle uint64_t uint64
#mangle int64_t int64
#endif



#ifdef __cplusplus
extern "C" {
#endif

 /**
 * @brief GF(2^8) vector multiply by constant.
 *
 * Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
 * is a single field element in GF(2^8). Can be used for RAID6 rebuild
 * and partial write functions. Function requires pre-calculation of a
 * 32-element constant array based on constant C. gftbl(C) = {C{00},
 * C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
 * and src must be aligned to 32B.
 * @requires SSE4.1
 *
 * @param len   Length of vector in bytes. Must be aligned to 32B.
 * @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
 * @param src   Pointer to src data array. Must be aligned to 32B.
 * @param dest  Pointer to destination data array. Must be aligned to 32B.
 * @returns 0 pass, other fail
 */

int gf_vect_mul_sse(int len, unsigned char *gftbl, void *src, void *dest);


 /**
 * @brief GF(2^8) vector multiply by constant.
 *
 * Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
 * is a single field element in GF(2^8). Can be used for RAID6 rebuild
 * and partial write functions. Function requires pre-calculation of a
 * 32-element constant array based on constant C. gftbl(C) = {C{00},
 * C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
 * and src must be aligned to 32B.
 * @requires AVX
 *
 * @param len   Length of vector in bytes. Must be aligned to 32B.
 * @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
 * @param src   Pointer to src data array. Must be aligned to 32B.
 * @param dest  Pointer to destination data array. Must be aligned to 32B.
 * @returns 0 pass, other fail
 */

int gf_vect_mul_avx(int len, unsigned char *gftbl, void *src, void *dest);


/**
 * @brief GF(2^8) vector multiply by constant, runs appropriate version.
 *
 * Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
 * is a single field element in GF(2^8). Can be used for RAID6 rebuild
 * and partial write functions. Function requires pre-calculation of a
 * 32-element constant array based on constant C. gftbl(C) = {C{00},
 * C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }.
 * Len and src must be aligned to 32B.
 *
 * This function determines what instruction sets are enabled
 * and selects the appropriate version at runtime.
 *
 * @param len   Length of vector in bytes. Must be aligned to 32B.
 * @param gftbl Pointer to 32-byte array of pre-calculated constants based on C.
 * @param src   Pointer to src data array. Must be aligned to 32B.
 * @param dest  Pointer to destination data array. Must be aligned to 32B.
 * @returns 0 pass, other fail
 */

int gf_vect_mul(int len, unsigned char *gftbl, void *src, void *dest);


/**
 * @brief Initialize 32-byte constant array for GF(2^8) vector multiply
 *
 * Calculates array {C{00}, C{01}, C{02}, ... , C{0f} }, {C{00}, C{10},
 * C{20}, ... , C{f0} } as required by other fast vector multiply
 * functions.
 * @param c     Constant input.
 * @param gftbl Table output.
 */

void gf_vect_mul_init(unsigned char c, unsigned char* gftbl);


/**
 * @brief GF(2^8) vector multiply by constant, runs baseline version.
 *
 * Does a GF(2^8) vector multiply b = Ca where a and b are arrays and C
 * is a single field element in GF(2^8). Can be used for RAID6 rebuild
 * and partial write functions. Function requires pre-calculation of a
 * 32-element constant array based on constant C. gftbl(C) = {C{00},
 * C{01}, C{02}, ... , C{0f} }, {C{00}, C{10}, C{20}, ... , C{f0} }. Len
 * and src must be aligned to 32B.
 *
 * @param len   Length of vector in bytes. Must be aligned to 32B.
 * @param a 	Pointer to 32-byte array of pre-calculated constants based on C.
 * 		only use 2nd element is used.
 * @param src   Pointer to src data array. Must be aligned to 32B.
 * @param dest  Pointer to destination data array. Must be aligned to 32B.
 */

void gf_vect_mul_base(int len, unsigned char *a, unsigned char *src,
			unsigned char *dest);

#ifdef __cplusplus
}
#endif

#endif //_GF_VECT_MUL_H
