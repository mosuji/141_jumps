addi $s0, $zero, 7
addi $s1, $zero, 9
addi $s2, $zero, 51
addi $s3, $zero, 51
j here
addi $s0, $zero, 0
addi $s1, $zero, 0
addi $s2, $zero, 0
here: bne $s2, $s3, hello #line 0x24
beq $s2, $s3, world
hello: 	addi $s0, $zero, 51 #line 0x2c
j foo
world: 	addi $s1, $zero, 12 #line 0x34
jal hello
foo: 	addi $s2, $zero, 42 #0x3c
addi $s0, $zero, 0
addi $s1, $zero, 0
addi $s2, $zero, 0
jr $ra