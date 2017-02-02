import isa, random, parseopt, strutils, os

################Compress
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

## ****************************************************************************
##  Deflate Implemenation Specific Defines
## ****************************************************************************
##  Note IGZIP_HIST_SIZE must be a power of two

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
  IGZIP_HASH_SIZE = (8 * IGZIP_K)
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


type
  isal_zstate_state* = enum
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
   BitBuf2* {.importc: "struct BitBuf2", header: "<isa-l/igzip_lib.h>".} = object
    m_bits*: uint64          ## !< bits in the bit buffer
    m_bit_count*: uint32     ## !< number of valid bits in the bit buffer
    m_out_buf*: ptr uint8     ## !< current index of buffer to write to
    m_out_end*: ptr uint8     ## !< end of buffer to write to
    m_out_start*: ptr uint8   ## !< start of buffer to write to

type
  isal_hufftables*{.importc: "struct isal_hufftables", header: "<isa-l/igzip_lib.h>".} = object
  isal_zstate* {.importc: "struct isal_zstate", header: "<isa-l/igzip_lib.h>".} = object
    b_bytes_valid*: uint32  ## !< number of bytes of valid data in buffer
    b_bytes_processed*: uint32 ## !< keeps track of the number of bytes processed in isal_zstate.buffer
    file_start*: ptr uint8    ## !< pointer to where file would logically start
    crc*: uint32             ## !< Current crc
    bitbuf*: BitBuf2           ## !< Bit Buffer
    state*: isal_zstate_state  ## !< Current state in processing the data stream
    count*: uint32          ## !< used for partial header/trailer writes
    tmp_out_buff*: array[16, uint8] ## !< temporary array
    tmp_out_start*: uint32   ## !< temporary variable
    tmp_out_end*: uint32     ## !< temporary variable
    has_eob*: uint32         ## !< keeps track of eob on the last deflate block
    has_eob_hdr*: uint32     ## !< keeps track of eob hdr (with BFINAL set)
    has_hist*: uint32 ## !< flag to track if there is match history
    buffer:array[2 * IGZIP_HIST_SIZE + ISAL_LOOK_AHEAD, uint8] ## 	DECLARE_ALIGNED(uint8_t buffer[2 * IGZIP_HIST_SIZE + ISAL_LOOK_AHEAD], 32);	//!< Internal buffer
    head:array[IGZIP_HASH_SIZE, uint16] ## 	DECLARE_ALIGNED(uint16_t head[IGZIP_HASH_SIZE], 16);	//!< Hash array


  isal_zstream* {.importc: "struct isal_zstream",
              header: "<isa-l/igzip_lib.h>".} = object
    next_in*: ptr uint8       ## !< Next input byte
    avail_in*: uint32        ## !< number of bytes available at next_in
    total_in*: uint32        ## !< total number of bytes read so far
    next_out*: ptr uint8      ## !< Next output byte
    avail_out*: uint32       ## !< number of bytes available at next_out
    total_out*: uint32       ## !< total number of bytes written so far
    hufftables*: ptr isal_hufftables ## !< Huffman encoding used when compressing
    end_of_stream*: uint32   ## !< non-zero if this is the last input buffer
    flush*: uint32           ## !< Flush type can be NO_FLUSH, SYNC_FLUSH or FULL_FLUSH
    gzip_flag*: uint32       ## !< Indicate if gzip compression is to be performed
    internal_state*: isal_zstate ## !< Internal state for this stream


const
  Version = "1.0.0" # keep in sync with Nimble version. D'oh!
  Usage = """
  Usage: compress infile
"""



var stream: isal_zstream


proc isal_deflate_init*(stream: ptr isal_zstream) : void {.
    cdecl, importc : "isal_deflate_init" , dynlib: isalibname.}
proc isal_deflate*(stream: ptr isal_zstream) : void {.
    cdecl, importc : "isal_deflate" , dynlib: isalibname.}

proc nimmain*(infile:string): void =
  var
    inbuf: array[8192, uint8]
    outbuf: array[8192, uint8]

  var flen:BiggestInt
  flen = 0
  var tflen: BiggestInt
  tflen = getFileSize(infile)
  echo "tflen = ", tflen
  var wlen = 0

  var ifile = open(infile)
  var outfile = infile

  outfile.add(".igzip")
  var ofile = open(outfile, fmWrite)

  isal_deflate_init(addr(stream))
  stream.end_of_stream = 0
  stream.flush = NO_FLUSH
  var count = 0;
  while count < 2 * IGZIP_HIST_SIZE + ISAL_LOOK_AHEAD :
    stream.internal_state.buffer[count] = uint8(32)
    inc(count)

  count = 0
  while count < IGZIP_HASH_SIZE:
    stream.internal_state.head[count] = uint16(16)
    inc(count)

  while stream.internal_state.state != ZSTATE_END:
    count = 0;
    while count < 8192:
      inbuf[count] = cast[uint8](0)
      inc(count)
    stream.avail_in = cast[uint32](ifile.readBuffer(addr(inbuf), 8192))
    stream.next_in = cast[ptr uint8](addr(inbuf))
    if (stream.avail_in < 8192) :
      stream.end_of_stream = 1
    else :
      stream.end_of_stream = 0

    echo "----001--avail_in = ",stream.avail_in ," endofstream = ",stream.end_of_stream;

    stream.avail_out = 8192
    while true:
      stream.avail_out = 8192
      count = 0
      while count < 8192:
        outbuf[count] = cast[uint8](0)
        inc(count)
      stream.next_out = cast[ptr uint8](addr(outbuf))

      isal_deflate(addr(stream))

      echo "----002--avail_out = ",stream.avail_out ," uint32(8192)-stream.avail_out = ",uint32(8192)-stream.avail_out;
      wlen = ofile.writeBuffer(addr(outbuf), uint32(8192)-stream.avail_out)
      if (stream.avail_out > uint32(0)): break

    if (stream.internal_state.state == ZSTATE_END) : break
  ifile.close()
  ofile.close()

  echo "End of igzip_example"

var
  infile = ""
for kind, key, val in getopt():
  case kind
  of cmdArgument:
    infile = key
  of cmdLongOption, cmdShortOption:
    case key.normalize
    of "help", "h":
      stdout.write(Usage)
      quit(0)
    of "version", "v":
      stdout.write(Version & "\n")
      quit(0)
  of cmdEnd: assert(false)
if infile == "":
  # no filename has been given, so we show the help:
  stdout.write(Usage)
else:
  nimmain(infile)
