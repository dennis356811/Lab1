.data
    num_test: .word 10
    test: .word 64, 128, 0, 2147483647, 4294967295, -1, -2147483647, 300, 878780422, 920105
    answer: .word 25, 24, 32, 1, 0, 0, 0, 23, 2, 12
    output: .string "your result -> "
    output2: .string " , answer -> "
    next_line: .string "\n"
    output_pass: .string "All pass\n"
    output_error: .string "Fail, total has "
    output_error2: .string " error"
.text

main:
    lw s0, num_test         # loading number of test 
    la s1, test             # loading test data address
    la s2, answer           # loading answer data address
    li s3, 0                # i = 0
    li s6, 0                # int error = 0
    bge s3, s0, main_for_loop_exit 
main_for_loop:            
    slli s4, s3, 2          # set s4 = i * 4 bytes
    add s5, s4, s1          # set s5 = *arr[i]
    lw a0, 0(s5)            # loading test data from memory
    ## do clz function
    jal ra, clz_bs
    ## verification
    add s5, s2, s4          # set s5 = *answer[i]
    lw a1, 0(s5)            # loading answer data from memory
    beq a0, a1, pass
    addi s6, s6, 1
    
pass:
    jal ra, print
    ## i++, check i < num_test
    addi s3, s3, 1
    blt s3, s0, main_for_loop
main_for_loop_exit:
    ## program finish
    beq s6, x0, all_pass
    la a0, output_error
    li a7, 4
    ecall
    add a0, s6, x0
    li a7, 1
    ecall
    la a0, output_error2
    li a7, 4
    ecall
    jal x0, exit
all_pass:
    la a0, output_pass
    li a7, 4
    ecall
exit:
    li a7, 10
    ecall
clz_bs:
    ## save ra
    addi sp, sp, -4         
    sw ra, 0(sp) 
    add t0, x0, x0      # int count = 0
    beq a0, x0, x_zero  # if (x == 0): 
    li t1, 0x0000FFFF   
    bgtu a0, t1, check_8 # if (x <= 0x0000FFFF):
    addi t0, t0, 16     # count += 16
    slli a0, a0, 16     # x <<= 16
check_8:
    li t1, 0x00FFFFFF   
    bgtu a0, t1, check_4 # if (x <= 0x00FFFFFF):
    addi t0, t0, 8      # count += 8
    slli a0, a0, 8      # x <<= 8
check_4:
    li t1, 0x0FFFFFFF   
    bgtu a0, t1, check_2 # if (x <= 0x0FFFFFFF):
    addi t0, t0, 4      # count += 4
    slli a0, a0, 4      # x <<= 4
check_2:
    li t1, 0x3FFFFFFF   
    bgtu a0, t1, check_1 # if (x <= 0x0000FFFF):
    addi t0, t0, 2      # count += 2
    slli a0, a0, 2      # x <<= 2
check_1:
    li t1, 0x7FFFFFFF   
    bgtu a0, t1, end_clz # if (x <= 0x0000FFFF):
    addi t0, t0, 1      # count += 1
    slli a0, a0, 1      # x <<= 1
end_clz:
    add a0, t0, x0      # return count
    ## Retrieved ra
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, ra, 0
x_zero:
    li a0, 32           # return 32
    ## Retrieved ra
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, ra, 0
print:
    ## your result: 
    add a2, a0, x0          # backup a0 result
    la a0, output
    li a7, 4
    ecall
    add a0, a2, x0
    li a7, 1
    ecall
    ## answer: 
    la a0, output2
    li a7, 4
    ecall
    add a0, a1, x0
    li a7, 1
    ecall
    la a0, next_line
    li a7, 4
    ecall
    jalr x0, ra, 0
