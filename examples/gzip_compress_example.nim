import isa/gzip

let c = newDeflateCompressor()
var data = ""
data &= c.compress("hello ")
data &= c.compress("world!")
data &= c.close()

# data now contains deflate compresses "hello world!"
