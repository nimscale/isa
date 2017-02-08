## *********************************************************************
##   Copyright(c) 2011-2016 Intel Corporation All rights reserved.
## 
##   Redistribution and use in source and binary forms, with or without
##   modification, are permitted provided that the following conditions 
##   are met:
##  Redistributions of source code must retain the above copyright
##       notice, this list of conditions and the following disclaimer.
##  Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in
##       the documentation and/or other materials provided with the
##       distribution.
##  Neither the name of Intel Corporation nor the names of its
##       contributors may be used to endorse or promote products derived
##       from this software without specific prior written permission.
## 
##   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
##   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
##   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## ********************************************************************
## *
##   @file aes_cbc.h
##   @brief AES CBC encryption/decryption function prototypes.
## 
## ; References:
## 

type
  cbc_key_size* {.size: sizeof(cint).} = enum
    CBC_128_BITS = 16, CBC_192_BITS = 24, CBC_256_BITS = 32


const
  CBC_ROUND_KEY_LEN* = (16)
  CBC_128_KEY_ROUNDS* = (10 + 1)  ## expanded key holds 10 key rounds plus original key
  CBC_192_KEY_ROUNDS* = (12 + 1)  ## expanded key holds 12 key rounds plus original key
  CBC_256_KEY_ROUNDS* = (14 + 1)  ## expanded key holds 14 key rounds plus original key
  CBC_MAX_KEYS_SIZE* = (CBC_ROUND_KEY_LEN * CBC_256_KEY_ROUNDS)
  CBC_IV_DATA_LEN* = (16)

## * @brief holds intermediate key data used in encryption/decryption
## 
## 

type
  cbc_key_data* {.importc: "cbc_key_data", header: "aes_cbc.h".} = object
    enc_keys* {.importc: "enc_keys".}: array[CBC_MAX_KEYS_SIZE, uint8] ##  must be 16 byte aligned
    dec_keys* {.importc: "dec_keys".}: array[CBC_MAX_KEYS_SIZE, uint8]


## * @brief CBC-AES key pre-computation done once for a key
## 
##  @requires SSE4.1 and AESNI
## 
##  arg 1: in:   pointer to key
##  arg 2: OUT:  pointer to a key expanded data
## 

proc aes_cbc_precomp*(key: ptr uint8; key_size: cint; keys_blk: ptr cbc_key_data): cint {.
    cdecl, importc: "aes_cbc_precomp", header: "aes_cbc.h".}
## * @brief CBC-AES 128 bit key Decryption
## 
##  @requires SSE4.1 and AESNI
## 
##  arg 1: in:   pointer to input (cipher text)
##  arg 2: IV:   pointer to IV, Must be 16 bytes aligned to a 16 byte boundary
##  arg 3: keys: pointer to keys, Must be on a 16 byte boundary and length of key size * key rounds
##  arg 4: OUT:  pointer to output (plain text ... in-place allowed)
##  arg 5: len_bytes:  length in bytes (multiple of 16)
## 

proc aes_cbc_dec_128*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64) {.cdecl, importc: "aes_cbc_dec_128",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or dec_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
## * @brief CBC-AES 192 bit key Decryption
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aes_cbc_dec_192*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64) {.cdecl, importc: "aes_cbc_dec_192",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or dec_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
## * @brief CBC-AES 256 bit key Decryption
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aes_cbc_dec_256*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64) {.cdecl, importc: "aes_cbc_dec_256",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or dec_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
## * @brief CBC-AES 128 bit key Encryption
## 
##  @requires SSE4.1 and AESNI
## 
##  arg 1: in:   pointer to input (plain text)
##  arg 2: IV:   pointer to IV, Must be 16 bytes aligned to a 16 byte boundary
##  arg 3: keys: pointer to keys, Must be on a 16 byte boundary and length of key size * key rounds
##  arg 4: OUT:  pointer to output (cipher text ... in-place allowed)
##  arg 5: len_bytes:  length in bytes (multiple of 16)
## 

proc aes_cbc_enc_128*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64): cint {.cdecl, importc: "aes_cbc_enc_128",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or enc_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
## * @brief CBC-AES 192 bit key Encryption
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aes_cbc_enc_192*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64): cint {.cdecl, importc: "aes_cbc_enc_192",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or enc_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
## * @brief CBC-AES 256 bit key Encryption
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aes_cbc_enc_256*(`in`: pointer; IV: ptr uint8; keys: ptr uint8; `out`: pointer;
                     len_bytes: uint64): cint {.cdecl, importc: "aes_cbc_enc_256",
    header: "aes_cbc.h".}
  ## !< Must be 16 bytes aligned to a 16 byte boundary
  ## !< Must be on a 16 byte boundary and length of key size * key rounds or enc_keys of cbc_key_data
## !< Must be a multiple of 16 bytes
