#include <stdio.h>
#include <string.h>
#include <cstdlib>
#include <cmath>
#include <omp.h>
#include <ctime>
#include <cuda.h>



#define A_h(x,y) A_h[M*x+y]
#define B_h(x,y) B_h[M*x+y]
#define C_h(x,y) C_h[M*x+y]

#define A_d(x,y) A_d[M*x+y]
#define B_d(x,y) B_d[M*x+y]
#define C_d(x,y) C_d[M*x+y]

__global__ void foo(int *A_d,int *B_d, int *C_d, int qtd_col_a, int qtd_col_b,int M ){
    int acumulador;
	int linha = blockIdx.x * blockDim.x + threadIdx.x; //blockIdx*blockDim e blockIdx*blockDim garante que toda a matriz seja coberda por 													   //threads

	if(linha<M){
        for(int coluna = 0; coluna< qtd_col_b; ++coluna){
            acumulador = 0;
            for(int i = 0; i<qtd_col_a; ++i){
                acumulador = acumulador + (A_d(linha,i)*B_d(i,coluna));
            }
            C_d(linha,coluna) = acumulador;
        }
    }
}

int main(){
    int M = 500;
    int A_h[M*M];
    int B_h[M*M];
    int C_h[M*M];

    int *A_d, *B_d, *C_d;

    int qtd_lin_a,qtd_lin_b,qtd_col_a,qtd_col_b;



    int block_size;
    int n_blocks;




    size_t size = M * M *sizeof( int );




    qtd_lin_a = M;
    qtd_col_a = M;

    qtd_lin_b = qtd_col_a;
    qtd_col_b =M;



   /* puts("\n\nMultiplicacao de matrizes");
    puts("\n\tDigite a qtd de linhas de A: ");
    scanf("%d", &qtd_lin_a);
    puts("\n\tDigite a qtd de colunas de A: ");
    scanf("%d", &qtd_col_a);
    qtd_lin_b = qtd_col_a;
    puts("\n\tDigite a qtd de colunas de B: ");
    scanf("%d", &qtd_col_b);*/


    srand(time(NULL) );

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


    cudaMalloc( (void **)&A_d, size );
    cudaMemcpy( A_d, A_h, size, cudaMemcpyHostToDevice );

    cudaMalloc( (void **)&B_d, size );
    cudaMemcpy( B_d, B_h, size, cudaMemcpyHostToDevice );

    cudaMalloc( (void **)&C_d, size );



    /***************/
    /**KERNEL******/
    block_size = 32;
    n_blocks   = M / block_size + ( M % block_size == 0 ? 0 : 1 );
    foo<<< n_blocks, block_size >>> (A_d, B_d, C_d,qtd_col_a,qtd_col_a,M);
    cudaMemcpy( C_h, C_d, sizeof( int ) * M * M, cudaMemcpyDeviceToHost );
    return 0;
}


