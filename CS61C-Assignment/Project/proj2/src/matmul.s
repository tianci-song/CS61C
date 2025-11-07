.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks


    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6

    li t0, 0        # row counter of m0 in outer loop
    li t1, 0        # column counter of m1 in inner loop
    slli t2, s2, 2  # byte offset of starting address of each row vector in m0
    mv t3, s3       # current address of column vector in m1

outer_loop_start:

    beq t0, s1, outer_loop_end 

inner_loop_start:

    beq t1, s5, inner_loop_end

    # Prologue
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)

    mv a0, s0       # arg1: address of current row vector in m0
    mv a1, t3       # arg2: address of current col vector in m1
    mv a2, s2       # arg3: length of vector
    li a3, 1        # arg4: stride of row vector is 1
    mv a4, s5       # arg5: stride of col vector is width of m1

    jal dot         # calling dot()

    # Epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16

    sw a0, 0(s6)    # store the result into destination matrix

    addi t3, t3, 4  # update the address of next column vector in m1 (stride is 1)
    addi s6, s6, 4  # update the address of destination matrix
    addi t1, t1, 1  # add the inner loop counter

    j inner_loop_start

inner_loop_end:

    # reset the inner loop counter and starting address of column vector in m1
    li t1, 0
    mv t3, s3

    # add the outer loop counter(go back to the outer loop)
    addi t0, t0, 1

    # calculate the current starting address of row vector in m0
    add s0, s0, t2

    j outer_loop_start

outer_loop_end:

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    
    ret
