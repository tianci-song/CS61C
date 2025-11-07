.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    # Prologue

    mv s0, a0
    mv s1, a1
    li t0, 0        # counter
    li t1, 0        # index of the largest number
    lw t2, 0(s0)    # the largest number

loop_start:
    beq t0, s1, loop_end
    lw t3, 0(s0)
    bge t2, t3, loop_continue
    mv t2, t3
    mv t1, t0

loop_continue:
    addi t0, t0, 1
    addi s0, s0, 4
    j loop_start

loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    # Epilogue

    mv a0, t1
    ret
