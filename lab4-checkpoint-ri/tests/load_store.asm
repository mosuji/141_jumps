addi $0, $0, 32 #load all the registers (except $0) with a value.  avoiding the register # is a good call (can catch reg_addr/reg_data wiring mix ups)
addi $1, $0, 33 #python code: print "\n".join(["addi $%d, $0, %d"%(i, -(i+32)) for i in range(32)])
addi $2, $0, 34 
addi $3, $0, 35
addi $4, $0, 36
addi $5, $0, 37
addi $6, $0, 38
addi $7, $0, 39
addi $8, $0, 40
addi $9, $0, 41
addi $10, $0, 42
addi $11, $0, 43
addi $12, $0, 44
addi $13, $0, 45
addi $14, $0, 46
addi $15, $0, 47
addi $16, $0, 48
addi $17, $0, 49
addi $18, $0, 50
addi $19, $0, 51
addi $20, $0, 52
addi $21, $0, 53
addi $22, $0, 54
addi $23, $0, 55
addi $24, $0, 56
addi $25, $0, 57
addi $26, $0, 58
addi $27, $0, 59
addi $28, $0, 60
addi $29, $0, 61
addi $30, $0, 62
addi $31, $0, 63
sw $0, 0x0($0)    #now store each register's value into memory ...
sw $1, 0x4($0)    #python: print "\n".join(["sw $%d, %s($0)"%(i, hex(i*4)) for i in range(32)])
sw $2, 0x8($0)
sw $3, 0xc($0)
sw $4, 0x10($0)
sw $5, 0x14($0)
sw $6, 0x18($0)
sw $7, 0x1c($0)
sw $8, 0x20($0)
sw $9, 0x24($0)
sw $10, 0x28($0)
sw $11, 0x2c($0)
sw $12, 0x30($0)
sw $13, 0x34($0)
sw $14, 0x38($0)
sw $15, 0x3c($0)
sw $16, 0x40($0)
sw $17, 0x44($0)
sw $18, 0x48($0)
sw $19, 0x4c($0)
sw $20, 0x50($0)
sw $21, 0x54($0)
sw $22, 0x58($0)
sw $23, 0x5c($0)
sw $24, 0x60($0)
sw $25, 0x64($0)
sw $26, 0x68($0)
sw $27, 0x6c($0)
sw $28, 0x70($0)
sw $29, 0x74($0)
sw $30, 0x78($0)
sw $31, 0x7c($0)
lw $31, 0x0($0)  # ... and then load them all back in the opposite order
lw $30, 0x4($0)  # print "\n".join(["lw $%d, %s($0)"%(31i, hex(i*4)) for i in range(32)])
lw $29, 0x8($0)
lw $28, 0xc($0)
lw $27, 0x10($0)
lw $26, 0x14($0)
lw $25, 0x18($0)
lw $24, 0x1c($0)
lw $23, 0x20($0)
lw $22, 0x24($0)
lw $21, 0x28($0)
lw $20, 0x2c($0)
lw $19, 0x30($0)
lw $18, 0x34($0)
lw $17, 0x38($0)
lw $16, 0x3c($0)
lw $15, 0x40($0)
lw $14, 0x44($0)
lw $13, 0x48($0)
lw $12, 0x4c($0)
lw $11, 0x50($0)
lw $10, 0x54($0)
lw $9, 0x58($0)
lw $8, 0x5c($0)
lw $7, 0x60($0)
lw $6, 0x64($0)
lw $5, 0x68($0)
lw $4, 0x6c($0)
lw $3, 0x70($0)
lw $2, 0x74($0)
lw $1, 0x78($0)
lw $0, 0x7c($0)
