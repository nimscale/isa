import isa/raid, collections, collections/views

let data = allocShared0(4096)
let dataView = ByteView(data: data, size: 96)
let dataSrc = "0000000000000000000000000000000011111111111111111111111111111111"
dataView.copyFrom(dataSrc.asUnsafeView)

var blocks = @[dataView.slice(0, 32).data,
               dataView.slice(32, 32).data,
               dataView.slice(64, 32).data]
generateXor(32, blocks.asView)

assert checkXor(32, blocks.asView)
dataView[0] = byte('5')
assert(not checkXor(32, blocks.asView))
echo(dataView.copyAsString.encodeHex)
