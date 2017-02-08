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
##  @file igzip_lib.h
## 
##  @brief This file defines the igzip compression and decompression interface, a
##  high performance deflate compression interface for storage applications.
## 
##  Deflate is a widely used compression standard that can be used standalone, it
##  also forms the basis of gzip and zlib compression formats. Igzip supports the
##  following flush features:
## 
##  - No Flush: The default method where no special flush is performed.
## 
##  - Sync flush: whereby isal_deflate() finishes the current deflate block at
##    the end of each input buffer. The deflate block is byte aligned by
##    appending an empty stored block.
## 
##  - Full flush: whereby isal_deflate() finishes and aligns the deflate block as
##    in sync flush but also ensures that subsequent block's history does not
##    look back beyond this point and new blocks are fully independent.
## 
##  Igzip contians some behaviour configurable at compile time. These
##  configureable options are:
## 
##  - IGZIP_HIST_SIZE - Defines the window size. The default value is 32K (note K
##    represents 1024), but 8K is also supported. Powers of 2 which are at most
##    32K may also work.
## 
##  - LONGER_HUFFTABLES - Defines whether to use a larger hufftables structure
##    which may increase performance with smaller IGZIP_HIST_SIZE values. By
##    default this optoin is not defined. This define sets IGZIP_HIST_SIZE to be
##    8 if IGZIP_HIST_SIZE > 8K.
## 
##    As an example, to compile gzip with an 8K window size, in a terminal run
##    @verbatim gmake D="-D IGZIP_HIST_SIZE=8*1024" @endverbatim on Linux and
##    FreeBSD, or with @verbatim nmake -f Makefile.nmake D="-D
##    IGZIP_HIST_SIZE=8*1024" @endverbatim on Windows.
## 
## 

## ****************************************************************************
##  Deflate Compression Standard Defines
## ****************************************************************************

const
  IGZIP_K* = 1024
  ISAL_DEF_MAX_HDR_SIZE* = 328
  ISAL_DEF_MAX_CODE_LEN* = 15
  ISAL_DEF_HIST_SIZE* = (32 * IGZIP_K)
  ISAL_DEF_LIT_SYMBOLS* = 257
  ISAL_DEF_LEN_SYMBOLS* = 29
  ISAL_DEF_DIST_SYMBOLS* = 30
  ISAL_DEF_LIT_LEN_SYMBOLS* = (ISAL_DEF_LIT_SYMBOLS + ISAL_DEF_LEN_SYMBOLS)
  ISAL_LOOK_AHEAD* = (18 * 16)    ##  Max repeat length, rounded up to 32 byte boundary
  IGZIP_HIST_SIZE = 1024 * 32

## ****************************************************************************
##  Deflate Implemenation Specific Defines
## ****************************************************************************
##  Note IGZIP_HIST_SIZE must be a power of two

when (IGZIP_HIST_SIZE > ISAL_DEF_HIST_SIZE):
  const
    IGZIP_HIST_SIZE* = ISAL_DEF_HIST_SIZE
when defined(LONGER_HUFFTABLE):
  when (IGZIP_HIST_SIZE > 8 * IGZIP_K):
    const
      IGZIP_HIST_SIZE* = (8 * IGZIP_K)
const
  ISAL_LIMIT_HASH_UPDATE* = true

when defined(LONGER_HUFFTABLE):
  const
    IGZIP_DIST_TABLE_SIZE* = 8 * 1024
  ##  DECODE_OFFSET is dist code index corresponding to DIST_TABLE_SIZE + 1
  const
    IGZIP_DECODE_OFFSET* = 26
else:
  const
    IGZIP_DIST_TABLE_SIZE* = 2
  ##  DECODE_OFFSET is dist code index corresponding to DIST_TABLE_SIZE + 1
  const
    IGZIP_DECODE_OFFSET* = 0
const
  IGZIP_LEN_TABLE_SIZE* = 256

const
  IGZIP_LIT_TABLE_SIZE* = ISAL_DEF_LIT_SYMBOLS

const
  IGZIP_HUFFTABLE_CUSTOM* = 0
  IGZIP_HUFFTABLE_DEFAULT* = 1
  IGZIP_HUFFTABLE_STATIC* = 2

##  Flush Flags

const
  NO_FLUSH* = 0
  SYNC_FLUSH* = 1
  FULL_FLUSH* = 2
  FINISH_FLUSH* = 0

##  Gzip Flags

const
  IGZIP_DEFLATE* = 0
  IGZIP_GZIP* = 1
  IGZIP_GZIP_NO_HDR* = 2

##  Compression Return values

const
  COMP_OK* = 0
  INVALID_FLUSH* = - 7
  INVALID_PARAM* = - 8
  STATELESS_OVERFLOW* = - 1
  ISAL_INVALID_OPERATION* = - 9

## *
##   @enum isal_zstate_state
##   @brief Compression State please note ZSTATE_TRL only applies for GZIP compression
## 
##  When the state is set to ZSTATE_NEW_HDR or TMP_ZSTATE_NEW_HEADER, the
##  hufftable being used for compression may be swapped
## 

type
  isal_zstate_state* {.size: sizeof(cint).} = enum
    ZSTATE_NEW_HDR,           ## !< Header to be written
    ZSTATE_HDR,               ## !< Header state
    ZSTATE_BODY,              ## !< Body state
    ZSTATE_FLUSH_READ_BUFFER, ## !< Flush buffer
    ZSTATE_SYNC_FLUSH,        ## !< Write sync flush block
    ZSTATE_FLUSH_WRITE_BUFFER, ## !< Flush bitbuf
    ZSTATE_TRL,               ## !< Trailer state
    ZSTATE_END,               ## !< End state
    ZSTATE_TMP_NEW_HDR,       ## !< Temporary Header to be written
    ZSTATE_TMP_HDR,           ## !< Temporary Header state
    ZSTATE_TMP_BODY,          ## !< Temporary Body state
    ZSTATE_TMP_FLUSH_READ_BUFFER, ## !< Flush buffer
    ZSTATE_TMP_SYNC_FLUSH,    ## !< Write sync flush block
    ZSTATE_TMP_FLUSH_WRITE_BUFFER, ## !< Flush bitbuf
    ZSTATE_TMP_TRL,           ## !< Temporary Trailer state
    ZSTATE_TMP_END            ## !< Temporary End state

type
  isal_huff_histogram* {.importc: "struct isal_huff_histogram", header: "igzip_lib.h".} = object
  isal_hufftables* {.importc: "struct isal_hufftables", header: "igzip_lib.h".} = object
  isal_zstate* {.importc: "struct isal_zstate", header: "igzip_lib.h".} = object
    state*: isal_zstate_state

  isal_zstream* {.importc: "struct isal_zstream", header: "igzip_lib.h".} = object
    next_in*: ptr uint8
    avail_in*: uint32
    total_in*: uint32

    next_out*: ptr uint8
    avail_out*: uint32
    total_out*: uint32

    end_of_stream*: uint32
    flush*: uint32
    gzip_flag*: uint32

    internal_state*: isal_zstate

  inflate_state* {.importc: "struct inflate_state", header: "igzip_lib.h".} = object
    next_in*: ptr uint8
    avail_in*: uint32

    next_out*: ptr uint8
    avail_out*: uint32

    block_state*: isal_block_state

  isal_block_state* {.size: sizeof(cint).} = enum
    ISAL_BLOCK_NEW_HDR,
    ISAL_BLOCK_HDR,
    ISAL_BLOCK_TYPE0,
    ISAL_BLOCK_CODED,
    ISAL_BLOCK_INPUT_DONE,
    ISAL_BLOCK_FINISH

## ****************************************************************************
##  Compression functions
## ****************************************************************************
## *
##  @brief Updates histograms to include the symbols found in the input
##  stream. Since this function only updates the histograms, it can be called on
##  multiple streams to get a histogram better representing the desired data
##  set. When first using histogram it must be initialized by zeroing the
##  structure.
## 
##  @param in_stream: Input stream of data.
##  @param length: The length of start_stream.
##  @param histogram: The returned histogram of lit/len/dist symbols.
## 

proc isal_update_histogram*(in_stream: ptr uint8; length: cint;
                           histogram: ptr isal_huff_histogram) {.cdecl,
    importc: "isal_update_histogram", header: "igzip_lib.h".}
## *
##  @brief Creates a custom huffman code for the given histograms in which
##   every literal and repeat length is assigned a code and all possible lookback
##   distances are assigned a code.
## 
##  @param hufftables: the output structure containing the huffman code
##  @param histogram: histogram containing frequency of literal symbols,
##         repeat lengths and lookback distances
##  @returns Returns a non zero value if an invalid huffman code was created.
## 

proc isal_create_hufftables*(hufftables: ptr isal_hufftables;
                            histogram: ptr isal_huff_histogram): cint {.cdecl,
    importc: "isal_create_hufftables", header: "igzip_lib.h".}
## *
##  @brief Creates a custom huffman code for the given histograms like
##  isal_create_hufftables() except literals with 0 frequency in the histogram
##  are not assigned a code
## 
##  @param hufftables: the output structure containing the huffman code
##  @param histogram: histogram containing frequency of literal symbols,
##         repeat lengths and lookback distances
##  @returns Returns a non zero value if an invalid huffman code was created.
## 

proc isal_create_hufftables_subset*(hufftables: ptr isal_hufftables;
                                   histogram: ptr isal_huff_histogram): cint {.
    cdecl, importc: "isal_create_hufftables_subset", header: "igzip_lib.h".}
## *
##  @brief Initialize compression stream data structure
## 
##  @param stream Structure holding state information on the compression streams.
##  @returns none
## 

proc isal_deflate_init*(stream: ptr isal_zstream) {.cdecl,
    importc: "isal_deflate_init", header: "igzip_lib.h".}
## *
##  @brief Set stream to use a new Huffman code
## 
##  Sets the Huffman code to be used in compression before compression start or
##  after the sucessful completion of a SYNC_FLUSH or FULL_FLUSH. If type has
##  value IGZIP_HUFFTABLE_DEFAULT, the stream is set to use the default Huffman
##  code. If type has value IGZIP_HUFFTABLE_STATIC, the stream is set to use the
##  deflate standard static Huffman code, or if type has value
##  IGZIP_HUFFTABLE_CUSTOM, the stream is set to sue the isal_hufftables
##  structure input to isal_deflate_set_hufftables.
## 
##  @param stream: Structure holding state information on the compression stream.
##  @param hufftables: new huffman code to use if type is set to
##  IGZIP_HUFFTABLE_CUSTOM.
##  @param type: Flag specifying what hufftable to use.
## 
##  @returns Returns INVALID_OPERATION if the stream was unmodified. This may be
##  due to the stream being in a state where changing the huffman code is not
##  allowed or an invalid input is provided.
## 

proc isal_deflate_set_hufftables*(stream: ptr isal_zstream;
                                 hufftables: ptr isal_hufftables; `type`: cint): cint {.
    cdecl, importc: "isal_deflate_set_hufftables", header: "igzip_lib.h".}
## *
##  @brief Initialize compression stream data structure
## 
##  @param stream Structure holding state information on the compression streams.
##  @returns none
## 

proc isal_deflate_stateless_init*(stream: ptr isal_zstream) {.cdecl,
    importc: "isal_deflate_stateless_init", header: "igzip_lib.h".}
## *
##  @brief Fast data (deflate) compression for storage applications.
## 
##  On entry to isal_deflate(), next_in points to an input buffer and avail_in
##  indicates the length of that buffer. Similarly next_out points to an empty
##  output buffer and avail_out indicates the size of that buffer.
## 
##  The fields total_in and total_out start at 0 and are updated by
##  isal_deflate(). These reflect the total number of bytes read or written so far.
## 
##  The call to isal_deflate() will take data from the input buffer (updating
##  next_in, avail_in and write a compressed stream to the output buffer
##  (updating next_out and avail_out). The function returns when either the input
##  buffer is empty or the output buffer is full.
## 
##  When the last input buffer is passed in, signaled by setting the
##  end_of_stream, the routine will complete compression at the end of the input
##  buffer, as long as the output buffer is big enough.
## 
##  The equivalent of the zlib FLUSH_SYNC operation is currently supported.
##  Flush types can be NO_FLUSH, SYNC_FLUSH or FULL_FLUSH. Default flush type is
##  NO_FLUSH. A SYNC_ OR FULL_ flush will byte align the deflate block by
##  appending an empty stored block.  Additionally FULL_FLUSH will ensure
##  look back history does not include previous blocks so new blocks are fully
##  independent. Switching between flush types is supported.
## 
##  If the gzip_flag is set to IGZIP_GZIP, a generic gzip header and the gzip
##  trailer are written around the deflate compressed data. If gzip_flag is set
##  to IGZIP_GZIP_NO_HDR, then only the gzip trailer is written.
## 
##  @param  stream Structure holding state information on the compression streams.
##  @return COMP_OK (if everything is ok),
##          INVALID_FLUSH (if an invalid FLUSH is selected),
## 

proc isal_deflate*(stream: ptr isal_zstream): cint {.cdecl, importc: "isal_deflate",
    header: "igzip_lib.h".}
## *
##  @brief Fast data (deflate) stateless compression for storage applications.
## 
##  Stateless (one shot) compression routine with a similar interface to
##  isal_deflate() but operates on entire input buffer at one time. Parameter
##  avail_out must be large enough to fit the entire compressed output. Max
##  expansion is limited to the input size plus the header size of a stored/raw
##  block.
## 
##  For stateless the flush types NO_FLUSH and FULL_FLUSH are supported.
##  FULL_FLUSH will byte align the output deflate block so additional blocks can
##  be easily appended.
## 
##  If the gzip_flag is set to IGZIP_GZIP, a generic gzip header and the gzip
##  trailer are written around the deflate compressed data. If gzip_flag is set
##  to IGZIP_GZIP_NO_HDR, then only the gzip trailer is written.
## 
##  @param  stream Structure holding state information on the compression streams.
##  @return COMP_OK (if everything is ok),
##          STATELESS_OVERFLOW (if output buffer will not fit output).
## 

proc isal_deflate_stateless*(stream: ptr isal_zstream): cint {.cdecl,
    importc: "isal_deflate_stateless", header: "igzip_lib.h".}
## ****************************************************************************
##  Inflate functions
## ****************************************************************************
## *
##  @brief Initialize decompression state data structure
## 
##  @param state Structure holding state information on the compression streams.
##  @returns none
## 

proc isal_inflate_init*(state: ptr inflate_state) {.cdecl,
    importc: "isal_inflate_init", header: "igzip_lib.h".}
## *
##  @brief Fast data (deflate) decompression for storage applications.
## 
##  On entry to isal_inflate(), next_in points to an input buffer and avail_in
##  indicates the length of that buffer. Similarly next_out points to an empty
##  output buffer and avail_out indicates the size of that buffer.
## 
##  The field total_out starts at 0 and is updated by isal_inflate(). This
##  reflects the total number of bytes written so far.
## 
##  The call to isal_inflate() will take data from the input buffer (updating
##  next_in, avail_in and write a decompressed stream to the output buffer
##  (updating next_out and avail_out). The function returns when the input buffer
##  is empty, the output buffer is full or invalid data is found. The current
##  state of the decompression on exit can be read from state->block-state. If
##  the crc_flag is set, the gzip crc of the output is stored in state->crc.
## 
##  @param  state Structure holding state information on the compression streams.
##  @return ISAL_DECOMP_OK (if everything is ok),
##          ISAL_END_INPUT (if all input was decompressed),
##          ISAL_OUT_OVERFLOW (if output buffer ran out of space),
##          ISAL_INVALID_BLOCK,
##          ISAL_INVALID_SYMBOL,
##          ISAL_INVALID_LOOKBACK.
## 

proc isal_inflate*(state: ptr inflate_state): cint {.cdecl, importc: "isal_inflate",
    header: "igzip_lib.h".}
## *
##  @brief Fast data (deflate) stateless decompression for storage applications.
## 
##  Stateless (one shot) decompression routine with a similar interface to
##  isal_inflate() but operates on entire input buffer at one time. Parameter
##  avail_out must be large enough to fit the entire decompressed output.
## 
##  @param  state Structure holding state information on the compression streams.
##  @return ISAL_DECOMP_OK (if everything is ok),
##          ISAL_END_INPUT (if all input was decompressed),
##          ISAL_OUT_OVERFLOW (if output buffer ran out of space),
##          ISAL_INVALID_BLOCK,
##          ISAL_INVALID_SYMBOL,
##          ISAL_INVALID_LOOKBACK.
## 

proc isal_inflate_stateless*(state: ptr inflate_state): cint {.cdecl,
    importc: "isal_inflate_stateless", header: "igzip_lib.h".}
