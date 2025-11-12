#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <omp.h>

void dgemm_no_block(float* A, float* B, float* C, int N, int BLOCK_SIZE); 
void dgemm_do_block(float* A, float* B, float* C, int N,int BLOCK_SIZE); 
void dgemm_do_block_omp(float* A, float* B, float* C, int N, int BLOCK_SIZE); 
void do_block(float* A, float* B, float* C, int N, int BLOCK_SIZE, 
    int si, int sj, int sk); 

int main(int argc, char** argv) {
	void (*dgemm[])(float* A, float* B, float* C, int N, int BLOCK_SIZE) = {
		dgemm_no_block, dgemm_do_block, dgemm_do_block_omp };
	const char* names[] = {
		"dgemm_no_block", "dgemm_do_block", "dgemm_do_block_omp" };
	
	if (argc != 3) {
		printf("argument count is incorrect\n");
		return 0;
	}
	const int n = atoi(argv[1]);
	const int block_size = atoi(argv[2]);
	float* A = (float*)malloc(n*n*sizeof(float));
	float* B = (float*)malloc(n*n*sizeof(float));
	float* C = (float*)malloc(n*n*sizeof(float));

	for (int i = 0; i < n * n; ++i) {
		A[i] = drand48()*2-1;
		B[i] = drand48()*2-1;
		C[i] = drand48()*2-1;
	}

	struct timeval start, end;
	for(int i = 0; i < 3; i++) {
		/* multiply matrices and measure the time */
		gettimeofday( &start, NULL );
		(*dgemm[i])( A, B, C, n, block_size);
		gettimeofday( &end, NULL );

		/* convert time to Gflop/s */
		double seconds = (end.tv_sec - start.tv_sec) +
		    1.0e-6 * (end.tv_usec - start.tv_usec);
		double Gflops = 2e-9*n*n*n/seconds;
		printf( "%s:\tn = %d, %.3f Gflop/s\n", names[i], n, Gflops );
	}

	free(A);
	free(B);
	free(C);

	return 0;
}

void dgemm_no_block(float* A, float* B, float* C, int N, int BLOCK_SIZE) {
    for (int k = 0; k < N; ++k) {
        for (int j = 0; j < N; ++j) {
            for (int i = 0; i < N; ++i) {
                C[i + N*j] += A[i + N*k] * B[k + N*j];
            }
        }
    }
}

void dgemm_do_block(float* A, float* B, float* C, int N, int BLOCK_SIZE) {
    for (int i = 0; i < N; i += BLOCK_SIZE) {
        for (int j = 0; j < N; j += BLOCK_SIZE) {
            for (int k = 0; k < N; k += BLOCK_SIZE) {
                //do_block(A, B, C, N, i, j, k);
		    for (int sk = k; sk < k + BLOCK_SIZE; ++sk) {
			for (int sj = j; sj < j + BLOCK_SIZE; ++sj) {
			    for (int si = i; si < i + BLOCK_SIZE; ++si) {
				C[si + N*sj] += A[si + N*sk] * B[sk + N*sj];
			    }
			}
		    }
            }
        }
    }
}

/*
void dgemm_no_block(float* A, float* B, float* C, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            for (int k = 0; k < N; ++k) {
                C[i + N*j] += A[i + N*k] * B[k + N*j];
            }
        }
    }
}

void dgemm_do_block(float* A, float* B, float* C, int N) {
    for (int i = 0; i < N; i += BLOCK_SIZE) {
        for (int j = 0; j < N; j += BLOCK_SIZE) {
            for (int k = 0; k < N; k += BLOCK_SIZE) {
                //do_block(A, B, C, N, i, j, k);
		    for (int si = i; si < i + BLOCK_SIZE; ++si) {
			for (int sj = j; sj < j + BLOCK_SIZE; ++sj) {
			    for (int sk = k; sk < k + BLOCK_SIZE; ++sk) {
				C[si + N*sj] += A[si + N*sk] * B[sk + N*sj];
			    }
			}
		    }
            }
        }
    }
}
*/

void dgemm_do_block_omp(float* A, float* B, float* C, int N, int BLOCK_SIZE) {
#pragma omp parallel for
    for (int i = 0; i < N; i += BLOCK_SIZE) {
        for (int j = 0; j < N; j += BLOCK_SIZE) {
            for (int k = 0; k < N; k += BLOCK_SIZE) {
                do_block(A, B, C, N, BLOCK_SIZE, i, j, k);
            }
        }
    }
}

void do_block(float* A, float* B, float* C, int N, int BLOCK_SIZE,
    int si, int sj, int sk) {
    for (int k = sk; k < sk + BLOCK_SIZE; ++k) {
        for (int j = sj; j < sj + BLOCK_SIZE; ++j) {
            for (int i = si; i < si + BLOCK_SIZE; ++i) {
                C[i + N*j] += A[i + N*k] * B[k + N*j];
            }
        }
    }
}

