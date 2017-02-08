import isa/aes, collections, collections/views, strutils

var iv = "0".repeat(16)
let ivView = alignedStringView(iv)
echo ivView
let key = expandAESKey("1234567890abcdef")

let input = "abcdef1234567890"
var output = "0".repeat(16)
var output2 = "0".repeat(16)

encryptCbc(key, ivView, input.asUnsafeView, output.asView)
echo output.encodeHex
decryptCbc(key, ivView, output.asView, output2.asView)
echo output2.encodeHex
assert output2.encodeHex == input.encodeHex
