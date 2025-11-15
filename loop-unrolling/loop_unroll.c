#include <x86intrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define UNROLL	(4)

void dgemm0(double* A, double* B, double* C, int N);	// no optimization
void dgemm_avx(double* A, double* B, double* C, int N);	// data(subword) parallisim
void dgemm_avx_unroll(double* A, double* B, double* C, int N);	// data parallisim and loop-unrolling

int main() {
	void (*dgemm[])(double* A, double* B, double* C, int N) = {
		dgemm0, dgemm_avx, dgemm_avx_unroll };
	const char* names[] = {"dgemm", "dgemm_avx", "dgemm_avx_unroll" };

	const int nMatDim = 960;	// dimension of matrix
	/* avx load/store needs the memory is 32 bytes aligned, so we must use aligned_alloc rather malloc */
	double* A = (double*)aligned_alloc(32, nMatDim * nMatDim * sizeof(double));
	double* B = (double*)aligned_alloc(32, nMatDim * nMatDim * sizeof(double));
	double* C = (double*)aligned_alloc(32, nMatDim * nMatDim * sizeof(double));
	for (int i = 0; i < nMatDim * nMatDim; ++i) {
		A[i] = drand48()*2 -1;
		B[i] = drand48()*2 -1;
		C[i] = drand48()*2 -1;
	}

    struct timeval start, end;
    for(int i = 0; i < 3; i++) {
        /* multiply matrices and measure the time */
        gettimeofday( &start, NULL );
        (*dgemm[i])( A, B, C, nMatDim );
        gettimeofday( &end, NULL );

        /* convert time to Gflop/s */
        double seconds = (end.tv_sec - start.tv_sec) +
            1.0e-6 * (end.tv_usec - start.tv_usec);
        double Gflops = 2e-9*nMatDim*nMatDim*nMatDim/seconds;
        printf( "%s:\tn = %d, %.3f Gflop/s\n", names[i], nMatDim, Gflops );
    }

	free(A);
	free(B);
	free(C);
}

void dgemm0(double* A, double* B, double* C, int N) {
	for (int i = 0; i < N; ++i) {
		for (int j = 0; j < N; ++j) {
			for (int k = 0; k < N; ++k) {
				C[i + j*N] += A[i + k*N] * B[k + j*N];	
			}
		}
	}
}

void dgemm_avx(double* A, double* B, double* C, int N) {
	for (int i = 0; i < N; i += 4) {
		for (int j = 0; j < N; ++j) {
			__m256d c = _mm256_load_pd(C + i + j*N);
			for (int k = 0; k < N; ++k) {
				__m256d b = _mm256_broadcast_sd(B + k + j*N);
				c = _mm256_add_pd(c, _mm256_mul_pd(
					_mm256_load_pd(A + i + k*N), b));
			}
			_mm256_store_pd(C + i + j*N, c);
		}
	}
}

void dgemm_avx_unroll(double* A, double* B, double* C, int N) {
	for (int i = 0; i < N; i += UNROLL*4) {
		for (int j = 0; j < N; ++j) {
			__m256d c[4];
			c[0] = _mm256_load_pd(C + i + j*N);
			c[1] = _mm256_load_pd(C + i+4 + j*N);
			c[2] = _mm256_load_pd(C + i+8 + j*N);
			c[3] = _mm256_load_pd(C + i+12 + j*N);

			for (int k = 0; k < N; ++k) {
				__m256d b = _mm256_broadcast_sd(B + k + j*N);
				c[0] = _mm256_add_pd(c[0], _mm256_mul_pd(
					_mm256_load_pd(A + i + k*N), b));
				c[1] = _mm256_add_pd(c[1], _mm256_mul_pd(
					_mm256_load_pd(A + i+4 + k*N), b));
				c[2] = _mm256_add_pd(c[2], _mm256_mul_pd(
					_mm256_load_pd(A + i+8 + k*N), b));
				c[3] = _mm256_add_pd(c[3], _mm256_mul_pd(
					_mm256_load_pd(A + i+12 + k*N), b));
			}
			_mm256_store_pd(C + i + j*N, c[0]);
			_mm256_store_pd(C + i+4 + j*N, c[1]);
			_mm256_store_pd(C + i+8 + j*N, c[2]);
			_mm256_store_pd(C + i+12 + j*N, c[3]);
		}
	}
}

void dgemm_avx_unroll_omp(double* A, double* B, double* C, int N) {
	for (int i = 0; i < N; i += UNROLL*4) {
		for (int j = 0; j < N; ++j) {
			__m256d c[4];
			c[0] = _mm256_load_pd(C + i + j*N);
			c[1] = _mm256_load_pd(C + i+4 + j*N);
			c[2] = _mm256_load_pd(C + i+8 + j*N);
			c[3] = _mm256_load_pd(C + i+12 + j*N);

			for (int k = 0; k < N; ++k) {
				__m256d b = _mm256_broadcast_sd(B + k + j*N);
				c[0] = _mm256_add_pd(c[0], _mm256_mul_pd(
					_mm256_load_pd(A + i + k*N), b));
				c[1] = _mm256_add_pd(c[1], _mm256_mul_pd(
					_mm256_load_pd(A + i+4 + k*N), b));
				c[2] = _mm256_add_pd(c[2], _mm256_mul_pd(
					_mm256_load_pd(A + i+8 + k*N), b));
				c[3] = _mm256_add_pd(c[3], _mm256_mul_pd(
					_mm256_load_pd(A + i+12 + k*N), b));
			}
			_mm256_store_pd(C + i + j*N, c[0]);
			_mm256_store_pd(C + i+4 + j*N, c[1]);
			_mm256_store_pd(C + i+8 + j*N, c[2]);
			_mm256_store_pd(C + i+12 + j*N, c[3]);
		}
	}
}
