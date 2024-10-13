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
    jal ra, clz
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
clz:          
    li t0, 0                # int count = 0
    li t1, 31               # int i = 31
    li t2, 1                # set t2 = 1U
    blt t1, x0, loop_exit   # if i < 0, go outside loop
for_loop:
    sll t3, t2, t1          # set t3 = (1U << i)
    and t3, t3, a0          # set t3 = (x & (1U << i))
    bne t3, x0, loop_exit   # if (x & (1U << i) == 1): break
    addi t0, t0, 1          # count++
    ## condition check (j >= 0)
    addi t1, t1, -1         # --i
    bge t1, x0, for_loop    # if (i >= 0) go loop again
loop_exit:
    add a0, t0, x0          # return count
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
