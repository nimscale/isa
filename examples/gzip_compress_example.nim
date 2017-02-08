import isa/gzip

let c = newDeflateCompressor()
var data = ""
data &= c.compress("hello ")
data &= c.compress("world!")
data &= c.close()

# data now contains deflate compressed "hello world!"

let d = newInflateDecompressor()
echo "out: " & d.decompress(data[0..2])
echo "out: " & d.decompress(data[3..^1])

let d1 = newInflateDecompressor()
# will throw exception
discard d1.decompress("this is invalid data")
