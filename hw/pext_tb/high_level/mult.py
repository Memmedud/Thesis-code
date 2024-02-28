
opA = -0x800F_08a3
opB = 0x0000_0125

# Generate true results
trueResult32 = opA * opB
trueResult16 = [((opA & 0xFFFF_0000) >> 16) * ((opB & 0xFFFF_0000) >> 16), 
                ((opA & 0x0000_FFFF) >> 0 ) * ((opB & 0x0000_FFFF) >> 0)]
trueResult8  = [((opA & 0xFF00_0000) >> 24) * ((opB & 0xFF00_0000) >> 24),
                ((opA & 0x00FF_0000) >> 16) * ((opB & 0x00FF_0000) >> 16),
                ((opA & 0x0000_FF00) >> 8)  * ((opB & 0x0000_FF00) >> 8),
                ((opA & 0x0000_00FF) >> 0)  * ((opB & 0x0000_00FF) >> 0),]

print(hex(trueResult32))
print(hex(trueResult16[0]), hex(trueResult16[1]))
print(hex(trueResult8[0]), hex(trueResult8[1]), hex(trueResult8[2]), hex(trueResult8[3]))

A0 = opA & 0xFF
B0 = opB & 0xFF
A1 = (opA & 0xFF00) >> 8
B1 = (opB & 0xFF00) >> 8
A2 = (opA & 0xFF0000) >> 16
B2 = (opB & 0xFF0000) >> 16
A3 = (opA & 0xFF000000) >> 24
B3 = (opB & 0xFF000000) >> 24

sum00 = A0*B0
sum10 = A1*B0
sum20 = A2*B0
sum30 = A3*B0

sum01 = A0*B1
sum11 = A1*B1
sum21 = A2*B1
sum31 = A3*B1

sum02 = A0*B2
sum12 = A1*B2
sum22 = A2*B2
sum32 = A3*B2

sum03 = A0*B3
sum13 = A1*B3
sum23 = A2*B3
sum33 = A3*B3

# 8x8-bit
print(hex(sum33), hex(sum22), hex(sum11), hex(sum00))

#print one qudrant
print(hex(sum33), hex(sum32), hex(sum23), hex(sum22))

# 16x16-bit
sum16_00 = (sum00 + (sum01 << 8)) + (((sum10 << 8) + (sum11 << 16)))
sum16_11 = (sum22 + (sum23 << 8)) + (((sum32 << 8) + (sum33 << 16))) + (sum22 & 0xFF)


sum16_11 = (sum22 & 0xFF) + (((sum33 + ((sum32 & 0xFF00) >> 8)) << 8 + (sum32 & 0xFF)) << 8) + ((sum33 + ((sum32 & 0xFF00) >> 8)) << 8 + (sum22 & 0xFF))
print(hex(sum16_11), hex(sum16_00))

# 32x32-bit
sum16_01 = (sum20 + (sum21 << 8)) + (((sum30 << 8) + (sum31 << 16)))
sum16_10 = (sum02 + (sum12 << 8)) + (((sum03 << 8) + (sum13 << 16)))

sum32 = sum16_00 + (sum16_01 << 16) + (sum16_10 << 16) + (sum16_11 << 32)
print(hex(sum32))

# 32x16-bit
sum24_0 = sum16_00 + (sum16_01 << 16)
sum24_1 = sum16_10 + (sum16_11 << 16)
print(hex(sum24_1), hex(sum24_0))