 {.deadCodeElim: on.}
when defined(windows):
  const
    libname* = "libisal_crypto.dll"
elif defined(macosx):
  const
    libname* = "libisal_crypto.dylib"
else:
  const
    libname* = "libisal_crypto.so"

import
  random, strutils


proc XTS_AES_128_enc*(k2: array[0..15, char]; k1: array[0..15, char]; TW_initial: array[0..15, char]; N: uint64;
                     pt: ptr cuchar; ct: ptr cuchar) {.cdecl, importc: "XTS_AES_128_enc",
    dynlib: libname.}

proc XTS_AES_128_enc_expanded_key*(k2: array[0..15, char]; k1: array[0..15, char]; TW_initial: array[0..15, char];
                                  N: uint64; pt: ptr cuchar; ct: ptr cuchar) {.cdecl,
    importc: "XTS_AES_128_enc_expanded_key", dynlib: libname.}

proc XTS_AES_128_dec*(k2: array[0..15, char] ;k1: array[0..15, char]; TW_initial: array[0..15, char]; N: uint64;
                     ct: ptr cuchar; pt: ptr cuchar) {.cdecl, importc: "XTS_AES_128_dec",
    dynlib: libname.}

proc XTS_AES_128_dec_expanded_key*(k2: ptr uint8; k1: ptr uint8; TW_initial: ptr uint8;
                                  N: uint64; ct: ptr uint8; pt: ptr uint8) {.cdecl,
    importc: "XTS_AES_128_dec_expanded_key", dynlib: libname.}


when defined(CACHED_TEST):
  ##  Cached test, loop many times over small dataset
  const
    TEST_LEN* = 32 * 1024
    TEST_LOOPS* = 400000
    TEST_TYPE_STR* = "_warm"
else:
  ##  Uncached test.  Pull from large mem base.
  const
    # GT_L3_CACHE* = 32 * 1024 * 1024
    GT_L3_CACHE* = 200 * 1024
    TEST_LEN* = (2 * GT_L3_CACHE)
    TEST_LOOPS* = 50
    TEST_TYPE_STR* = "_cold"
const
  TEST_MEM* = TEST_LEN
type
  u8* = cuchar
  Timeval {.importc: "struct timeval",
              header: "<sys/select.h>".} = object ## struct timeval
      tv_sec: int  ## Seconds.
      tv_usec: int ## Microseconds.

  perf* = object
    tv*: Timeval

proc gettimeofday(tv: ptr Timeval, val: int): cint {.header: "<sys/time.h>", importc: "gettimeofday".}

proc perf_start*(p: ptr perf): cint {.inline, cdecl.} =
  return gettimeofday(addr((p.tv)), 0)

proc perf_stop*(p: ptr perf): cint {.inline, cdecl.} =
  return gettimeofday(addr((p.tv)), 0)

proc perf_print*(stop: perf; start: perf; dsize: clonglong) {.inline, cdecl.} =
  var secs: clonglong
  var usecs: clonglong
  # secs = stop.tv.tv_sec - start.tv.tv_sec
  secs = stop.tv.tv_sec - start.tv.tv_sec

  usecs = secs * 1000000 + stop.tv.tv_usec - start.tv.tv_usec
  echo "runtime = ", usecs, "usecs"
  if dsize != 0:
    echo " bandwidth ", dsize div (1024 * 1024), " MB in", usecs div 1000000,"sec = ",dsize div usecs," MB/s \n"
  else:
    echo"\n"



proc main*(): cint {.cdecl.} =
  var
    i: cint
    key1: array[0 .. 15, char]
    key2: array[0 .. 15, char]
    tinit: array[0 .. 15, char]
    pt: ptr cuchar
    ct: ptr cuchar
    dt: ptr cuchar

  echo "aes_xts_128_dec_perf:\n"
  pt = cast[ptr cuchar](alloc(TEST_LEN))
  ct = cast[ptr cuchar](alloc(TEST_LEN))
  dt = cast[ptr cuchar](alloc(TEST_LEN))

  if nil == pt or nil == ct or nil == dt:
    echo "malloc of testsize failed.\n"
    return - 1


  assert key1.len == 16
  assert key2.len == 16
  assert tinit.len == 16
  assert key1 == ['\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0']
  assert key2 == ['\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0']
  assert tinit == ['\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0']


  randomize()
  i = 0
  while i < 16:
    key1[i] = cast[cuchar](random(10))
    key2[i] = cast[cuchar](random(11))
    tinit[i] = cast[cuchar](random(12))
    inc(i)

  i = 0
  var tmpbuf = ""
  while i < TEST_LEN:
    var tmp = cast[cuchar](random(10))
    tmpbuf = tmpbuf & tmp
    inc(i)
  pt = cast[ptr cuchar](tmpbuf)

  XTS_AES_128_enc(key2, key1, tinit, (uint64)TEST_LEN, pt, ct)
  XTS_AES_128_dec(key2, key1, tinit, (uint64)TEST_LEN, ct, dt)
  var
    start: perf
    stop: perf
  var mystatus = 0;
  mystatus =perf_start(addr(start))
  i = 0
  while i < TEST_LOOPS:
    XTS_AES_128_dec(key2, key1, tinit, TEST_LEN, ct, dt)
    inc(i)
  mystatus = perf_stop(addr(stop))
  echo "aes_xts_128_dec", TEST_TYPE_STR
  perf_print(stop, start, cast[clonglong](TEST_LEN * i))
  return 0

var
  ret: cint
ret = main()


