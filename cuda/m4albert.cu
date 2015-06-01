#include <stdio.h>
#include <string.h>
#include <cstdlib>
#include <cmath>
#include <omp.h>
#include <ctime>
#include <cuda.h>

#define M 500
#define N 500
#define T 500

#define A_h(i,j) A_h[M*i+j]
#define B_h(i,j) B_h[M*i+j]
#define C_h(i,j) C_h[M*i+j]

#define A_d(i,j) A_d[M*i+j]
#define B_d(i,j) B_d[M*i+j]

#define C_dd(i,j) C_dd[M*i+j]

#define C_dh(i,j) C_dh[M*i+j]


//int A_h[] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

//int A_h[] = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};

//int B_h[] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};

int A_h[M*T];
int B_h[M*T];


__global__ void bar(int *A_d,int *B_d, int *C_dd, int total){
	int i,j,k;

	int idx = blockIdx.x * blockDim.x + threadIdx.x; 
	
	if(idx < total){
		
		j=(idx)%M;
		i=(idx)/M;
		C_dd(i,j) = 0;
		for(k = 0; k<T; ++k){
			C_dd(i,j) += A_d(i,k)*B_d(k,j);
                }	
	}
	
}


int main(){
    
    /*int A_h[M*M];
    int B_h[M*M];
    int C_h[M*M];*/

    int *A_d, *B_d, *C_d;
    int *C_dd;
    int *C_dh;

    int qtd_lin_a,qtd_lin_b,qtd_col_a,qtd_col_b;



    int block_size;
    int n_blocks;

    int b =1;
    int cont = 0;

    size_t size = M * M *sizeof( int );
    size_t sizeCdd = M*N*sizeof(int);

    srand(time(NULL));

    for(int i = 0; i<M; ++i){
        for(int j = 0; j<N; ++j){
            A_h(i,j) =rand() % 10;
        }
    }

    for(int i = 0; i<M; ++i){
        for(int j = 0; j<N; ++j){
            B_h(i,j) =rand() % 10;
        }
    }


/*
    qtd_lin_a = M;
    qtd_col_a = N;

    qtd_lin_b = qtd_col_a;
    qtd_col_b =;
*/


   /* puts("\n\nMultiplicacao de matrizes");
    puts("\n\tDigite a qtd de linhas de A: ");
    scanf("%d", &qtd_lin_a);
    puts("\n\tDigite a qtd de colunas de A: ");
    scanf("%d", &qtd_col_a);
    qtd_lin_b = qtd_col_a;
    puts("\n\tDigite a qtd de colunas de B: ");
    scanf("%d", &qtd_col_b);*/

/*
    srand ();

    for(int i = 0; i<qtd_lin_a; ++i){
        for(int j = 0; j<qtd_col_a; ++j){
            A_h(i,j) =rand() % 10;
        }
    }

    for(int i = 0; i<qtd_lin_b; ++i){
        for(int j = 0; j<qtd_col_b; ++j){
            B_h(i,j) =rand() % 10;
        }
    }
*/
     C_dh = (int *)malloc( sizeCdd );   
    cudaMalloc( (void **)&A_d, size );
    cudaMemcpy( A_d, A_h, size, cudaMemcpyHostToDevice );

    cudaMalloc( (void **)&B_d, size );
    cudaMemcpy( B_d, B_h, size, cudaMemcpyHostToDevice );

    cudaMalloc( (void **)&C_d, size );
    cudaMalloc( (void **)&C_dd, sizeCdd);



    /***************/
    /**KERNEL******/
    /*block_size = 32;
    n_blocks   = M / block_size + ( M % block_size == 0 ? 0 : 1 );
    foo<<< n_blocks, block_size >>> (A_d, B_d, C_d,qtd_col_a,qtd_col_a,M);
    cudaMemcpy( C_h, C_d, sizeof( int ) * M * M, cudaMemcpyDeviceToHost );*/
	
    block_size = 32;
    n_blocks   = (M*N) / block_size + ( (M*N) % block_size == 0 ? 0 : 1 );
    bar<<<n_blocks, block_size>>>(A_d, B_d, C_dd, (M*N));
    //++cont;     
	// cudaMemcpy( C_dh, C_dd, sizeof( int ) *M*N*T, cudaMemcpyDeviceToHost );

   /* for(int k = 0; k<T; ++k){
	for(int i = 0; i<N; ++i){
	    for(int j = 0; j<M; ++j){
			printf(" %d", C_dh(i,j,k));
			
		}
		puts("\n");	
	}
	puts("---\n");
    }
*/
    cudaMemcpy( C_dh, C_dd, sizeof( int ) *M*N, cudaMemcpyDeviceToHost );

    /*for(int i = 0; i<N; ++i){
	    for(int j = 0; j<M; ++j){
			printf(" %d", C_dh(i,j,0));
			
		}
		puts("\n");	
	}*/
    printf("\n\tContador: %d", cont);	
    return 0;
}


