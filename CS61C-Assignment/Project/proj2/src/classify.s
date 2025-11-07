.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>


    # check the number of argument
    li t0, 5
    bne a0, t0, incorrect_number_of_args

    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)       # matrix M0
    sw s4, 16(sp)       # matrix M1
    sw s5, 20(sp)       # matrix Mi
    sw s6, 24(sp)       # heap space for ReLU's Md
    sw s7, 28(sp)       # address of [a1, a2] array in read_matrix()
    sw s8, 32(sp)       # heap space for final Md
    sw ra, 36(sp)

    mv a2, x0           # when classify.s used as a unit test function, manually set a2
    mv s0, a0
    mv s1, a1
    mv s2, a2


	# =====================================
    # LOAD MATRICES
    # =====================================

    # malloc space for a1, a2 in read_matrix()
    li a0, 24
    jal malloc
    mv s7, a0

    # Load pretrained m0
    lw a0, 4(s1)        # M0 file path
    mv a1, s7           # address of row in M0
    addi a2, s7, 4      # address of col in M0
    jal read_matrix
    mv s3, a0           # address of matrix M0


    # Load pretrained m1
    lw a0, 8(s1)        # M1 file path 
    addi a1, s7, 8      # address of row in M1
    addi a2, s7, 12     # address of col in M1
    jal read_matrix
    mv s4, a0           # address of matrix M1


    # Load input matrix
    lw a0, 12(s1)       # Input matrix file path 
    addi a1, s7, 16     # address of row in Mi
    addi a2, s7, 20     # address of col in Mi
    jal read_matrix
    mv s5, a0           # address of input matrix




    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # allocate space for a6 in matmul()
    lw t0, 0(s7)        # row of M0
    lw t1, 20(s7)       # col of Mi
    mul a0, t0, t1      # number of elems
    slli a0, a0, 2      # number of bytes
    jal malloc
    mv s6, a0           

    # 1. m0 * input

    mv a0, s3           # address of M0
    lw a1, 0(s7)        # row of M0 
    lw a2, 4(s7)        # col of M0
    mv a3, s5           # address of Mi
    lw a4, 16(s7)       # row of Mi
    lw a5, 20(s7)       # col of Mi
    mv a6, s6           # heap space for Md
    jal matmul

    # 2. ReLU(m0 * input)

    mv a0, s6           # address of Md
    lw t0, 0(s7)        # row of M0
    lw t1, 20(s7)       # col of Mi
    mul a1, t0, t1      # number of elements in Md
    jal relu

    # 3. m1 * ReLU(m0 * input)    

    lw t0, 8(s7)        # row of M1
    lw t1, 20(s7)       # col of Mi
    mul a0, t0, t1      # num of elems
    slli a0, a0, 2      # num of bytes
    jal malloc          # allocate space for the final Md
    mv s8, a0

    mv a0, s4           # address of M1
    lw a1, 8(s7)        # row of M1
    lw a2, 12(s7)       # col of M1
    mv a3, s6           # address of ReLU's Md
    lw a4, 0(s7)        # row of ReLU matrix (row of M0)
    lw a5, 20(s7)       # col of ReLU matrix (col of Mi)
    mv a6, s8           # heap space for Md
    jal matmul



    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    lw a0, 16(s1)       # output file path
    mv a1, s8           # address of output matrix Md
    lw a2, 8(s7)        # row of M1
    lw a3, 20(s7)       # col of Mi
    jal write_matrix

    

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    
    lw t0, 8(s7)        # row of M1
    lw t1, 20(s7)       # col of Mi
    mv a0, s8           # address of output matrix Md
    mul a1, t0, t1      # number of elements
    jal argmax

    bne s2, x0, exit_print

    # Print classification

    mv a1, a0           # result to be printed
    jal print_int

    # Print newline afterwards for clarity

    li a1, 10           # '\n' ASCII code
    jal print_char

exit_print:

    # free heap space for s6
    mv a0, s6
    jal free

    # free heap space for s7
    mv a0, s7
    jal free

    # free heap space for s8
    mv a0, s8
    jal free

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40

    ret

incorrect_number_of_args:

    li a1, 89
    j exit2
