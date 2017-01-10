{.deadCodeElim: on.}
when defined(windows):
  const
    isalibname* = "libisal.dll"
    isaclibname* = "libisal_crypto.dll"
elif defined(macosx):
  const
    isalibname* = "libisal.dylib"
    isaclibname* = "libisal_crypto.dylib"
else:
  const
    isalibname* = "libisal.so"
    isaclibname* = "libisal_crypto.so"


import 
  strutils, os, times, parseopt, compiler/llstream, compiler/ast,
  compiler/renderer, compiler/options, compiler/msgs,random, system

################Check CRC
proc crc64ecmarefl(crc64_checksum : int, buffer: array[4096, cuchar], length: int ) : int {. 
    cdecl, importc : "crc64_ecma_refl" , dynlib: isalibname.}
    
proc crc64*(filepath: string): void {.inline, cdecl.} =
  const size = 4096
  var
    i = open(filepath)
    buf: array[size, char]
    crc64_checksum = 0
    total_in = 0
    relen = 0
  relen = i.readBuffer(buf.addr, size)
  while relen > 0:
    crc64_checksum = crc64ecmarefl(crc64_checksum, buf, relen)
    total_in = total_in + relen
    relen = i.readBuffer(buf.addr, size)
  i.close()
  echo "total length is $#.\nchecksum is 0x$#.\n".format(total_in, toHex(crc64_checksum))
########################################################################################

################Check AES encrypt/decrypt

proc encryptAES(key2: array[16, cuchar], key1:array[16, cuchar], tinit:array[16, cuchar], ptlen: int, pt:array[256, uint8], ct_test:array[256, uint8]) : int {. 
    cdecl, importc : "XTS_AES_128_enc" , dynlib: isaclibname.}
proc decryptAES(key2: array[16, cuchar], key1:array[16, cuchar], tinit:array[16, cuchar], ptlen: int, ct:array[256, uint8], dt_test:array[256, uint8]) : int {. 
    cdecl, importc : "XTS_AES_128_dec" , dynlib: isaclibname.}

proc encryptFileAES*(srcFile : string, encFile : string, key2: array[16, cuchar], key1:array[16, cuchar], tinit:array[16, cuchar] ) : void {.inline, cdecl.} =
  const testlen = 256
  var
    ct_test: array[testlen, uint8]
    srcfp, encfp: File
    buf: array[testlen, uint8]
    readlen = 0
    writelen = 0
    result: int = 0
    i: int = 0;

  srcfp = open(srcFile)
  encfp = open(encFile, fmWrite)
  while i < testlen:
    ct_test[i] = cast[uint8](0)
    inc(i)
    
  readlen = 1;
  while readlen > 0:
    readlen = readBytes(srcfp, buf, 0, testlen)
    result = encryptAES(key2, key1, tinit, readlen, buf, ct_test)
    writelen = writeBytes(encfp, ct_test, 0, readlen)
  srcfp.close()
  encfp.close()
  
########################################################################################

proc decryptFileAES*(encFile : string, decFile : string, key2: array[16, cuchar], key1:array[16, cuchar], tinit:array[16, cuchar] ) : void {.inline, cdecl.} =
  const testlen = 256
  var
    dt_test: array[testlen, uint8]
    encfp, decfp: File
    buf: array[testlen, uint8]
    readlen = 0
    writelen = 0
    result: int = 0
    i: int = 0;
 
  encfp = open(encFile)
  decfp = open(decFile, fmWrite)
  while i < testlen:
    dt_test[i] = cast[uint8](0)
    inc(i)
    
  readlen = 1;
  while readlen > 0:
    readlen = readBytes(encfp, buf, 0, testlen)
    result = decryptAES(key2, key1, tinit, readlen, buf, dt_test)
    writelen = writeBytes(decfp, dt_test, 0, readlen)

  encfp.close()
  decfp.close()

########################################################################################
