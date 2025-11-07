#include <stdlib.h>

void dgemm(float* A, float* B, float* C, int N);

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
	for (int k = 0; k < N; ++k) {
		for (int j = 0; j < N; ++j) {
			for (int i = 0; i < N; ++i) {
				C[i + N*j] += A[i + N*k] * B[k + N*j];
			}
		}
	} 
}
