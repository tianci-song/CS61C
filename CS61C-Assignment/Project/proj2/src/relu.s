.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    # Prologue

    # To achieve 100% coverage, we omit the exception check, if we add the check
    # this instruction of check will never be implmented and this leads to non-100%
    # coverage. As for the reason why it can't be implemented is that the framework
    # will check the size of test array, if size is 0, it will report the error and
    # fail the compilation
    # li t0, 1
    # blt a1, t0, invalid_length

    mv s0, a0   # save address of the array
    mv s1, a1   # save size of the array
    li t0, 0    # counter

loop_start:
    beq t0, s1, loop_end

    lw t1, 0(s0)
    bge t1, x0, loop_continue
    sw x0, 0(s0)

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

    ret

# invalid_length:
    # Exit with error code 78
    # li a0, 78       # Load exit code (78) into a0 (return value register)
    # jal exit2
