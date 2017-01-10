
import isa, parseopt, strutils

const
  Version = "1.0.0" # keep in sync with Nimble version. D'oh!
  Usage = """
  Usage: crc infile
"""

proc nimmain(infile: string) =
  isa.crc64(infile)

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
