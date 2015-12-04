addi $s0, $zero, 0x40001c 	#line 7 - 1st
addi $s1, $zero, 0x400024	#line 9 - 3rd
addi $s2, $zero, 0x400014	#line 5 - 2nd
jr $s0
addi $s0, $zero, 31 #011111
jr $s1
addi $s1, $zero, 36	#100100
jr $s2
addi $s2, $zero, 51	#110011
addi $s3, $zero, 51	#110011
bne $s2, $s3, hello
beq $s2, $s3, world
hello: 	addi $s0, $zero, 51	#110011 - skipped initially
j foo
world: 	addi $s1, $zero, 12 #001100
jal hello
foo: 	addi $s2, $zero, 42 #101010