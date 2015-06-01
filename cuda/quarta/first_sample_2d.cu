// cuda_example3.cu : Defines the entry point for the console application.
//


#include <stdio.h>
#include <cuda.h>
#include <string.h>

#define A(x,y) A[M*x+y]
#define a_h(x,y) a_h[M*x+y]
typedef struct cudaDeviceProp cudaDevProp_t;



// Kernel that executes on the CUDA device
__global__ void foo( float *A, int N, int M)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if ( idx < N ){ //aqui idx representa a linha. Cada elemento (idx,y) e gerado
		for(int i = 0; i<M; ++i){
			A(idx,i) = M*idx+i;
		}
    }
  
}



// main routine that executes on the host
int main( void )
{
    float *a_h, *a_d; 
    const int N = 1000; 
    const int M = 10000;
	int ct, dev;
	cudaDevProp_t prop;

	cudaGetDeviceCount(&ct); //is there a cuda device??

    if(ct == 0){ 
        printf("\nNo CUDA device found.\n");
        exit(0);
    }
	
    cudaGetDevice(&dev);
    cudaGetDeviceProperties(&prop,dev);

    int block_size = prop.maxThreadsPerBlock; //maior quantidade de threads permitida em um bloco unidimensional
    int n_blocks   = N*M / block_size + ( N % block_size == 0 ? 0 : 1 );

    size_t size = N * M *sizeof( float );

    a_h = (float *)malloc( size );    //Tudo sera alocado da mesma forma, pois temos matriz A[N*M] mas estamos visualizando A[N][M]
    cudaMalloc( (void **)&a_d, size ); 
    cudaMemcpy( a_d, a_h, size, cudaMemcpyHostToDevice );

  

    foo <<< n_blocks, block_size >>> ( a_d, N,M );


    cudaMemcpy( a_h, a_d, sizeof( float ) * N * M, cudaMemcpyDeviceToHost ); //recuperando resultados
    
   /*for ( int i = 0; i < N; i++ ){
		printf("%d[ ", i);
		for(int j = 0; j<M; ++j){
    		printf( "%d ",(int)a_h(i,j) ); 
    	}
		puts(" ]");
		puts("\n");
    }*/
	printf("\n\n%d\n\n", (int)a_h((N-1),(M-1))); 

    free( a_h );
    cudaFree( a_d );
    return 0;
}
