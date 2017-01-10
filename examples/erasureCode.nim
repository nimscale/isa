import isa


####### TESTS FOR ERASURE coding

####ENCODE TEST on filesystem


#is pseudocode
path=somefileLargerThan1MB
nrparts=20
redundancy=4 #means any 4 of the parts can be lost
metadata=isa.encodeFile(path,nrparts,redundancy)

#metadata is structure which has paths to parts of result

#DECODE test

pathRestore=somefileLargerThan1MB_restore
isa.decodeFile(metadata,pathRestore)



####ENCODE TEST from data

data=... #binary data 1 MB (buffer?)
nrparts=20
redundancy=4 #means any 4 of the parts can be lost
parts=isa.encode(data,nrparts,redundancy)

#parts is list of the encoded parts

dataRestored= isa.decode(parts, ...)

#check dataRestored=data
