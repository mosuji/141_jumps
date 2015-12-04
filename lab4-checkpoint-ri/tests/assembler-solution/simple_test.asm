addi $s0, $zero, 7
addi $s1, $zero, 9
addi $s2, $zero, 51	#110011
addi $s3, $zero, 51	#110011
bne $s2, $s3, hello
beq $s2, $s3, world
hello: 	addi $s0, $zero, 51	#110011
j foo
world: 	addi $s1, $zero, 12 #001100
jal hello
foo: 	addi $s2, $zero, 42 #101010
addi $s0, $zero, 0
addi $s1, $zero, 0
addi $s2, $zero, 0
jr $ra