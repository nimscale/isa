import isa/build, isa/raw_multi_buffer, collections/views
import isa/raw_sha1

type
  HasherPool[MGR, CTX] = ref object
    ## Object that manages computation of multiple hashes.
    ##
    ## (computing several hashes at the same time is faster than doing it serially)
    mgr: MGR

  Job[MGR, CTX] = CTX

  Sha1Pool* = HasherPool[SHA1_HASH_CTX_MGR, SHA1_HASH_CTX]

  Sha1Job* = Job[SHA1_HASH_CTX_MGR, SHA1_HASH_CTX]

export HASH_UPDATE, HASH_FIRST, HASH_LAST, HASH_ENTIRE, HASH_CTX_FLAG

proc newSha1Pool*(): Sha1Pool =
  new(result)
  assert cast[int](addr result.mgr) mod 16 == 0 # ensure the object is aligned
  sha1_ctx_mgr_init(addr result.mgr)

proc initJob*[T](typ: typedesc[T], userData: pointer=nil): T =
  hash_ctx_init(result)
  result.user_data = user_data

proc bswap32(a: uint32): uint32 {.importc: "__builtin_bswap32".}

proc getResult*(job: ptr Job): string =
  # digest is stored in endian-reversed 32-bit integers
  result = newString(sizeof(job.job.result_digest))
  for i in 0..<(sizeof(job.job.result_digest) div 4):
    var word: uint32 = bswap32(job.job.result_digest[i])
    copyMem(addr result[i * 4], addr word, 4)

proc userData*(job: ptr Job): pointer =
  return job.ctx.user_data

proc doSubmit(mgr: ptr SHA1_HASH_CTX_MGR; ctx: ptr SHA1_HASH_CTX;
              buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr SHA1_HASH_CTX =
  return sha1_ctx_mgr_submit(mgr, ctx, buffer, len, flags)

proc flushHash*(pool: Sha1Pool): ptr Sha1Job =
  ## Force pool to complete a job.
  return sha1_ctx_mgr_flush(addr pool.mgr)

proc submitHash*[MGR, CTX](pool: HasherPool[MGR, CTX], job: ptr Sha1Job, data: ByteView, kind: HASH_CTX_FLAG): auto =
  ## Submit a hashing job into a pool. If pool completes a job, return it.
  return doSubmit(addr pool.mgr, job, data.data, data.len.uint32, kind)

proc computeHashes*[MGR, CTX](pool: HasherPool[MGR, CTX], data: seq[string]): seq[string] =
  ## Compute hashes of blocks stored in ``data``.
  var jobs = newSeq[CTX](data.len)
  result = newSeq[string](data.len)
  for i in 0..<data.len:
    jobs[i] = initJob(CTX, userData=addr result[i])

  template finishHash(job) =
    let s = cast[ptr string](job.userData)
    s[] = job.getResult

  for i in 0..<data.len:
    let job = pool.submitHash(addr jobs[i], ByteView(data: unsafeAddr data[i][0], size: data[i].len), HASH_ENTIRE)
    if job != nil:
      finishHash(job)

  while true:
    let job = pool.flushHash()
    if job == nil:
      break

    finishHash(job)
