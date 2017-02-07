import isa/build, isa/raw_gzip, collections/bytes, collections/views

type
  DeflateCompressor = ref object
    stream: isal_zstream

proc newDeflateCompressor*(): DeflateCompressor =
  ## Create new Deflate compressor.
  ##
  ## The compressor returns raw data without headers with window size == 32kB.
  ## The data can be decompressed, for example, by using Python's zlib.decompress(data, -15)
  let self = new(DeflateCompressor)
  isal_deflate_init(addr self.stream)
  self.stream.end_of_stream = 0
  self.stream.flush = NO_FLUSH
  return self

proc drain(self: DeflateCompressor): string =
  # unoptimal: involves two memory copies, but it's hard to make universal API without this
  result = ""
  var buffer = newString(4096)

  while true:
    self.stream.avail_out = buffer.len.uint32
    self.stream.next_out = cast[ptr uint8](addr buffer[0])
    discard isal_deflate(addr self.stream)
    result &= buffer[0..<buffer.len - self.stream.avail_out.int]

    if self.stream.avail_out != 0:
      break

  assert(self.stream.avail_in == 0);

proc compress*(self: DeflateCompressor, data: string): string =
  ## Compress data using Deflate.
  self.stream.avail_in = data.len.uint32
  self.stream.next_in = cast[ptr uint8](unsafeAddr data[0])

  return self.drain

proc close*(self: DeflateCompressor): string =
  ## Close the stream and return remaining data.
  self.stream.end_of_stream = 1

  result = self.drain

  while self.stream.internal_state.state != ZSTATE_END:
    result &= self.drain

when isMainModule:
  let c = newDeflateCompressor()
  let text = "hello"
  let data = c.compress(text) & c.close()
  echo data.encodeHex
