
import
  strutils, os, times, parseopt, compiler/llstream, compiler/ast,
  compiler/renderer, compiler/options, compiler/msgs

type
  uint16_t = uint16
  uint64_t = uint64
  uint32_t = uint32
  int64_t = int64

const
  Version = "1.0.0" # keep in sync with Nimble version. D'oh!
  Usage = """
  Usage: crc64_example infile
"""


{.passL: "-lisal".}
proc crc64_ecma_refl(crc64_checksum : int, buffer: array[4096, cuchar], length: int ) : int {. cdecl,
                                        dynlib : "libisal.so",
                                        importc : "crc64_ecma_refl" .}


proc nimmain(infile: string) =
  var start = getTime()
  const size = 4096
  var
    i = open(infile)
    buf: array[size, char]
    crc64_checksum = 0
    total_in = 0
    relen = 0
  relen = i.readBuffer(buf.addr, size)
  while relen > 0:
#  crc64_ecma_refl(crc64_checksum, inbuf, avail_in);
    crc64_checksum = crc64_ecma_refl(crc64_checksum, buf, relen)
    total_in = total_in + relen
    relen = i.readBuffer(buf.addr, size)
  i.close()
  echo total_in
  echo crc64_checksum
  echo "total length is $#.\nchecksum is $#.\n".format(total_in, crc64_checksum)


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
