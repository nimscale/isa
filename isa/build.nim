import os, osproc, macros

const basePath = splitPath(currentSourcePath()).head & "/../deps/"

{.passc: "-I" & basePath & "isa-l/include".}
{.passc: "-I" & basePath & "isa-l_crypto/include".}
{.passc: "-I" & basePath & "isa-l_crypto/mh_sha1".}
{.passc: "-I" & basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128".}
{.passc: "-I" & basePath & "isa-l_crypto/aes".}

{.compile: basePath & "isa-l/crc/crc64_base.c" .}
{.compile: basePath & "isa-l/crc/crc_base.c" .}
{.compile: basePath & "isa-l/erasure_code/ec_base.c" .}
{.compile: basePath & "isa-l/erasure_code/ec_highlevel_func.c" .}
{.compile: basePath & "isa-l/igzip/huff_codes.c" .}
{.compile: basePath & "isa-l/igzip/hufftables_c.c" .}
{.compile: basePath & "isa-l/igzip/igzip.c" .}
{.compile: basePath & "isa-l/igzip/igzip_base.c" .}
{.compile: basePath & "isa-l/igzip/igzip_inflate.c" .}
{.compile: basePath & "isa-l/raid/raid_base.c" .}

{.compile: basePath & "isa-l_crypto/aes/cbc_pre.c".}
{.compile: basePath & "isa-l_crypto/aes/gcm_pre.c".}
#{.compile: basePath & "isa-l_crypto/aes/xts_128_rand.c".}
#{.compile: basePath & "isa-l_crypto/aes/xts_256_rand.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_ctx_avx.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_ctx_avx2.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_ctx_avx512.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_ctx_sse.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_mb_mgr_init_avx2.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_mb_mgr_init_avx512.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_mb_mgr_init_sse.c".}
{.compile: basePath & "isa-l_crypto/md5_mb/md5_ref.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1_avx512.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1_block_base.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1_finalize_base.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1_ref.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/mh_sha1_update_base.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1/sha1_for_mh_sha1.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_avx512.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_finalize_base.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_update_base.c".}
{.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/murmur3_x64_128.c".}
# {.compile: basePath & "isa-l_crypto/mh_sha1_murmur3_x64_128/murmur3_x64_128_internal.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_ctx_avx.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_ctx_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_ctx_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_ctx_sse.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_mb_mgr_init_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_mb_mgr_init_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_mb_mgr_init_sse.c".}
{.compile: basePath & "isa-l_crypto/sha1_mb/sha1_ref.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_ctx_avx.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_ctx_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_ctx_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_ctx_sse.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_mb_mgr_init_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_mb_mgr_init_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_mb_mgr_init_sse.c".}
{.compile: basePath & "isa-l_crypto/sha256_mb/sha256_ref.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ctx_avx.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ctx_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ctx_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ctx_sb_sse4.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ctx_sse.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_mb_mgr_init_avx2.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_mb_mgr_init_avx512.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_mb_mgr_init_sse.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_ref.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_sb_mgr_flush_sse4.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_sb_mgr_init_sse4.c".}
{.compile: basePath & "isa-l_crypto/sha512_mb/sha512_sb_mgr_submit_sse4.c".}

var additionalObjects {.compiletime.}: string = ""
const compilationToken = "isa-l=81c8c823cdd26b776cf377ff80eb9c6e46a44ede isa-l_crypto=603529a4e06ac8a1662c13d6b31f122e21830352"
const tokenFile = basePath & "asm_compiled" # this file is used to avoid repeated assembling
const asmCompiled = staticExec("cat " & quoteShell(tokenFile)) == compilationToken

template compileAsm(f) =
  static:
    if not asmCompiled:
      echo "assembling ", f
      let output = staticExec("yasm -i" & quoteShell(basePath & "isa-l/include") & " " &
        " -i" & quoteShell(basePath & "isa-l_crypto/include") & " " &
        quoteShell(basePath & f) & " -felf64 -o " & quoteShell(basePath & f & ".o"))
      if output != "":
        echo output
        error("compilation failed")
    additionalObjects &= " " & quoteShell(basePath & f & ".o")

# isa
compileAsm("isa-l/crc/crc16_t10dif_01.asm")
compileAsm("isa-l/crc/crc16_t10dif_by4.asm")
compileAsm("isa-l/crc/crc32_ieee_01.asm")
compileAsm("isa-l/crc/crc32_ieee_by4.asm")
compileAsm("isa-l/crc/crc32_iscsi_00.asm")
compileAsm("isa-l/crc/crc32_iscsi_01.asm")
compileAsm("isa-l/crc/crc64_ecma_norm_by8.asm")
compileAsm("isa-l/crc/crc64_ecma_refl_by8.asm")
compileAsm("isa-l/crc/crc64_iso_norm_by8.asm")
compileAsm("isa-l/crc/crc64_iso_refl_by8.asm")
compileAsm("isa-l/crc/crc64_jones_norm_by8.asm")
compileAsm("isa-l/crc/crc64_jones_refl_by8.asm")
compileAsm("isa-l/crc/crc64_multibinary.asm")
compileAsm("isa-l/crc/crc_multibinary.asm")
compileAsm("isa-l/erasure_code/ec_multibinary.asm")
compileAsm("isa-l/erasure_code/gf_2vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_2vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_2vect_dot_prod_avx512.asm")
compileAsm("isa-l/erasure_code/gf_2vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_2vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_2vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_2vect_mad_avx512.asm")
compileAsm("isa-l/erasure_code/gf_2vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_3vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_3vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_3vect_dot_prod_avx512.asm")
compileAsm("isa-l/erasure_code/gf_3vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_3vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_3vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_3vect_mad_avx512.asm")
compileAsm("isa-l/erasure_code/gf_3vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_4vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_4vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_4vect_dot_prod_avx512.asm")
compileAsm("isa-l/erasure_code/gf_4vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_4vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_4vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_4vect_mad_avx512.asm")
compileAsm("isa-l/erasure_code/gf_4vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_5vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_5vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_5vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_5vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_5vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_5vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_6vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_6vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_6vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_6vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_6vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_6vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_vect_dot_prod_avx.asm")
compileAsm("isa-l/erasure_code/gf_vect_dot_prod_avx2.asm")
compileAsm("isa-l/erasure_code/gf_vect_dot_prod_avx512.asm")
compileAsm("isa-l/erasure_code/gf_vect_dot_prod_sse.asm")
compileAsm("isa-l/erasure_code/gf_vect_mad_avx.asm")
compileAsm("isa-l/erasure_code/gf_vect_mad_avx2.asm")
compileAsm("isa-l/erasure_code/gf_vect_mad_avx512.asm")
compileAsm("isa-l/erasure_code/gf_vect_mad_sse.asm")
compileAsm("isa-l/erasure_code/gf_vect_mul_avx.asm")
compileAsm("isa-l/erasure_code/gf_vect_mul_sse.asm")
compileAsm("isa-l/igzip/bitbuf2.asm")
compileAsm("isa-l/igzip/crc32_gzip.asm")
compileAsm("isa-l/igzip/crc_data.asm")
#compileAsm("isa-l/igzip/data_struct2.asm")
compileAsm("isa-l/igzip/detect_repeated_char.asm")
compileAsm("isa-l/igzip/huffman.asm")
#compileAsm("isa-l/igzip/igzip_body.asm")
compileAsm("isa-l/igzip/igzip_body_01.asm")
compileAsm("isa-l/igzip/igzip_body_02.asm")
compileAsm("isa-l/igzip/igzip_body_04.asm")
compileAsm("isa-l/igzip/igzip_compare_types.asm")
#compileAsm("isa-l/igzip/igzip_decode_block_stateless.asm")
compileAsm("isa-l/igzip/igzip_decode_block_stateless_01.asm")
compileAsm("isa-l/igzip/igzip_decode_block_stateless_04.asm")
compileAsm("isa-l/igzip/igzip_finish.asm")
compileAsm("isa-l/igzip/igzip_inflate_multibinary.asm")
compileAsm("isa-l/igzip/igzip_multibinary.asm")
#compileAsm("isa-l/igzip/igzip_update_histogram.asm")
compileAsm("isa-l/igzip/igzip_update_histogram_01.asm")
compileAsm("isa-l/igzip/igzip_update_histogram_04.asm")
#compileAsm("isa-l/igzip/inflate_data_structs.asm")
compileAsm("isa-l/igzip/options.asm")
compileAsm("isa-l/igzip/rfc1951_lookup.asm")
compileAsm("isa-l/igzip/stdmac.asm")
compileAsm("isa-l/raid/pq_check_sse.asm")
# compileAsm("isa-l/raid/pq_check_sse_i32.asm")
compileAsm("isa-l/raid/pq_gen_avx.asm")
compileAsm("isa-l/raid/pq_gen_avx2.asm")
compileAsm("isa-l/raid/pq_gen_sse.asm")
# compileAsm("isa-l/raid/pq_gen_sse_i32.asm")
compileAsm("isa-l/raid/raid_multibinary.asm")
compileAsm("isa-l/raid/xor_check_sse.asm")
compileAsm("isa-l/raid/xor_gen_avx.asm")
compileAsm("isa-l/raid/xor_gen_sse.asm")

# isa crypto

compileAsm("isa-l_crypto/aes/XTS_AES_128_dec_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_dec_expanded_key_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_dec_expanded_key_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_dec_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_enc_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_enc_expanded_key_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_enc_expanded_key_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_128_enc_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_dec_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_dec_expanded_key_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_dec_expanded_key_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_dec_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_enc_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_enc_expanded_key_avx.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_enc_expanded_key_sse.asm")
compileAsm("isa-l_crypto/aes/XTS_AES_256_enc_sse.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_128_x4_sse.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_128_x8_avx.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_192_x4_sse.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_192_x8_avx.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_256_x4_sse.asm")
compileAsm("isa-l_crypto/aes/cbc_dec_256_x8_avx.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_128_x4_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_128_x8_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_192_x4_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_192_x8_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_256_x4_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_enc_256_x8_sb.asm")
compileAsm("isa-l_crypto/aes/cbc_multibinary.asm")
compileAsm("isa-l_crypto/aes/gcm128_avx_gen2.asm")
compileAsm("isa-l_crypto/aes/gcm128_avx_gen4.asm")
compileAsm("isa-l_crypto/aes/gcm128_sse.asm")
compileAsm("isa-l_crypto/aes/gcm256_avx_gen2.asm")
compileAsm("isa-l_crypto/aes/gcm256_avx_gen4.asm")
compileAsm("isa-l_crypto/aes/gcm256_sse.asm")
compileAsm("isa-l_crypto/aes/gcm_defines.asm")
compileAsm("isa-l_crypto/aes/gcm_multibinary.asm")
compileAsm("isa-l_crypto/aes/keyexp_128.asm")
compileAsm("isa-l_crypto/aes/keyexp_192.asm")
compileAsm("isa-l_crypto/aes/keyexp_256.asm")
compileAsm("isa-l_crypto/aes/keyexp_multibinary.asm")
compileAsm("isa-l_crypto/aes/xts_aes_128_multibinary.asm")
compileAsm("isa-l_crypto/aes/xts_aes_256_multibinary.asm")
compileAsm("isa-l_crypto/include/datastruct.asm")
compileAsm("isa-l_crypto/include/memcpy.asm")
compileAsm("isa-l_crypto/include/multibinary.asm")
compileAsm("isa-l_crypto/include/reg_sizes.asm")
compileAsm("isa-l_crypto/md5_mb/md5_job.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_datastruct.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_flush_avx.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_flush_avx2.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_flush_avx512.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_flush_sse.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_submit_avx.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_submit_avx2.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_submit_avx512.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_mgr_submit_sse.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_x16x2_avx512.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_x4x2_avx.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_x4x2_sse.asm")
compileAsm("isa-l_crypto/md5_mb/md5_mb_x8x2_avx2.asm")
compileAsm("isa-l_crypto/md5_mb/md5_multibinary.asm")
compileAsm("isa-l_crypto/mh_sha1/mh_sha1_block_avx.asm")
compileAsm("isa-l_crypto/mh_sha1/mh_sha1_block_avx2.asm")
compileAsm("isa-l_crypto/mh_sha1/mh_sha1_block_avx512.asm")
compileAsm("isa-l_crypto/mh_sha1/mh_sha1_block_sse.asm")
compileAsm("isa-l_crypto/mh_sha1/mh_sha1_multibinary.asm")
compileAsm("isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_block_avx.asm")
compileAsm("isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_block_avx2.asm")
compileAsm("isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_block_avx512.asm")
compileAsm("isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_block_sse.asm")
compileAsm("isa-l_crypto/mh_sha1_murmur3_x64_128/mh_sha1_murmur3_x64_128_multibinary.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_job.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_datastruct.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_flush_avx.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_flush_avx2.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_flush_avx512.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_flush_sse.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_submit_avx.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_submit_avx2.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_submit_avx512.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_mgr_submit_sse.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_x16_avx512.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_x4_avx.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_x4_sse.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_mb_x8_avx2.asm")
compileAsm("isa-l_crypto/sha1_mb/sha1_multibinary.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_job.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_datastruct.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_flush_avx.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_flush_avx2.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_flush_avx512.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_flush_sse.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_submit_avx.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_submit_avx2.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_submit_avx512.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_mgr_submit_sse.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_x16_avx512.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_x4_avx.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_x4_sse.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_mb_x8_avx2.asm")
compileAsm("isa-l_crypto/sha256_mb/sha256_multibinary.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_job.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_datastruct.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_flush_avx.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_flush_avx2.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_flush_avx512.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_flush_sse.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_submit_avx.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_submit_avx2.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_submit_avx512.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_mgr_submit_sse.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_x2_avx.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_x2_sse.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_x4_avx2.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_mb_x8_avx512.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_multibinary.asm")
compileAsm("isa-l_crypto/sha512_mb/sha512_sse4.asm")


{.passl: additionalObjects.}

static:
  if not asmCompiled:
    discard staticExec("echo " & quoteShell(compilationToken) & " > " & quoteShell(tokenFile))
