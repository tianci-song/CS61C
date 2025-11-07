#include <stdlib.h>

void dgemm(float* A, float* B, float* C, int N);
void do_block(float* A, float* B, float* C, int N, 
	int si, int sj, int sk);

#define BLOCK_SIZE 128

int main() {
	const int n = 2048;
	float* A = (float*)malloc(n*n*sizeof(float));
	float* B = (float*)malloc(n*n*sizeof(float));
	float* C = (float*)malloc(n*n*sizeof(float));

    for (int i = 0; i < n * n; ++i) { 
		A[i] = drand48()*2-1; 
		B[i] = drand48()*2-1; 
		C[i] = drand48()*2-1; 
	}

    dgemm(A, B, C, n);

	free(A);
	free(B);
	free(C);

    return 0;
}

void dgemm(float* A, float* B, float* C, int N) {
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












