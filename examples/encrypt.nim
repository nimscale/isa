import isa


####### TESTS FOR encryption/decryption (use aes https://github.com/01org/isa-l_crypto)

####enryption TEST on filesystem


#is pseudocode
path=somefileLargerThan1MB
destpath=...
isa.encryptFileAES(path,destpath)


#DECODE test

isa.decryptFileAES(destpath,pathcompare)

#check file on pathcompare=path
