import isa


####### TESTS FOR encryption/decryption

####enryption TEST on filesystem


#is pseudocode
path=somefileLargerThan1MB
destpath=...
isa.encryptFile(path,destpath)

#metadata is structure which has paths to parts of result

#DECODE test

isa.decryptFile(destpath,pathcompare)

#check file on pathcompare=path
