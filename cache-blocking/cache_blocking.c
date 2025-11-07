#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define BLOCK_SIZE 64

void dgemm_no_block(float* A, float* B, float* C, int N); 
void dgemm_do_block(float* A, float* B, float* C, int N); 
void do_block(float* A, float* B, float* C, int N,
    int si, int sj, int sk); 

int main() {
	void (*dgemm[])(float* A, float* B, float* C, int N) = {dgemm_no_block, dgemm_do_block};
	const char* names[] = {"dgemm_no_blocking", "dgemm_with_blocking"};

	const int n = 4096;
    float* A = (float*)malloc(n*n*sizeof(float));
    float* B = (float*)malloc(n*n*sizeof(float));
    float* C = (float*)malloc(n*n*sizeof(float));

    for (int i = 0; i < n * n; ++i) {
        A[i] = drand48()*2-1;
        B[i] = drand48()*2-1;
        C[i] = drand48()*2-1;
    }

    struct timeval start, end;
    for(int i = 0; i < 2; i++) {
        /* multiply matrices and measure the time */
        gettimeofday( &start, NULL );
        (*dgemm[i])( A, B, C, n);
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

void dgemm_no_block(float* A, float* B, float* C, int N) {
    for (int k = 0; k < N; ++k) {
        for (int j = 0; j < N; ++j) {
            for (int i = 0; i < N; ++i) {
                C[i + N*j] += A[i + N*k] * B[k + N*j];
            }
        }
    }
}

void dgemm_do_block(float* A, float* B, float* C, int N) {
    for (int i = 0; i < N; i += BLOCK_SIZE) {
        for (int j = 0; j < N; j += BLOCK_SIZE) {
            for (int k = 0; k < N; k += BLOCK_SIZE) {
                do_block(A, B, C, N, i, j, k);
            }
        }
    }
}

void do_block(float* A, float* B, float* C, int N,
    int si, int sj, int sk) {
    for (int k = sk; k < sk + BLOCK_SIZE; ++k) {
        for (int j = sj; j < sj + BLOCK_SIZE; ++j) {
            for (int i = si; i < si + BLOCK_SIZE; ++i) {
                C[i + N*j] += A[i + N*k] * B[k + N*j];
            }
        }
    }
}

