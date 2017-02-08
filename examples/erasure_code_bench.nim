import isa/erasure_code, collections

var data = @[
  "0".repeat(4096),
  "1".repeat(4096)
]

let coder = newErasureCoder(2, 1) # creating erasure coder is expensive

for i in 0..<100000:
  discard coder.encode(data)
