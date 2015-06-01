// cuda_example3.cu : Defines the entry point for the console application.
//


#include <stdio.h>
#include <cuda.h>
#include <string.h>


// Kernel that executes on the CUDA device
__global__ void square_array( float *a, long int N, long int b )
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if ( ((2*b)*idx+b) < N){
        a[idx*2*b] = a[idx*2*b]+a[((2*b)*idx+b)];
    	 a[((2*b)*idx+b)] = 0;
       
    }
}

typedef struct cudaDeviceProp cudaDevProp_t;

// main routine that executes on the host
int main( void )
{
    
    int ct,dev;
    long int b = 1;
    int passos = 0;
    cudaDevProp_t prop;

    float *a_h, *a_d; // Pointer to host & device arrays
    const long int N = 30000; // Number of elements in arrays

    size_t size = N * sizeof( float );

    cudaGetDeviceCount(&ct); //is there a cuda device??

    if(ct == 0){ 
        printf("\nNo CUDA device found.\n");
        exit(0);
    }

    a_h = (float *)malloc( size );    // Allocate array on host
    cudaMalloc( (void **)&a_d, size ); // Allocate array on device

    // Initialize host array and copy it to CUDA device
    for ( long int i = 0; i < N; i++ )
        a_h[i] = (float)1;

    cudaMemcpy( a_d, a_h, size, cudaMemcpyHostToDevice );

    // kernel initialization
    cudaGetDevice(&dev);
    cudaGetDeviceProperties(&prop,dev);
    int block_size = prop.maxThreadsPerBlock; //ATENTION
    int n_blocks   = N / block_size + ( N % block_size == 0 ? 0 : 1 );

    while(b<N){
        passos++;
    	square_array <<< n_blocks, block_size >>> ( a_d, N,b );
        b = b*2;
        cudaMemcpy( a_h, a_d, sizeof( float ) * N, cudaMemcpyDeviceToHost );
        puts("\n\n");
    // Print results
      // for ( int i = 0; i < N; i++ )
          printf( " %f\n",a_h[0] ); // Cleanup
    }
    // Retrieve result from device and store it in host array

    printf("\n\tPASSOS: %d", passos);
    free( a_h );
    cudaFree( a_d );
    return 0;
}
