#ifndef _AES_XTS_H
#define _AES_XTS_H

#include <stdint.h>

#ifdef C2NIM
#  dynlib libname
#  cdecl
#  prefix isa_
#  if defined(windows)
#    define libname "libisal_crypto.dll"
#  elif defined(macosx)
#    define libname "libisal_crypto.dylib"
#  else
#    define libname "libisal_crypto.so"
#  endif
#mangle uint16_t uint16
#mangle uint64_t uint64
#mangle uint32_t uint32
#mangle uint8_t  uint8


#mangle int64_t int64
#endif

#ifdef __cplusplus
extern "C" {
#endif

/** @brief XTS-AES-128 Encryption
 * @requires AES-NI
 */

void XTS_AES_128_enc(
	uint8_t *k2,	//!<  key used for tweaking, 16 bytes
	uint8_t *k1,	//!<  key used for encryption of tweaked plaintext, 16 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *pt,	//!<  plaintext sector input data
	uint8_t *ct	//!<  ciphertext sector output data
	);

/** @brief XTS-AES-128 Encryption with pre-expanded keys
 * @requires AES-NI
 */

void XTS_AES_128_enc_expanded_key(
	uint8_t *k2,	//!<  expanded key used for tweaking, 16*11 bytes
	uint8_t *k1,	//!<  expanded key used for encryption of tweaked plaintext, 16*11 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *pt,	//!<  plaintext sector input data
	uint8_t *ct	//!<  ciphertext sector output data
	);

/** @brief XTS-AES-128 Decryption
 * @requires AES-NI
 */

void XTS_AES_128_dec(
	uint8_t *k2,	//!<  key used for tweaking, 16 bytes
	uint8_t *k1,	//!<  key used for decryption of tweaked ciphertext, 16 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *ct,	//!<  ciphertext sector input data
	uint8_t *pt	//!<  plaintext sector output data
	);

/** @brief XTS-AES-128 Decryption with pre-expanded keys
 * @requires AES-NI
 */

void XTS_AES_128_dec_expanded_key(
	uint8_t *k2,	//!<  expanded key used for tweaking, 16*11 bytes - encryption key is used
	uint8_t *k1,	//!<  expanded decryption key used for decryption of tweaked ciphertext, 16*11 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *ct,	//!<  ciphertext sector input data
	uint8_t *pt	//!<  plaintext sector output data
	);

/** @brief XTS-AES-256 Encryption
 * @requires AES-NI
 */

void XTS_AES_256_enc(
	uint8_t *k2,	//!<  key used for tweaking, 16*2 bytes
	uint8_t *k1,	//!<  key used for encryption of tweaked plaintext, 16*2 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *pt,	//!<  plaintext sector input data
	uint8_t *ct	//!<  ciphertext sector output data
	);

/** @brief XTS-AES-256 Encryption with pre-expanded keys
 * @requires AES-NI
 */

void XTS_AES_256_enc_expanded_key(
	uint8_t *k2,	//!<  expanded key used for tweaking, 16*15 bytes
	uint8_t *k1,	//!<  expanded key used for encryption of tweaked plaintext, 16*15 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *pt,	//!<  plaintext sector input data
	uint8_t *ct	//!<  ciphertext sector output data
	);

/** @brief XTS-AES-256 Decryption
 * @requires AES-NI
 */

void XTS_AES_256_dec(
	uint8_t *k2,	//!<  key used for tweaking, 16*2 bytes
	uint8_t *k1,	//!<  key used for  decryption of tweaked ciphertext, 16*2 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *ct,	//!<  ciphertext sector input data
	uint8_t *pt	//!<  plaintext sector output data
	);

/** @brief XTS-AES-256 Decryption with pre-expanded keys
 * @requires AES-NI
 */

void XTS_AES_256_dec_expanded_key(
	uint8_t *k2,	//!<  expanded key used for tweaking, 16*15 bytes - encryption key is used
	uint8_t *k1,	//!<  expanded decryption key used for decryption of tweaked ciphertext, 16*15 bytes
	uint8_t *TW_initial,	//!<  initial tweak value, 16 bytes
	uint64_t N,	//!<  sector size, in bytes
	const uint8_t *ct,	//!<  ciphertext sector input data
	uint8_t *pt	//!<  plaintext sector output data
	);

#ifdef __cplusplus
}
#endif

#endif //_AES_XTS_H
