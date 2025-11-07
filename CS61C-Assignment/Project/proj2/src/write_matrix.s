.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:
    
    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)   # heap memory address or reuse as number of elements
    sw ra, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open file
    mv a1, s0       # filename
    li a2, 1        # write only permission
    jal fopen
    li t0, -1
    beq a0, t0, fopen_failure

    # save file descriptor
    mv s4, a0

    # write first 8 bytes to the file
    # first create a buffer by malloc
    li a0, 8        # number of bytes
    jal malloc
    mv s5, a0       # heap memory address
    sw s2, 0(s5)    # store row
    sw s3, 4(s5)    # store col
    
    mv a1, s4       # file desc
    mv a2, s5       # buffer
    li a3, 2        # num of elems
    li a4, 4        # each elem size

    jal fwrite
    li t0, 2
    bne a0, t0, fwrite_failure

    # free the heap
    mv a0, s5
    jal free

    # write the element data to the file
    mv a1, s4       # file desc
    mv a2, s1       # buffer of real data
    mul s5, s2, s3  # save the number of elems
    mv a3, s5
    li a4, 4        # each elem size

    jal fwrite
    bne a0, s5, fwrite_failure

    # close the file
    mv a1, s4       # file desc
    jal fclose
    li t0, -1
    beq a0, t0, fclose_failure

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

    ret

fopen_failure:

    li a1, 93
    j exit2

fwrite_failure:

    li a1, 94
    j exit2

fclose_failure:

    li a1, 95
    j exit2
