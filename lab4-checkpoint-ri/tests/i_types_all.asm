addi $0,  $0,  13842 #shouldn't work ($zero should always be zero)
addi $1,  $0, -1
addi $2,  $0,  3
addi $3,  $0, -5
ori  $4,  $0,  7
ori  $5,  $0, -11
xori $6,  $0,  13
xori $7,  $0, -17
ori  $8, $0,   19
ori  $9, $0,  -23
ori  $10, $0,  29
ori  $11, $0, -31
ori  $12, $0,  37
ori  $13, $0, -41
ori  $14, $0,  43
ori  $15, $0, -47
ori  $16, $0,  53
ori  $17, $0,  54
ori  $18, $0,  55
ori  $19, $0,  56
ori  $20, $0,  57
ori  $21, $0,  58
ori  $22, $0,  59
ori  $23, $0,  60
ori  $24, $0,  61
ori  $25, $0,  62
ori  $26, $0,  63
ori  $27, $0,  64
andi $28,  $7, -1
andi $29,  $7,  7
slti $30, $3, 1023
slti $31, $4, -1023
last: j last
#final state
#r00::   $zero::          0
#r01::     $at::         -1
#r02::     $v0::          3
#r03::     $v1::         -5
#r04::     $a0::          7
#r05::     $a1::        -11
#r06::     $a2::         13
#r07::     $a3::        -17
#r08::     $t0::         19
#r09::     $t1::        -23
#r10::     $t2::         29
#r11::     $t3::        -31
#r12::     $t4::         37
#r13::     $t5::        -41
#r14::     $t6::         43
#r15::     $t7::        -47
#r16::     $s0::         53
#r17::     $s1::         54
#r18::     $s2::         55
#r19::     $s3::         56
#r20::     $s4::         57
#r21::     $s5::         58
#r22::     $s6::         59
#r23::     $s7::         60
#r24::     $t8::         61
#r25::     $t9::         62
#r26::     $k0::         63
#r27::     $k1::         64
#r28::     $gp::        -17
#r29::     $sp::          7
#r30::     $fp::          0
#r31::     $ra::          1


