// cuda_example3.cu : Defines the entry point for the console application.
#include <stdio.h>
#include <cuda.h>

// Kernel that executes on the CUDA device

__global__ void add_two_vectors(float *a, float *b, float *c, int N)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if ( idx < N ){ 
		c[idx] = a[idx] + b[idx];
    }
}




// main routine that executes on the host
int main( void )
{
    float *a_h, *a_d; // Pointer to host & device arrays
    float *b_h, *b_d;
    float *c_h, *c_d;

    const int N = 10000000; // Number of elements in arrays
    int block_size = 4; //number threads in a block
    int n_blocks   = N / block_size + ( N % block_size == 0 ? 0 : 1 ); // # of blocks
	.
	.
	.
	
		
    size_t size = N * sizeof( float ); //for alocation. aloca N vezes o tamanho do tipo

    a_h = (float *)malloc( size );    // Allocate array on host
    b_h = (float *)malloc( size );
    c_h = (float *)malloc( size );

    cudaMalloc( (void **)&a_d, size ); // Allocate array on device
    cudaMalloc( (void **)&b_d, size );
    cudaMalloc( (void **)&c_d, size );

    // Initialize host array and copy it to CUDA device
    for ( int i = 0; i < N; i++ )
        a_h[i] = (float)i; //float pois gpu trabalha com FPO
    cudaMemcpy( a_d, a_h, size, cudaMemcpyHostToDevice ); //mesma coisa do memcopy, sendo que copiando um host inicializado pro device(gpu)
				                  //ponteiros para os vetores, size, operacao

    for ( int i = 0; i < N; i++ )
        b_h[i] = (float)i;
    cudaMemcpy( b_d, b_h, size, cudaMemcpyHostToDevice );

    

    //square_array <<< n_blocks, block_size >>> ( a_d, N ); //chamando o kernel com o vertor iniciado na GPU
    
    add_two_vectors <<< n_blocks,block_size >>> (a_d,b_d,c_d,N); 
	do_some_host_computation( );
	cudaMemcpy(...);
    
// Retrieve result from device and store it in host array
    cudaMemcpy( c_h, c_d, sizeof( float ) * N, cudaMemcpyDeviceToHost ); //agora a operacao contra'ria a linha 38 esta sendo realizada.

   // Print results
    for ( int i = 0; i < N; i++ )
        printf( "%d %f\n", i, c_h[i] ); // Cleanup
    
    free( a_h );
    free( b_h );
    free( c_h );
    
    cudaFree( a_d );
    cudaFree( b_d );
    cudaFree( c_d );
    return 0;
}
