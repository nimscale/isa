import isa/erasure_code, collections

# We split our data into several chunks of equal size.

var data = @[
  "Lorem ipsum dolor sit amet, consectetur adipiscing ",
  "elit, sed do eiusmod tempor incididunt ut labore et",
  "dolore magna aliqua. Ut enim ad minim veniam, quis ",
  "nostrud exercitation ullamco laboris nisi ut aliqui",
  "ex ea commodo consequat. Duis aute irure dolor in  ",
  "reprehenderit in voluptate velit esse cillum dolore",
  "eu fugiat nulla pariatur. Excepteur sint occaecat  ",
  " cupidatat non proident, sunt in culpa qui officia "
]

let originalData = data

# Now create erasure coder that will add redundancy to the message.
let coder = newErasureCoder(data.len, 2)

# Append code blocks to the message
data &= coder.encode(data)

# Let's simulate some data loss
data[2] = nil
data[4] = nil

# And recover the missing chunks
let recoveredData = coder.decode(data)
assert recoveredData[0] == originalData[2]
assert recoveredData[1] == originalData[4]
