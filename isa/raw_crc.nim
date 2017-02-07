## *********************************************************************
##   Copyright(c) 2011-2015 Intel Corporation All rights reserved.
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
##   @file  crc.h
##   @brief CRC functions.
## 

##  Multi-binary functions
## *
##  @brief Generate CRC from the T10 standard, runs appropriate version.
## 
##  This function determines what instruction sets are enabled and
##  selects the appropriate version at runtime.
## 
##  @returns 16 bit CRC
## 

proc crc16_t10dif*(init_crc: uint16; buf: ptr cuchar; len: uint64): uint16 {.cdecl,
    importc: "crc16_t10dif", header: "crc.h".}
  ## !< initial CRC value, 16 bits
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes (64-bit data)
## *
##  @brief Generate CRC from the IEEE standard, runs appropriate version.
## 
##  This function determines what instruction sets are enabled and
##  selects the appropriate version at runtime.
## 
##  @returns 32 bit CRC
## 

proc crc32_ieee*(init_crc: uint32; buf: ptr cuchar; len: uint64): uint32 {.cdecl,
    importc: "crc32_ieee", header: "crc.h".}
  ## !< initial CRC value, 32 bits
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes (64-bit data)
## *
##  @brief ISCSI CRC function, runs appropriate version.
## 
##  This function determines what instruction sets are enabled and
##  selects the appropriate version at runtime.
## 
##  @returns 32 bit CRC
## 

proc crc32_iscsi*(buffer: ptr cuchar; len: cint; init_crc: cuint): cuint {.cdecl,
    importc: "crc32_iscsi", header: "crc.h".}
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes
  ## !< initial CRC value
##  Base functions
## *
##  @brief ISCSI CRC function, baseline version
##  @returns 32 bit CRC
## 

proc crc32_iscsi_base*(buffer: ptr cuchar; len: cint; crc_init: cuint): cuint {.cdecl,
    importc: "crc32_iscsi_base", header: "crc.h".}
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes
  ## !< initial CRC value
## *
##  @brief Generate CRC from the T10 standard, runs baseline version
##  @returns 16 bit CRC
## 

proc crc16_t10dif_base*(seed: uint16; buf: ptr uint8; len: uint64): uint16 {.
    cdecl, importc: "crc16_t10dif_base", header: "crc.h".}
  ## !< initial CRC value, 16 bits
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes (64-bit data)
## *
##  @brief Generate CRC from the IEEE standard, runs baseline version
##  @returns 32 bit CRC
## 

proc crc32_ieee_base*(seed: uint32; buf: ptr uint8; len: uint64): uint32 {.cdecl,
    importc: "crc32_ieee_base", header: "crc.h".}
  ## !< initial CRC value, 32 bits
  ## !< buffer to calculate CRC on
  ## !< buffer length in bytes (64-bit data)
