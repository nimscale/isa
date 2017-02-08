import isa/build, isa/raw_aes_keyexp, isa/raw_aes_gcm, isa/raw_aes_cbc, collections/views

type
  AESKey = ref object
    length: int
    enc: array[256, uint8]
    dec: array[256, uint8]

proc expandAESKey*(key: string): AESKey =
  ## Expands AES-128/192/256 key.
  new(result)
  result.length = key.len
  case key.len:
  of 16:
    aes_keyexp_128(cast[ptr uint8](unsafeAddr key[0]), addr result.enc[0], addr result.dec[0])
  of 24:
    aes_keyexp_192(cast[ptr uint8](unsafeAddr key[0]), addr result.enc[0], addr result.dec[0])
  of 32:
    aes_keyexp_256(cast[ptr uint8](unsafeAddr key[0]), addr result.enc[0], addr result.dec[0])
  else:
    raise newException(Exception, "bad key size")

proc encryptCbc*(key: AESKey, iv: ByteView, input: ByteView, output: ByteView) =
  ## Encrypt data from ``input`` to ``output`` using ``iv`` as IV. IV should be aligned to 16-bytes.
  assert input.len == output.len and input.len mod 16 == 0 and iv.len == 16
  case key.length:
  of 16:
    discard aes_cbc_enc_128(input.data, cast[ptr uint8](iv.data), addr key.enc[0], output.data, input.len.uint64)
  of 24:
    discard aes_cbc_enc_192(input.data, cast[ptr uint8](iv.data), addr key.enc[0], output.data, input.len.uint64)
  of 32:
    discard aes_cbc_enc_256(input.data, cast[ptr uint8](iv.data), addr key.enc[0], output.data, input.len.uint64)
  else:
    doAssert(false)

proc decryptCbc*(key: AESKey, iv: ByteView, input: ByteView, output: ByteView) =
  ## Decrypt data from ``input`` to ``output`` using ``iv`` as IV. IV should be aligned to 16-bytes.
  assert input.len == output.len and input.len mod 16 == 0 and iv.len == 16
  case key.length:
  of 16:
    aes_cbc_dec_128(input.data, cast[ptr uint8](iv.data), addr key.dec[0], output.data, input.len.uint64)
  of 24:
    aes_cbc_dec_192(input.data, cast[ptr uint8](iv.data), addr key.dec[0], output.data, input.len.uint64)
  of 32:
    aes_cbc_dec_256(input.data, cast[ptr uint8](iv.data), addr key.dec[0], output.data, input.len.uint64)
  else:
    doAssert(false)
