import isa/build, isa/raw_crc, isa/raw_crc64, collections/views

proc crc16_t10dir*(buf: ByteView, initial: uint16): uint16 =
  ## Compute CRC16 from T10 standard.
  return crc16_t10dif(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc32_ieee*(buf: ByteView, initial: uint32): uint32 =
  ## Compute CRC32 from IEEE standard.
  return crc32_ieee(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc32_iscsi*(buf: ByteView, initial: uint32): uint32 =
  ## Compute CRC32 from iSCSI.
  return crc32_iscsi(cast[ptr cuchar](buf.data), buf.len.cint, initial)

proc crc64_jones_norm*(buf: ByteView, initial: uint64): uint64 =
  ## Compute "Jones" CRC64 in normal form.
  return crc64_jones_norm(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc64_iso_norm*(buf: ByteView, initial: uint64): uint64 =
  ## Compute ISO CRC64 in normal form.
  return crc64_iso_norm(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc64_ecma_norm*(buf: ByteView, initial: uint64): uint64 =
  ## Compute ECMA-182 CRC64 in normal form.
  return crc64_ecma_norm(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc64_jones_refl*(buf: ByteView, initial: uint64): uint64 =
  ## Compute "Jones" CRC64 in reflected form.
  return crc64_jones_refl(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc64_iso_refl*(buf: ByteView, initial: uint64): uint64 =
  ## Compute ISO CRC64 in reflected form.
  return crc64_iso_refl(initial, cast[ptr cuchar](buf.data), buf.len.uint64)

proc crc64_ecma_refl*(buf: ByteView, initial: uint64): uint64 =
  ## Compute ECMA-182 CRC64 in reflected form.
  return crc64_ecma_refl(initial, cast[ptr cuchar](buf.data), buf.len.uint64)
