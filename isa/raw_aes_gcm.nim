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
##   @file aes_gcm.h
##   @brief AES GCM encryption/decryption function prototypes.
## 
##  At build time there is an option to use non-temporal loads and stores
##  selected by defining the compile time option NT_LDST. The use of this option
##  places the following restriction on the gcm encryption functions:
## 
##  - The plaintext and cyphertext buffers must be aligned on a 16 byte boundary.
## 
##  - When using the streaming API, all partial input buffers must be a multiple
##    of 16 bytes long except for the last input buffer.
## 
##  - In-place encryption/decryption is not recommended.
## 
## 
## 
## ; References:
## ;       This code was derived and highly optimized from the code described in paper:
## ;               Vinodh Gopal et. al. Optimized Galois-Counter-Mode Implementation on Intel Architecture Processors. August, 2010
## ;
## ;       For the shift-based reductions used in this code, we used the method described in paper:
## ;               Shay Gueron, Michael E. Kounavis. Intel Carry-Less Multiplication Instruction and its Usage for Computing the GCM Mode. January, 2010.
## ;
## ;
## ;
## ; Assumptions: Support for SSE4.1 or greater, AVX or AVX2
## ;
## ;
## ; iv:
## ;       0                   1                   2                   3
## ;       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
## ;       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## ;       |                             Salt  (From the SA)               |
## ;       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## ;       |                     Initialization Vector                     |
## ;       |         (This is the sequence number from IPSec header)       |
## ;       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## ;       |                              0x1                              |
## ;       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
## ;
## ; TLen:
## ;       from the definition of the spec, TLen can only be 8, 12 or 16 bytes.
## ;
## 

##  Authenticated Tag Length in bytes. Valid values are 16 (most likely), 12 or 8.

const
  MAX_TAG_LEN* = (16)

## 
##  IV data is limited to 16 bytes. The last DWORD (4 bytes) must be 0x1
## 

const
  GCM_IV_LEN* = (16)
  GCM_IV_DATA_LEN* = (12)

## #define GCM_IV_END_MARK {0x00, 0x00, 0x00, 0x01};

const
  GCM_IV_END_START* = (12)
  LONGEST_TESTED_AAD_LENGTH* = (2 * 1024)

##  Key lengths of 128 and 256 supported

const
  GCM_128_KEY_LEN* = (16)
  GCM_256_KEY_LEN* = (32)
  GCM_BLOCK_LEN* = 16
  GCM_ENC_KEY_LEN* = 16
  GCM_KEY_SETS* = (15)          ## exp key + 14 exp round keys

## * @brief holds intermediate key data needed to improve performance
## 
##  gcm_data hold internal key information used by gcm128 and gcm256.
## 

type
  gcm_data* {.importc: "gcm_data", header: "aes_gcm.h".} = object
    expanded_keys* {.importc: "expanded_keys".}: array[
        GCM_ENC_KEY_LEN * GCM_KEY_SETS, uint8]
    shifted_hkey_1* {.importc: "shifted_hkey_1".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey <<1 mod poly here
    shifted_hkey_2* {.importc: "shifted_hkey_2".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^2 <<1 mod poly here
    shifted_hkey_3* {.importc: "shifted_hkey_3".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^3 <<1 mod poly here
    shifted_hkey_4* {.importc: "shifted_hkey_4".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^4 <<1 mod poly here
    shifted_hkey_5* {.importc: "shifted_hkey_5".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^5 <<1 mod poly here
    shifted_hkey_6* {.importc: "shifted_hkey_6".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^6 <<1 mod poly here
    shifted_hkey_7* {.importc: "shifted_hkey_7".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^7 <<1 mod poly here
    shifted_hkey_8* {.importc: "shifted_hkey_8".}: array[GCM_ENC_KEY_LEN, uint8] ##  store HashKey^8 <<1 mod poly here
    shifted_hkey_1_k* {.importc: "shifted_hkey_1_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_2_k* {.importc: "shifted_hkey_2_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^2 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_3_k* {.importc: "shifted_hkey_3_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^3 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_4_k* {.importc: "shifted_hkey_4_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^4 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_5_k* {.importc: "shifted_hkey_5_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^5 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_6_k* {.importc: "shifted_hkey_6_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^6 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_7_k* {.importc: "shifted_hkey_7_k".}: array[GCM_ENC_KEY_LEN,
        uint8]              ##  store XOR of High 64 bits and Low 64 bits of  HashKey^7 <<1 mod poly here (for Karatsuba purposes)
    shifted_hkey_8_k* {.importc: "shifted_hkey_8_k".}: array[GCM_ENC_KEY_LEN,
        uint8] ##  store XOR of High 64 bits and Low 64 bits of  HashKey^8 <<1 mod poly here (for Karatsuba purposes)
                ##  init, update and finalize context data
    aad_hash* {.importc: "aad_hash".}: array[GCM_BLOCK_LEN, uint8]
    aad_length* {.importc: "aad_length".}: uint64
    in_length* {.importc: "in_length".}: uint64
    partial_block_enc_key* {.importc: "partial_block_enc_key".}: array[
        GCM_BLOCK_LEN, uint8]
    orig_IV* {.importc: "orig_IV".}: array[GCM_BLOCK_LEN, uint8]
    current_counter* {.importc: "current_counter".}: array[GCM_BLOCK_LEN, uint8]
    partial_block_length* {.importc: "partial_block_length".}: uint64


## *
##  @brief GCM-AES Encryption using 128 bit keys
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_enc*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                      `in`: ptr uint8; plaintext_len: uint64; iv: ptr uint8;
                      aad: ptr uint8; aad_len: uint64; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm128_enc", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialization Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes (must be a multiple of 4 bytes). Valid values are 16 (most likely), 12 or 8.
## *
##  @brief GCM-AES Decryption  using 128 bit keys
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_dec*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                      `in`: ptr uint8; plaintext_len: uint64; iv: ptr uint8;
                      aad: ptr uint8; aad_len: uint64; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm128_dec", header: "aes_gcm.h".}
  ## !< Plaintext output. Decrypt in-place is allowed.
  ## !< Ciphertext input
  ## !< Length of data in Bytes for encryption.
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialisation Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes (must be a multiple of 4 bytes). Valid values are 16 (most likely), 12 or 8.
## *
##  @brief start a AES-128-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_init*(my_ctx_data: ptr gcm_data; iv: ptr uint8; aad: ptr uint8; aad_len: uint64) {.
    cdecl, importc: "aesni_gcm128_init", header: "aes_gcm.h".}
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialization Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
## *
##  @brief encrypt a block of a AES-128-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_enc_update*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                             `in`: ptr uint8; plaintext_len: uint64) {.cdecl,
    importc: "aesni_gcm128_enc_update", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
## *
##  @brief decrypt a block of a AES-128-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_dec_update*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                             `in`: ptr uint8; plaintext_len: uint64) {.cdecl,
    importc: "aesni_gcm128_dec_update", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
## *
##  @brief End encryption of a AES-128-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_enc_finalize*(my_ctx_data: ptr gcm_data; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm128_enc_finalize", header: "aes_gcm.h".}
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes. Valid values are 16 (most likely), 12 or 8.
## *
##  @brief End decryption of a AES-128-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm128_dec_finalize*(my_ctx_data: ptr gcm_data; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm128_dec_finalize", header: "aes_gcm.h".}
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes. Valid values are 16 (most likely), 12 or 8.
## *
##  @brief pre-processes key data
## 
##  Prefills the gcm data with key values for each round and the initial sub hash key for tag encoding
## 

proc aesni_gcm128_pre*(key: ptr uint8; gdata: ptr gcm_data) {.cdecl,
    importc: "aesni_gcm128_pre", header: "aes_gcm.h".}
## *
##  @brief GCM-AES Encryption using 256 bit keys
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_enc*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                      `in`: ptr uint8; plaintext_len: uint64; iv: ptr uint8;
                      aad: ptr uint8; aad_len: uint64; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm256_enc", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialization Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes (must be a multiple of 4 bytes). Valid values are 16 (most likely), 12 or 8.
## *
##  @brief GCM-AES Decryption using 256 bit keys
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_dec*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                      `in`: ptr uint8; plaintext_len: uint64; iv: ptr uint8;
                      aad: ptr uint8; aad_len: uint64; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm256_dec", header: "aes_gcm.h".}
  ## !< Plaintext output. Decrypt in-place is allowed.
  ## !< Ciphertext input
  ## !< Length of data in Bytes for encryption.
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialisation Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes (must be a multiple of 4 bytes). Valid values are 16 (most likely), 12 or 8.
## *
##  @brief start a AES-256-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_init*(my_ctx_data: ptr gcm_data; iv: ptr uint8; aad: ptr uint8; aad_len: uint64) {.
    cdecl, importc: "aesni_gcm256_init", header: "aes_gcm.h".}
  ## !< Pre-counter block j0: 4 byte salt (from Security Association) concatenated with 8 byte Initialization Vector (from IPSec ESP Payload) concatenated with 0x00000001. 16-byte pointer.
  ## !< Additional Authentication Data (AAD).
  ## !< Length of AAD.
## *
##  @brief encrypt a block of a AES-256-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_enc_update*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                             `in`: ptr uint8; plaintext_len: uint64) {.cdecl,
    importc: "aesni_gcm256_enc_update", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
## *
##  @brief decrypt a block of a AES-256-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_dec_update*(my_ctx_data: ptr gcm_data; `out`: ptr uint8;
                             `in`: ptr uint8; plaintext_len: uint64) {.cdecl,
    importc: "aesni_gcm256_dec_update", header: "aes_gcm.h".}
  ## !< Ciphertext output. Encrypt in-place is allowed.
  ## !< Plaintext input
  ## !< Length of data in Bytes for encryption.
## *
##  @brief End encryption of a AES-256-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_enc_finalize*(my_ctx_data: ptr gcm_data; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm256_enc_finalize", header: "aes_gcm.h".}
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes. Valid values are 16 (most likely), 12 or 8.
## *
##  @brief End decryption of a AES-256-GCM Encryption message
## 
##  @requires SSE4.1 and AESNI
## 
## 

proc aesni_gcm256_dec_finalize*(my_ctx_data: ptr gcm_data; auth_tag: ptr uint8; auth_tag_len: uint64) {.
    cdecl, importc: "aesni_gcm256_dec_finalize", header: "aes_gcm.h".}
  ## !< Authenticated Tag output.
  ## !< Authenticated Tag Length in bytes. Valid values are 16 (most likely), 12 or 8.
## *
##  @brief pre-processes key data
## 
##  Prefills the gcm data with key values for each round and the initial sub hash key for tag encoding
## 

proc aesni_gcm256_pre*(key: ptr uint8; gdata: ptr gcm_data) {.cdecl,
    importc: "aesni_gcm256_pre", header: "aes_gcm.h".}