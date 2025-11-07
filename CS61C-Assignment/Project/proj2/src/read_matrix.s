.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28	
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)       # file descriptor
    sw s4, 16(sp)       # heap memory address
    sw s5, 20(sp)       # number of bytes
    sw ra, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # open the matrix binary file
    mv a1, s0   # filename
    li a2, 0    # read only
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error

    # save the file descriptor
    mv s3, a0           

    # read the first 8 bytes from the file
    li a0, 8            # allocate 8 bytes
    jal malloc
    beq a0, x0, malloc_error

    mv s4, a0           # save the buffer
    mv a1, s3           # arg1: file descriptor
    mv a2, s4           # arg2: read info into this buffer
    li a3, 8            # number of bytes to be read

    jal fread

    li t0, 8
    bne a0, t0, fread_error
    
    # load and store the number of rows and columns
    lw t0, 0(s4)
    lw t1, 4(s4)
    sw t0, 0(s1) 
    sw t1, 0(s2)

    # save the number of bytes
    mul t0, t0, t1      # number of elements
    li t1, 4
    mul s5, t0, t1      # number of bytes

    # free the allocated space
    mv a0, s4           # heap address
    jal free

    # read the rest of elements from the file
    mv a0, s5           
    jal malloc
    beq a0, x0, malloc_error

    mv s4, a0           # save the buffer
    mv a1, s3           # arg1: file descriptor
    mv a2, s4           # arg2: read info into this buffer
    mv a3, s5           # number of bytes to be read

    jal fread
    bne a0, s5, fread_error

    # close the file
    mv a1, s3
    jal fclose
    li t0, -1
    beq a0, t0, fclose_error

    # return the address of matrix
    mv a0, s4           

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

malloc_error:

    li a1, 88           # exit code: 88
    j exit2

fopen_error:
    
    li a1, 90           # exit code: 90
    j exit2

fread_error:

    li a1, 91           # exit code: 91
    j exit2

fclose_error:

    li a1, 92           # exit code: 92
    j exit2
