.data
    num_test: .word 14
    multiplier: .word 9, 9, -9, -9, 0, 10, 0, -10, 0, 1024, 32768, -32768, 32768, -32768
    multiplicand: .word 7, -7, 7, -7, 0, 0, 10, 0, -10, -1024, 32768, -32768, -32768, 32768
    answer: .word 63, -63, -63, 63, 0, 0, 0, 0, 0, -1048576, 1073741824, 1073741824, -1073741824, -1073741824
    next_line: .string "\n"
    output: .string "your result -> "
    output2: .string " , answer -> "
    output_pass: .string "All pass\n"
    output_error: .string "Fail, total has "
    output_error2: .string " error"
.text
main:
    la s0, multiplier               # load multiplier address
    la s1, multiplicand             # load multiplicand address
    la s2, answer                   # Load answer address
    la s3, num_test                 # Load number of test
    lw s3, 0(s3)
    li s5, 0                        # int i = 0
    li s6, 0                        # int error = 0
main_for_loop:
    li s4, 0                        # Initialize accumulator
    ## get test data
    slli t0, s5, 2                  # size = i * 4 byte
    add t1, t0, s0                  # get multiplier[i] address
    lw t1, 0(t1)                    # set t1 = mulitplier[i]
    add t2, t0, s1                  # get multiplicand[i] address
    lw t2, 0(t2)                    # set t1 = mulitplicand[i] 

    ## make multipler positvie
    srai t3, t1, 31                 # t3 = 0xFFFFFFFF if different signed
    bge t1, x0, multiplier_positive # If multiplier positive (#A02)
    neg t1, t1                      # Make multiplier positive

multiplier_positive:
    ## use clz to initialize bit counter (t4)
    add a0, t1, x0                  # pass arguement 

    li t4, 32                       # t4 = 32

    ## do shift_and_add_loop
shift_and_add_loop:
    beq t4, x0, end_shift_and_add   # Exit if bit count is zero
    andi t5, t1, 1                  # Check least significant bit
    beq t5, x0, skip_add            # Skip add if bit is 0
    add s4, s4, t2                  # Add to accumulator

skip_add:
    srai t1, t1, 1                  # Right shift multiplier
    slli t2, t2, 1                  # Left shift multiplicand
    addi t4, t4, -1                 # Decrease bit counter
    jal  x0, shift_and_add_loop     # Repeat loop

end_shift_and_add:
    xor s4, s4, t3
    andi t3, t3, 1
    add s4, s4, t3
    jal ra, print
    addi s5, s5, 1
    blt s5, s3, main_for_loop
main_for_loop_exit:
    beq s6, x0, pass
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
pass:
    la a0, output_pass
    li a7, 4
    ecall
exit:
    li a7, 10
    ecall
print:
    la a0, output
    li a7, 4
    ecall
    add a0, s4, x0
    li a7, 1
    ecall
    la a0, output2
    li a7, 4
    ecall
    add a0, t0, s2
    lw a0, 0(a0)
    li a7, 1
    ecall
    beq a0, s4, correct
    addi s6, s6, 1
correct:
    la a0, next_line
    li a7, 4
    ecall 
    jalr x0, ra, 0
