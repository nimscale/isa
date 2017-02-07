import isa/build, isa/raw_raid, collections/views

proc generateXor*(chunkLen: int; chunks: View[pointer]) =
  ## Generate XOR parity into chunks[array.len-1] from chunks[0..<array.len-1]
  ## Each chunks[i] should be a pointer into block of size ``chunkLen`` and must be aligned to 32 bytes.
  let err = xor_gen(chunks.len.cint, chunkLen.cint, cast[ptr pointer](chunks.data))
  assert err == 0

proc generatePQ*(chunkLen: int; chunks: View[pointer]) =
  ## Generate P + Q parity into chunks[array.len-1] and chunks[array.len-2] from chunks[0..<array.len-2]
  ## Each chunks[i] should be a pointer into block of size ``chunkLen`` and must be aligned to 32 bytes.
  let err = pq_gen(chunks.len.cint, chunkLen.cint, cast[ptr pointer](chunks.data))
  assert err == 0

proc checkXor*(chunkLen: int; chunks: View[pointer]): bool =
  ## Check XOR parity of chunks.
  ##
  ## Each chunks[i] should be a pointer into block of size ``chunkLen`` and must be aligned to 32 bytes.
  let err = xor_check(chunks.len.cint, chunkLen.cint, cast[ptr pointer](chunks.data))
  return err == 0

proc checkPQ*(chunkLen: int; chunks: View[pointer]): bool =
  ## Check P + Q parity of chunks.
  ##
  ## Each chunks[i] should be a pointer into block of size ``chunkLen`` and must be aligned to 32 bytes.
  let err = pq_check(chunks.len.cint, chunkLen.cint, cast[ptr pointer](chunks.data))
  return err == 0
