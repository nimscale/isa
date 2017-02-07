import isa/build, isa/raw_multi_buffer, collections/views
import isa/raw_sha1, isa/raw_sha256, isa/raw_sha512, isa/raw_md5

type
  HasherPool[MGR, CTX] = ref object
    ## Object that manages computation of multiple hashes.
    ##
    ## (computing several hashes at the same time is faster than doing it serially)
    mgr: MGR

  Job[MGR, CTX] = CTX

  Sha1Pool* = HasherPool[SHA1_HASH_CTX_MGR, SHA1_HASH_CTX]

  Sha1Job* = Job[SHA1_HASH_CTX_MGR, SHA1_HASH_CTX]

  Md5Pool* = HasherPool[MD5_HASH_CTX_MGR, MD5_HASH_CTX]

  Md5Job* = Job[MD5_HASH_CTX_MGR, MD5_HASH_CTX]

  Sha256Pool* = HasherPool[SHA256_HASH_CTX_MGR, SHA256_HASH_CTX]

  Sha256Job* = Job[SHA256_HASH_CTX_MGR, SHA256_HASH_CTX]

  Sha512Pool* = HasherPool[SHA512_HASH_CTX_MGR, SHA512_HASH_CTX]

  Sha512Job* = Job[SHA512_HASH_CTX_MGR, SHA512_HASH_CTX]

export HASH_UPDATE, HASH_FIRST, HASH_LAST, HASH_ENTIRE, HASH_CTX_FLAG

proc newSha1Pool*(): Sha1Pool =
  new(result)
  assert cast[int](addr result.mgr) mod 16 == 0 # ensure the object is aligned
  sha1_ctx_mgr_init(addr result.mgr)

proc newMd5Pool*(): Md5Pool =
  new(result)
  assert cast[int](addr result.mgr) mod 16 == 0 # ensure the object is aligned
  md5_ctx_mgr_init(addr result.mgr)

proc newSha256Pool*(): Sha256Pool =
  new(result)
  assert cast[int](addr result.mgr) mod 16 == 0 # ensure the object is aligned
  sha256_ctx_mgr_init(addr result.mgr)

proc newSha512Pool*(): Sha512Pool =
  new(result)
  assert cast[int](addr result.mgr) mod 16 == 0 # ensure the object is aligned
  sha512_ctx_mgr_init(addr result.mgr)

proc initJob*[T](typ: typedesc[T], userData: pointer=nil): T =
  hash_ctx_init(result)
  result.user_data = user_data

proc bswap32(a: uint32): uint32 {.importc: "__builtin_bswap32".}
proc bswap64(a: uint64): uint64 {.importc: "__builtin_bswap64".}

proc getResult*(job: ptr Job): string =
  result = newString(sizeof(job.job.result_digest))

  for i in 0..<(sizeof(job.job.result_digest) div sizeof(job.job.result_digest[0])):
    when job is ptr Sha512Job:
      var word: uint64 = bswap64(job.job.result_digest[i])
      copyMem(addr result[i * 8], addr word, 8)
    else:
      var word: uint32
      when job is ptr Md5Job:
        word = job.job.result_digest[i]
      else:
        # digest is stored in endian-reversed 32-bit integers
        word = bswap32(job.job.result_digest[i])
      copyMem(addr result[i * 4], addr word, 4)

proc userData*(job: ptr Job): pointer =
  return job.ctx.user_data

# sha1
proc doSubmit(mgr: ptr SHA1_HASH_CTX_MGR; ctx: ptr SHA1_HASH_CTX;
              buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr SHA1_HASH_CTX =
  return sha1_ctx_mgr_submit(mgr, ctx, buffer, len, flags)

proc flushHash*(pool: Sha1Pool): ptr Sha1Job =
  ## Force pool to complete a job.
  return sha1_ctx_mgr_flush(addr pool.mgr)

# sha256
proc doSubmit(mgr: ptr SHA256_HASH_CTX_MGR; ctx: ptr SHA256_HASH_CTX;
              buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr SHA256_HASH_CTX =
  return sha256_ctx_mgr_submit(mgr, ctx, buffer, len, flags)

proc flushHash*(pool: Sha256Pool): ptr Sha256Job =
  ## Force pool to complete a job.
  return sha256_ctx_mgr_flush(addr pool.mgr)

# sha512

proc doSubmit(mgr: ptr SHA512_HASH_CTX_MGR; ctx: ptr SHA512_HASH_CTX;
              buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX =
  return sha512_ctx_mgr_submit(mgr, ctx, buffer, len, flags)

proc flushHash*(pool: Sha512Pool): ptr Sha512Job =
  ## Force pool to complete a job.
  return sha512_ctx_mgr_flush(addr pool.mgr)

# md5
proc doSubmit(mgr: ptr MD5_HASH_CTX_MGR; ctx: ptr MD5_HASH_CTX;
              buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr MD5_HASH_CTX =
  return md5_ctx_mgr_submit(mgr, ctx, buffer, len, flags)

proc flushHash*(pool: Md5Pool): ptr Md5Job =
  ## Force pool to complete a job.
  return md5_ctx_mgr_flush(addr pool.mgr)


proc submitHash*[MGR, CTX](pool: HasherPool[MGR, CTX], job: ptr Job[MGR, CTX], data: ByteView, kind: HASH_CTX_FLAG): auto =
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
