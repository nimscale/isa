## High level interface for ISA-L erasure coder.
import isa/build, isa/raw_erasure_code, sequtils, future

type
  ErasureCoder* = ref object
    k, m: int
    encodeMatrix: seq[cuchar]
    encodeTabs: seq[cuchar]

  ErasureDecoder* = ref object
    coder: ErasureCoder
    decodeMatrix: seq[cuchar]
    decodeTabs: seq[cuchar]
    erasures: seq[int]

proc showTab(t: seq[cuchar]): string =
  return $(t.map(x => x.int))

proc newErasureCoder*(k: int, m: int): ErasureCoder =
  ## Create a new erasure coder.
  ##
  ## k - number of data chunks
  ## m - number of redundant chunks
  let self = ErasureCoder(k: k, m: m)

  self.encodeMatrix = newSeq[cuchar](k * (k + m))
  self.encodeTabs = newSeq[cuchar](32 * k * (k + m))

  gf_gen_cauchy1_matrix(addr self.encodeMatrix[0], (k + m).cint, k.cint)
  ec_init_tables(k.cint, m.cint, addr self.encodeMatrix[k * k], addr self.encodeTabs[0])

  return self

proc encode*(self: ErasureCoder, input: ptr cstring, output: ptr cstring, chunksize: int) =
  ec_encode_data(chunksize.cint, self.k.cint, self.m.cint,
                 cast[ptr cuchar](addr self.encodeTabs[0]),
                 cast[ptr ptr cuchar](input),
                 cast[ptr ptr cuchar](output))

proc encode*(self: ErasureCoder, input: seq[string]): seq[string] =
  ## Erasure-code chunks from ``input``.
  ##
  ## ``input.len`` should equal ``self.k`` and all chunks should have same size.

  assert input.len == self.k
  let chunksize = input[0].len
  for s in input: assert(s.len == chunksize)

  result = newSeq[string](self.m)
  for i in 0..<self.m: result[i] = newString(chunksize)

  var inputPtr = newSeq[cstring](input.len)
  for i in 0..<input.len: inputPtr[i] = input[i].cstring

  var outputPtr = newSeq[cstring](result.len)
  for i in 0..<result.len: outputPtr[i] = result[i].cstring

  self.encode(addr inputPtr[0], addr outputPtr[0], chunksize)

proc pad(s: var string, k: int) =
  for i in 0..<(k - s.len mod k):
    s.add(char(k))

proc encodeString*(s: string, totalChunks: int, maxLost: int): seq[string] =
  ## Erasure-code single string. You will get ``totalChunks`` of chunks.
  assert totalChunks <= 255
  assert maxLost + 1 <= totalChunks
  let origChunks = totalChunks - maxLost

  var s = s
  pad(s, origChunks)
  var chunks: seq[string] = @[]
  let sizePerChunk = s.len div origChunks
  for i in 0..<origChunks:
    chunks.add(s[i * sizePerChunk..<(i+1) * sizePerChunk])

  chunks &= newErasureCoder(origChunks, maxLost).encode(chunks)
  return chunks

proc newDecoder*(coder: ErasureCoder, erasures: seq[int]): ErasureDecoder =
  ## Create decoder the decodes damaged blocks with numbers in ``erasures``.
  ## Caching this object may be faster than using ``ErasureCoder.decode``.
  if erasures.len > coder.m:
    raise newException(Exception, "too much data lost")

  var isErased = newSeq[bool](coder.k + coder.m)
  for i in erasures:
    isErased[i] = true

  var row = 0
  var smatrix: seq[cuchar] = newSeq[cuchar](coder.k * (coder.k + coder.m))
  var invmatrix: seq[cuchar] = newSeq[cuchar](coder.k * (coder.k + coder.m))
  var decodematrix: seq[cuchar] = newSeq[cuchar](coder.k * (coder.k + coder.m))

  # remove damaged entries from the matrix
  for i in 0..<coder.k + coder.m:
    if isErased[i]:
      continue
    for j in 0..<coder.k:
      smatrix[coder.k * row + j] = coder.encodeMatrix[coder.k * i + j]
    row += 1

  let ok = gf_invert_matrix(addr smatrix[0], addr invmatrix[0], coder.k.cint)
  assert(ok == 0)

  # put damaged entries from the inverted matrix
  for index, i in erasures:
    for j in 0..<coder.k:
      decodematrix[coder.k * index + j] = invmatrix[coder.k * i + j]

  var decodeTabs = newSeq[cuchar](32 * coder.k * (coder.k + coder.m))
  ec_init_tables(coder.k.cint, erasures.len.cint, addr decodeMatrix[0], addr decodeTabs[0])

  return ErasureDecoder(coder: coder, decodeTabs: decodeTabs, decodeMatrix: decodeMatrix,
                        erasures: erasures)

proc decode*(self: ErasureDecoder, input: ptr cstring, output: ptr cstring, chunksize: int) =
  ec_encode_data(chunksize.cint, self.coder.k.cint, self.erasures.len.cint,
                 cast[ptr cuchar](addr self.decodeTabs[0]),
                 cast[ptr ptr cuchar](input),
                 cast[ptr ptr cuchar](output))

proc decode*(self: ErasureDecoder, input: seq[string]): seq[string] =
  ## Repair damanged chunks. ``input`` should include only non-damanged chunks.
  let chunksize = input[0].len
  for s in input: assert(s.len == chunksize)

  result = newSeq[string](self.erasures.len)
  for i in 0..<result.len: result[i] = newString(chunksize)

  var inputPtr = newSeq[cstring](input.len)
  for i in 0..<input.len: inputPtr[i] = input[i].cstring

  var outputPtr = newSeq[cstring](result.len)
  for i in 0..<result.len: outputPtr[i] = result[i].cstring

  self.decode(addr inputPtr[0], addr outputPtr[0], chunksize)

proc decode*(coder: ErasureCoder, input: seq[string]): seq[string] =
  ## Repair damanged chunks. Damanged chunks should be marked using ``nil`` in ``input``.
  var erasures: seq[int] = @[]
  var decodeInput: seq[string] = @[]
  for i in 0..<input.len:
    if input[i] == nil:
      erasures.add(i)
    else:
      decodeInput.add(input[i])

  return coder.newDecoder(erasures).decode(decodeInput)
