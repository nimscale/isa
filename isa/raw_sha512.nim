## *********************************************************************
##   Copyright(c) 2011-2016 Intel Corporation All rights reserved.
## 
##   Redistribution and use in source and binary forms, with or without
##   modification, are permitted provided that the following conditions 
##   are met:
##  Redistributions of source code must retain the above copyright
##       notice, this list of conditions and the following disclaimer.
##  Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in
##       the documentation and/or other materials provided with the
##       distribution.
##  Neither the name of Intel Corporation nor the names of its
##       contributors may be used to endorse or promote products derived
##       from this software without specific prior written permission.
## 
##   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
##   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
##   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## ********************************************************************

## *
##   @file sha512_mb.h
##   @brief Single/Multi-buffer CTX API SHA512 function prototypes and structures
## 
##  Interface for single and multi-buffer SHA512 functions
## 
##  <b> Single/Multi-buffer SHA512  Entire or First-Update..Update-Last </b>
## 
##  The interface to this single/multi-buffer hashing code is carried out through the
##  context-level (CTX) init, submit and flush functions and the SHA512_HASH_CTX_MGR and
##  SHA512_HASH_CTX objects. Numerous SHA512_HASH_CTX objects may be instantiated by the
##  application for use with a single SHA512_HASH_CTX_MGR.
## 
##  The CTX interface functions carry out the initialization and padding of the jobs
##  entered by the user and add them to the multi-buffer manager. The lower level "scheduler"
##  layer then processes the jobs in an out-of-order manner. The scheduler layer functions
##  are internal and are not intended to be invoked directly. Jobs can be submitted
##  to a CTX as a complete buffer to be hashed, using the HASH_ENTIRE flag, or as partial
##  jobs which can be started using the HASH_FIRST flag, and later resumed or finished
##  using the HASH_UPDATE and HASH_LAST flags respectively.
## 
##  <b>Note:</b> The submit function does not require data buffers to be block sized.
## 
##  The SHA512 CTX interface functions are available for 5 architectures: multi-buffer SSE,
##  AVX, AVX2, AVX512 and single-buffer SSE4 (which is used in the same way as the
##  multi-buffer code). In addition, a multibinary interface is provided, which selects the
##  appropriate architecture-specific function at runtime. This multibinary interface
##  selects the single buffer SSE4 functions when the platform is detected to be Silvermont.
## 
##  <b>Usage:</b> The application creates a SHA512_HASH_CTX_MGR object and initializes it
##  with a call to sha512_ctx_mgr_init*() function, where henceforth "*" stands for the
##  relevant suffix for each architecture; _sse, _avx, _avx2, _avx512(or no suffix for the
##  multibinary version). The SHA512_HASH_CTX_MGR object will be used to schedule processor
##  resources, with up to 2 SHA512_HASH_CTX objects (or 4 in the AVX2 case, 8 in the AVX512
##  case) being processed at a time.
## 
##  Each SHA512_HASH_CTX must be initialized before first use by the hash_ctx_init macro
##  defined in multi_buffer.h. After initialization, the application may begin computing
##  a hash by giving the SHA512_HASH_CTX to a SHA512_HASH_CTX_MGR using the submit functions
##  sha512_ctx_mgr_submit*() with the HASH_FIRST flag set. When the SHA512_HASH_CTX is
##  returned to the application (via this or a later call to sha512_ctx_mgr_submit*() or
##  sha512_ctx_mgr_flush*()), the application can then re-submit it with another call to
##  sha512_ctx_mgr_submit*(), but without the HASH_FIRST flag set.
## 
##  Ideally, on the last buffer for that hash, sha512_ctx_mgr_submit_sse is called with
##  HASH_LAST, although it is also possible to submit the hash with HASH_LAST and a zero
##  length if necessary. When a SHA512_HASH_CTX is returned after having been submitted with
##  HASH_LAST, it will contain a valid hash. The SHA512_HASH_CTX can be reused immediately
##  by submitting with HASH_FIRST.
## 
##  For example, you would submit hashes with the following flags for the following numbers
##  of buffers:
##  <ul>
##   <li> one buffer: HASH_FIRST | HASH_LAST  (or, equivalently, HASH_ENTIRE)
##   <li> two buffers: HASH_FIRST, HASH_LAST
##   <li> three buffers: HASH_FIRST, HASH_UPDATE, HASH_LAST
##  etc.
##  </ul>
## 
##  The order in which SHA512_CTX objects are returned is in general different from the order
##  in which they are submitted.
## 
##  A few possible error conditions exist:
##  <ul>
##   <li> Submitting flags other than the allowed entire/first/update/last values
##   <li> Submitting a context that is currently being managed by a SHA512_HASH_CTX_MGR. (Note:
##    This error case is not applicable to the single buffer SSE4 version)
##   <li> Submitting a context after HASH_LAST is used but before HASH_FIRST is set.
##  </ul>
## 
##   These error conditions are reported by returning the SHA512_HASH_CTX immediately after
##   a submit with its error member set to a non-zero error code (defined in
##   multi_buffer.h). No changes are made to the SHA512_HASH_CTX_MGR in the case of an
##   error; no processing is done for other hashes.
## 
## 

import
  isa/raw_multi_buffer

const
  SHA512_DIGEST_NWORDS* = 8
  SHA512_MAX_LANES* = 8
  SHA512_X4_LANES* = 4
  SHA512_MIN_LANES* = 2
  SHA512_BLOCK_SIZE* = 128
  SHA512_LOG2_BLOCK_SIZE* = 7
  SHA512_PADLENGTHFIELD_SIZE* = 16

type
  sha512_digest_array* = array[SHA512_DIGEST_NWORDS,
                             array[SHA512_MAX_LANES, uint64]]
  SHA512_WORD_T* = uint64

## * @brief Scheduler layer - Holds info describing a single SHA512 job for the multi-buffer manager

type
  SHA512_JOB* {.importc: "SHA512_JOB", header: "sha512_mb.h".} = object
    buffer* {.importc: "buffer".}: ptr uint8 ## !< pointer to data buffer for this job
    len* {.importc: "len".}: uint64 ## !< length of buffer for this job in blocks.
    result_digest* {.importc: "result_digest".}: array[SHA512_DIGEST_NWORDS, uint64]
    status* {.importc: "status".}: JOB_STS ## !< output job status
    user_data* {.importc: "user_data".}: pointer ## !< pointer for user's job-related data
  

## * @brief Scheduler layer -  Holds arguments for submitted SHA512 job

type
  SHA512_MB_ARGS_X8* {.importc: "SHA512_MB_ARGS_X8", header: "sha512_mb.h".} = object
    digest* {.importc: "digest".}: sha512_digest_array
    data_ptr* {.importc: "data_ptr".}: array[SHA512_MAX_LANES, ptr uint8]


## * @brief Scheduler layer - Lane data

type
  SHA512_LANE_DATA* {.importc: "SHA512_LANE_DATA", header: "sha512_mb.h".} = object
    job_in_lane* {.importc: "job_in_lane".}: ptr SHA512_JOB


## * @brief Scheduler layer - Holds state for multi-buffer SHA512 jobs

type
  SHA512_MB_JOB_MGR* {.importc: "SHA512_MB_JOB_MGR", header: "sha512_mb.h".} = object
    args* {.importc: "args".}: SHA512_MB_ARGS_X8
    lens* {.importc: "lens".}: array[SHA512_MAX_LANES, uint64]
    unused_lanes* {.importc: "unused_lanes".}: uint64 ## !< each byte is index (00, 01 or 00...03) of unused lanes, byte 2 or 4 is set to FF as a flag
    ldata* {.importc: "ldata".}: array[SHA512_MAX_LANES, SHA512_LANE_DATA]
    num_lanes_inuse* {.importc: "num_lanes_inuse".}: uint32


## * @brief Context layer - Holds state for multi-buffer SHA512 jobs

type
  SHA512_HASH_CTX_MGR* {.importc: "SHA512_HASH_CTX_MGR", header: "sha512_mb.h".} = object
    mgr* {.importc: "mgr".}: SHA512_MB_JOB_MGR


## * @brief Context layer - Holds info describing a single SHA512 job for the multi-buffer CTX manager

type
  SHA512_HASH_CTX* {.importc: "SHA512_HASH_CTX", header: "sha512_mb.h".} = object
    job* {.importc: "job".}: SHA512_JOB ##  Must be at struct offset 0.
    status* {.importc: "status".}: HASH_CTX_STS ## !< Context status flag
    error* {.importc: "error".}: HASH_CTX_ERROR ## !< Context error flag
    total_length* {.importc: "total_length".}: uint32 ## !< Running counter of length processed for this CTX's job
    incoming_buffer* {.importc: "incoming_buffer".}: pointer ## !< pointer to data input buffer for this CTX's job
    incoming_buffer_length* {.importc: "incoming_buffer_length".}: uint32 ## !< length of buffer for this job in bytes.
    partial_block_buffer* {.importc: "partial_block_buffer".}: array[
        SHA512_BLOCK_SIZE * 2, uint8] ## !< CTX partial blocks
    partial_block_buffer_length* {.importc: "partial_block_buffer_length".}: uint32
    user_data* {.importc: "user_data".}: pointer ## !< pointer for user to keep any job-related data
  

## ******************************************************************
##  Context level API function prototypes
## ****************************************************************
## *
##  @brief Initialize the context level SHA512 multi-buffer manager structure.
##  @requires SSE4.1
## 
##  @param mgr Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init_sse*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init_sse", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the context level multi-buffer manager.
##  @requires SSE4.1
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit_sse*(mgr: ptr SHA512_HASH_CTX_MGR;
                               ctx: ptr SHA512_HASH_CTX; buffer: pointer;
                               len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit_sse", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires SSE4.1
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush_sse*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_flush_sse", header: "sha512_mb.h".}
## *
##  @brief Initialize the SHA512 multi-buffer manager structure.
##  @requires AVX
## 
##  @param mgr Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init_avx*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init_avx", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the multi-buffer manager.
##  @requires AVX
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit_avx*(mgr: ptr SHA512_HASH_CTX_MGR;
                               ctx: ptr SHA512_HASH_CTX; buffer: pointer;
                               len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit_avx", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires AVX
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush_avx*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_flush_avx", header: "sha512_mb.h".}
## *
##  @brief Initialize the SHA512 multi-buffer manager structure.
##  @requires AVX2
## 
##  @param mgr	Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init_avx2*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init_avx2", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the multi-buffer manager.
##  @requires AVX2
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit_avx2*(mgr: ptr SHA512_HASH_CTX_MGR;
                                ctx: ptr SHA512_HASH_CTX; buffer: pointer;
                                len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit_avx2", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires AVX2
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush_avx2*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_flush_avx2", header: "sha512_mb.h".}
## *
##  @brief Initialize the SHA512 multi-buffer manager structure.
##  @requires AVX512
## 
##  @param mgr	Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init_avx512*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init_avx512", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the multi-buffer manager.
##  @requires AVX512
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit_avx512*(mgr: ptr SHA512_HASH_CTX_MGR;
                                  ctx: ptr SHA512_HASH_CTX; buffer: pointer;
                                  len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit_avx512", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires AVX512
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush_avx512*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_flush_avx512", header: "sha512_mb.h".}
## *
##  @brief Initialize the SHA512 multi-buffer manager structure.
##  @requires SSE4
## 
##  @param mgr	Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init_sb_sse4*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init_sb_sse4", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the multi-buffer manager.
##  @requires SSE4
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit_sb_sse4*(mgr: ptr SHA512_HASH_CTX_MGR;
                                   ctx: ptr SHA512_HASH_CTX; buffer: pointer;
                                   len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit_sb_sse4", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires SSE4
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush_sb_sse4*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_flush_sb_sse4", header: "sha512_mb.h".}
## ******************* multibinary function prototypes *********************
## *
##  @brief Initialize the SHA512 multi-buffer manager structure.
##  @requires SSE4.1 or AVX or AVX2 or AVX512
## 
##  @param mgr	Structure holding context level state info
##  @returns void
## 

proc sha512_ctx_mgr_init*(mgr: ptr SHA512_HASH_CTX_MGR) {.cdecl,
    importc: "sha512_ctx_mgr_init", header: "sha512_mb.h".}
## *
##  @brief  Submit a new SHA512 job to the multi-buffer manager.
##  @requires SSE4.1 or AVX or AVX2 or AVX512
## 
##  @param  mgr Structure holding context level state info
##  @param  ctx Structure holding ctx job info
##  @param  buffer Pointer to buffer to be processed
##  @param  len Length of buffer (in bytes) to be processed
##  @param  flags Input flag specifying job type (first, update, last or entire)
##  @returns NULL if no jobs complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_submit*(mgr: ptr SHA512_HASH_CTX_MGR; ctx: ptr SHA512_HASH_CTX;
                           buffer: pointer; len: uint32; flags: HASH_CTX_FLAG): ptr SHA512_HASH_CTX {.
    cdecl, importc: "sha512_ctx_mgr_submit", header: "sha512_mb.h".}
## *
##  @brief Finish all submitted SHA512 jobs and return when complete.
##  @requires SSE4.1 or AVX or AVX2 or AVX512
## 
##  @param mgr	Structure holding context level state info
##  @returns NULL if no jobs to complete or pointer to jobs structure.
## 

proc sha512_ctx_mgr_flush*(mgr: ptr SHA512_HASH_CTX_MGR): ptr SHA512_HASH_CTX {.cdecl,
    importc: "sha512_ctx_mgr_flush", header: "sha512_mb.h".}
## ******************************************************************
##  Scheduler (internal) level out-of-order function prototypes
## ****************************************************************

proc sha512_mb_mgr_init_sse*(state: ptr SHA512_MB_JOB_MGR) {.cdecl,
    importc: "sha512_mb_mgr_init_sse", header: "sha512_mb.h".}
proc sha512_mb_mgr_submit_sse*(state: ptr SHA512_MB_JOB_MGR; job: ptr SHA512_JOB): ptr SHA512_JOB {.
    cdecl, importc: "sha512_mb_mgr_submit_sse", header: "sha512_mb.h".}
proc sha512_mb_mgr_flush_sse*(state: ptr SHA512_MB_JOB_MGR): ptr SHA512_JOB {.cdecl,
    importc: "sha512_mb_mgr_flush_sse", header: "sha512_mb.h".}
const
  sha512_mb_mgr_init_avx* = sha512_mb_mgr_init_sse

proc sha512_mb_mgr_submit_avx*(state: ptr SHA512_MB_JOB_MGR; job: ptr SHA512_JOB): ptr SHA512_JOB {.
    cdecl, importc: "sha512_mb_mgr_submit_avx", header: "sha512_mb.h".}
proc sha512_mb_mgr_flush_avx*(state: ptr SHA512_MB_JOB_MGR): ptr SHA512_JOB {.cdecl,
    importc: "sha512_mb_mgr_flush_avx", header: "sha512_mb.h".}
proc sha512_mb_mgr_init_avx2*(state: ptr SHA512_MB_JOB_MGR) {.cdecl,
    importc: "sha512_mb_mgr_init_avx2", header: "sha512_mb.h".}
proc sha512_mb_mgr_submit_avx2*(state: ptr SHA512_MB_JOB_MGR; job: ptr SHA512_JOB): ptr SHA512_JOB {.
    cdecl, importc: "sha512_mb_mgr_submit_avx2", header: "sha512_mb.h".}
proc sha512_mb_mgr_flush_avx2*(state: ptr SHA512_MB_JOB_MGR): ptr SHA512_JOB {.cdecl,
    importc: "sha512_mb_mgr_flush_avx2", header: "sha512_mb.h".}
proc sha512_mb_mgr_init_avx512*(state: ptr SHA512_MB_JOB_MGR) {.cdecl,
    importc: "sha512_mb_mgr_init_avx512", header: "sha512_mb.h".}
proc sha512_mb_mgr_submit_avx512*(state: ptr SHA512_MB_JOB_MGR; job: ptr SHA512_JOB): ptr SHA512_JOB {.
    cdecl, importc: "sha512_mb_mgr_submit_avx512", header: "sha512_mb.h".}
proc sha512_mb_mgr_flush_avx512*(state: ptr SHA512_MB_JOB_MGR): ptr SHA512_JOB {.
    cdecl, importc: "sha512_mb_mgr_flush_avx512", header: "sha512_mb.h".}
##  Single buffer SHA512 APIs, optimized for SLM.

proc sha512_sse4*(M: pointer; D: pointer; L: uint64) {.cdecl, importc: "sha512_sse4",
    header: "sha512_mb.h".}
##  Note that these APIs comply with multi-buffer APIs' high level usage

proc sha512_sb_mgr_init_sse4*(state: ptr SHA512_MB_JOB_MGR) {.cdecl,
    importc: "sha512_sb_mgr_init_sse4", header: "sha512_mb.h".}
proc sha512_sb_mgr_submit_sse4*(state: ptr SHA512_MB_JOB_MGR; job: ptr SHA512_JOB): ptr SHA512_JOB {.
    cdecl, importc: "sha512_sb_mgr_submit_sse4", header: "sha512_mb.h".}
proc sha512_sb_mgr_flush_sse4*(state: ptr SHA512_MB_JOB_MGR): ptr SHA512_JOB {.cdecl,
    importc: "sha512_sb_mgr_flush_sse4", header: "sha512_mb.h".}
