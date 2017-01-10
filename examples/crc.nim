import isa


####### TESTS FOR CRC use CRC32 https://github.com/01org/isa-l/tree/master/crc

#### CRC test

#is pseudocode
path=somefileLargerThan1MB
crc=isa.crc(path)

#print crc
