import isa


####### TESTS FOR compression/decompression (https://github.com/01org/isa-l/tree/master/igzip)



#is pseudocode
path=somefileLargerThan1MB
destpath=...
isa.compress(path,destpath)


isa.decompress(destpath,pathcompare)

#check file on pathcompare=path
