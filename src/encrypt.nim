
import isa, random, parseopt, strutils, os

const
  Version = "1.0.0" # keep in sync with Nimble version. D'oh!
  Usage = """
  Usage: encrypt srcfile dstpath
"""

proc nimmain() =
  const testlen = 256
  var
    i: cint
    srcbuf: array[testlen, uint8]
    decbuf: array[testlen, uint8]
    key1: array[16, cuchar]
    key2: array[16, cuchar]
    tinit: array[16, cuchar]
    srcfile: string
    encfile: string
    decfile: string
    srcfp, decfp: File
    readlen = 0
    srcreadlen = 0
    decreadlen = 0


  srcfile = "./encrypt"
  encfile = "/tmp/enctest"
  decfile = "/tmp/dectest"

  randomize()
  i = 0
  while i < 16:
    key1[i] = cast[cuchar](random(10))
    key2[i] = cast[cuchar](random(11))
    tinit[i] = cast[cuchar](random(12))
    inc(i)

  #encrypt the file
  echo "Encrypting ", srcfile, " ..."
  isa.encryptFileAES(srcfile, encfile, key2, key1, tinit)
  echo "Encrypted."
  #decrypt the file
  echo "Decrypting ", decfile, " ..."
  isa.decryptFileAES(encfile, decfile, key2, key1, tinit)
  echo "Decrypted."
  #compare
  echo "Comparing ", srcfile , " with ", decfile, " ..."
  if (getFileSize(srcfile) != getFileSize(decfile)):
    echo "File size is different!"
    echo "src file :", getFileSize(srcfile)
    echo "decrypted file: ", getFileSize(decfile)
    return

  echo "src file :", getFileSize(srcfile)
  echo "decrypted file: ", getFileSize(decfile)

  srcfp = open(srcfile)
  decfp = open(decfile)
  srcreadlen = 1;
  while srcreadlen > 0:
    srcreadlen = readBytes(srcfp, srcbuf, 0, testlen)
    decreadlen = readBytes(decfp, decbuf, 0, testlen)
    if (srcreadlen != decreadlen) :
      echo "File size is different, Failed!"
      return
    i = 0;
    while i < srcreadlen :
      if (srcbuf[i] != decbuf[i]):
        echo "File is different, Failed!"
        return
      inc(i)

  echo "Finished to compare."
  echo "Success!"
nimmain()
