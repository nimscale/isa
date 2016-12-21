 {.deadCodeElim: on.}

import
  random, erasure_code, strutils
## #define CACHED_TEST

when defined(windows):
  const
    libname* = "libisal.dll"
elif defined(macosx):
  const
    libname* = "libisal.dylib"
else:
  const
    libname* = "libisal.so"
##  Use sys/time.h functions for time
when defined(CACHED_TEST):
  ##  Cached test, loop many times over small dataset
  const
    TEST_SOURCES* = 32
  template TEST_LEN*(m: untyped): untyped =
    ((128 * 1024 div m) and not (64 - 1))

  template TEST_LOOPS*(m: untyped): untyped =
    (100 * m)

  const
    TEST_TYPE_STR* = "_warm"
else:
  when not defined(TEST_CUSTOM):
    ##  Uncached test.  Pull from large mem base.
    const
      TEST_SOURCES* = 32
      GT_L3_CACHE* = 32 * 1024 * 1024
    template TEST_LEN*(m: untyped): untyped =
      ((GT_L3_CACHE div m) and not (64 - 1))

    template TEST_LOOPS*(m: untyped): untyped =
      (10)

    const
      TEST_TYPE_STR* = "_cold"
  else:
    const
      TEST_TYPE_STR* = "_cus"
    when not defined(TEST_LOOPS):
      template TEST_LOOPS*(m: untyped): untyped =
        1000

const
  MMAX* = TEST_SOURCES
  KMAX* = TEST_SOURCES

type
  u8* = cuchar
  Timeval {.importc: "struct timeval",
              header: "<sys/select.h>".} = object ## struct timeval
      tv_sec: int  ## Seconds. 
      tv_usec: int ## Microseconds. 
    
  perf* = object
    tv*: Timeval
  Matrix[W, H: static[int]] =
    array[1..W, array[1..H, u8]]

proc memcpy(dest:array[32, u8], src:array[4,int], size: cint) {.header: "<malloc.h>", importc: "memcpy".}

proc memcmp(src:ptr u8, dst:ptr u8, size: int32): cint{.header: "<malloc.h>", importc: "memcmp".}

proc memset(dest: ptr, value:cuchar, size: cint) {.header: "<malloc.h>", importc: "memset".}

proc posix_memalign(memptr: ptr, alignment: cint, size: cint): cint {.header: "<stdlib.h>", importc: "posix_memalign".}

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


proc gf_gen_rs_matrix(a:array[MMAX * KMAX, u8]; m:cint; k:cint) {.cdecl, importc: "gf_gen_rs_matrix", dynlib: libname.}
proc ec_init_tables(k:cint; m: cint; a: ptr u8; g_tbls:array[KMAX * TEST_SOURCES * 32, u8]) {.cdecl, importc: "ec_init_tables", dynlib: libname.}
proc ec_encode_data_base(m:int32; k:cint; mk:int32, g_tbls:array[0..32767, u8]; buffs:array[TEST_SOURCES, ptr u8]; bfsk:ptr ptr u8) {.cdecl, importc: "ec_encode_data_base", dynlib: libname.}
proc gf_invert_matrix(b:array[MMAX * KMAX, u8]; d:array[MMAX * KMAX, u8]; k:cint): cint {.cdecl, importc: "gf_invert_matrix", dynlib: libname.}

#proc main*(argc: cint; argv: ptr cstring): cint {.cdecl.} =
proc main(argc: cint) =
  var
    i, j, rtest, m, k, nerrs, r : cint
  var
    buf : ptr u8
  var
    # u8 *temp_buffs[TEST_SOURCES], *buffs[TEST_SOURCES];
    temp_buffs : array[TEST_SOURCES, ptr u8]
    buffs : array[TEST_SOURCES, ptr u8]
    recov : array[TEST_SOURCES, ptr u8]
    # u8 a[MMAX * KMAX], b[MMAX * KMAX], c[MMAX * KMAX], d[MMAX * KMAX];
    a, b, c, d: array[MMAX * KMAX, u8]
    g_tbls:array[KMAX * TEST_SOURCES * 32, u8]
    src_in_err:array[TEST_SOURCES, u8]
    src_err_list:array[TEST_SOURCES, u8]

  var
    start: perf
    stop: perf

  ##  Pick test parameters
  m = 14
  k = 10
  nerrs = 4

  type
    IntArray = array[0..3, int] # an array that is indexed with 0..5
  var
    err_list: IntArray
  err_list = [2, 4, 5, 7]


  # printf("erasure_code_base_perf: %dx%d %d\x0A", m, TEST_LEN(m), nerrs)
  echo "erasure_code_base_perf: ", m, "x", TEST_LEN(m), nerrs, "\n"
  if m > MMAX or k > KMAX or nerrs > (m - k):
    echo " Input test parameter error\n"
    return

  memcpy(src_err_list, err_list, nerrs)
  #for i in low(err_list)..high(err_list):
  #  src_err_list[i] = cast[u8](err_list[i])
  memset(addr(src_in_err), cast[u8](0), TEST_SOURCES)
  #for i in low(TEST_SOURCES)..high(TEST_SOURCES):
  #  src_in_err[i] = cast[u8]('0');
  randomize()

  i = 0
  while i < nerrs:
    src_in_err[cast[int](src_err_list[i])] = cast[u8](0)
    inc(i)
  ##  Allocate the arrays
  i = 0
  try:
    while i < m:
      var result = posix_memalign(addr(buf), 64, TEST_LEN(m))
      if result != 0:
        echo "alloc error: Fail \n"
        return
      buffs[i] = buf
      inc(i)
    i = 0
  except Exception:
    var exc = getCurrentException()
    echo "--exception:", getCurrentExceptionMsg()


  while i < (m - k):
    var result = posix_memalign(addr(buf), 64, TEST_LEN(m))
    if  result != 0:
      echo "alloc error: Fail\n"
      return
    temp_buffs[i] = buf
    inc(i)

  ##  Make random data
  i = 0
  while i < k:
   j = 0
   var tmpbf = ""
   while j < TEST_LEN(m):
      var tmp = cast[u8](random(10));
      tmpbf = tmpbf & tmp
      inc(j)
   buffs[i]=cast[ptr u8](tmpbf)
   inc(i)

  gf_gen_rs_matrix(a, m, k)
  ec_init_tables(k, m - k, addr(a[k * k]), g_tbls)
  ec_encode_data_base(TEST_LEN(m), k, m - k, g_tbls, buffs, addr(buffs[k]))
  ##  Start encode test
  var mystatus = 0;
  mystatus = perf_start(addr(start))
  rtest = 0
  
  while rtest < TEST_LOOPS(m):
    ##  Make parity vects
    ec_init_tables(k, m - k, addr(a[k * k]), g_tbls)
    ec_encode_data_base(TEST_LEN(m), k, m - k, g_tbls, buffs, addr(buffs[k]))
    inc(rtest)
  mystatus = perf_stop(addr(stop))
  echo "erasure_code_base_encode", TEST_TYPE_STR, ": "
  perf_print(stop, start, cast[clonglong]((TEST_LEN(m)) * (m) * rtest))
  ##  Start decode test
  mystatus = perf_start(addr(start))
  rtest = 0
  while rtest < TEST_LOOPS(m):
    i = 0
    r = 0
    while i < k:
      while src_in_err[r] > cast[u8](0):
        inc(r)
      recov[i] = buffs[r]
      j = 0
      while j < k:
        b[k * i + j] = a[k * r + j]
        inc(j)
      inc(i)
      inc(r)
    if gf_invert_matrix(b, d, k) < 0:
      echo "BAD MATRIX\n"
      return
    i = 0
    while i < nerrs:
      j = 0
      while j < k:
        c[k * i + j] = d[k * cast[cint](src_err_list[i]) + j]
        inc(j)
      inc(i)
    ##  Recover data

    ec_init_tables(k, nerrs, addr(c[0]), g_tbls)
    ec_encode_data_base(TEST_LEN(m), k, nerrs, g_tbls, recov, addr(temp_buffs[1]))
    inc(rtest)
    
  mystatus = perf_stop(addr(stop))
  i = 0
  while i < nerrs:
    if 0 != memcmp(temp_buffs[i], buffs[cast[int](src_err_list[i])], TEST_LEN(m)):
      echo "Fail error recovery (",m,",",k,",",nerrs
      return
    inc(i)
  echo "erasure_code_base_decode", TEST_TYPE_STR, ": "
  perf_print(stop, start, cast[clonglong]((TEST_LEN(m)) * (k + nerrs) * rtest))
  echo "done all: Pass\n"
  return

var
  infile = "a"
if infile == "":
  # no filename has been given, so we show the help:
  stdout.write("a")
else:
  main(1)
