// cuda_example3.cu : Defines the entry point for the console application.
//


#include <stdio.h>
#include <string.h>
#include <cuda.h>

const int N = 64;

__global__ void foo( float **a, int N )
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    if ( i < N && j<N )
        a[i][j] = 1;
}


// main routine that executes on the host
int main( void )
{
    const int block_size = 4;
    int n_blocks;
    
    dim3 dimblock(block_size, block_size);

   
    float a_h[N][N], **a_d; // Pointer to host & device arrays
   


    size_t size = N * N * sizeof( float );

    cudaMalloc( (void **)&a_d, size ); // Allocate array on device
    

    // Initialize host array and copy it to CUDA device
    for ( int i = 0; i < N; i++){
        for(int j = 0; j<N; j++){
	    a_h[i][j] = (float)i;
        }
     }


    for ( int i = 0; i < N; i++ ){
	
        for(int j = 0; j<N; j++){
	    printf("%d ",(int)a_h[i][j]);
        }
    }
    puts("\n");

   
   /*
       invocando o kernel
   */
   n_blocks   = N / block_size + ( N % block_size == 0 ? 0 : 1 );
   cudaMemcpy( a_d, a_h, size, cudaMemcpyHostToDevice );

   foo<<< n_blocks, dimblock >>> ( a_d, N );

   cudaMemcpy( a_h, a_d,size, cudaMemcpyDeviceToHost );

   puts("\nDEVICE - HOST:\n");

   for ( int i = 0; i < N; i++ ){
	
       for(int j = 0; j<N; j++){
	    printf("%d ",(int)a_h[i][j]);
        }
    }
    puts("\n");

    //free( a_h );

    cudaFree( a_d );
    return 0;
}
