// cuda_example3.cu : Defines the entry point for the console application.
//


#include <stdio.h>
#include <cuda.h>
#include <string.h>

#define A(x,y) A[M*x+y]
#define a_h(x,y) a_h[M*x+y]

typedef struct cudaDeviceProp cudaDevProp_t;



// Kernel that executes on the CUDA device

//A[i][j] = ordem do elemento na matriz, de 0 -> n²-1
__global__ void bar(float *A, int N, int M){
	int i = blockIdx.x * blockDim.x + threadIdx.x; //blockIdx*blockDim e blockIdx*blockDim garante que toda a matriz seja coberda por 													   //threads
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	
	if(i<N && j<M){
		A(i,j) = M*i+j;}
}

void checkCUDAError(const char *msg)
{
    cudaError_t err = cudaGetLastError(); //erro da ultima opereacao cuda chamada
    if( cudaSuccess != err) 
    {
        fprintf(stderr, "Cuda error: %s: %s.\n", msg, 
                                  cudaGetErrorString( err) );
        exit(EXIT_FAILURE);
    }                         
}

// main routine that executes on the host
int main( void )
{
    float *a_h, *a_d; 
    const int N = 1002; 
    const int M = 1002;

	int ct, dev;
	cudaDevProp_t prop;
	

	cudaGetDeviceCount(&ct);
    if(ct == 0){ 
        printf("\nNo CUDA device found.\n");
        exit(0);
    }
    cudaGetDevice(&dev);
    cudaGetDeviceProperties(&prop,dev);

	dim3 bDim(22,22); //threads por bloco. Nao podem ultrapassar a capacidade da VGA
						//se o Z nao for definido, fica Z=1

  	dim3 gDim((N/bDim.x)+( N % bDim.x == 0 ? 0 : 1 ),M/bDim.y+( M % bDim.y == 0 ? 0 : 1 )); //~numBlocks

    size_t size = N * M *sizeof( float );
  
    a_h = (float *)malloc( size );   //Tudo sera alocado da mesma forma, pois temos matriz A[N*M] mas estamos visualizando A[N][M]
  		
    cudaMalloc( (void **)&a_d, size ); 
    cudaMemcpy( a_d, a_h, size, cudaMemcpyHostToDevice );

	checkCUDAError("memcpy"); //caro tenha ocorrido erro, retorna o tipo e em qual operacao ocorreu.
	
	bar<<<gDim, bDim>>>(a_d, N,M);

	cudaThreadSynchronize(); // bloqueia o device ate que a execucao do kernel tenha sido concluida. Retorna erro ou sucesso.

    checkCUDAError("kernel invocation");

	/*
		Atencao: sem cudaThreadSync, o programa retornaria os erros do memcopy, nao do kernel.
	*/

    cudaMemcpy( a_h, a_d, sizeof( float ) * N * M, cudaMemcpyDeviceToHost ); //recuperando resultados
    checkCUDAError("memcpy"); //checa erro ao recuperar os resultados


   /*for ( int i = 0; i < N; i++ ){
		printf("%d[ ", i);
		for(int j = 0; j<M; ++j){
    		printf( "%d ",(int)a_h(i,j) ); 
    	}
		puts(" ]");
		puts("\n");
    }*/
	
	printf("\n\n%d\n\n", (int)a_h((N-1),(M-1))); 
	if((int)a_h((N-1),(M-1))!=(N*N-1)){
		printf("\n\nKernel com erros de programacao");
		exit(1);
	}
    free( a_h );
    cudaFree( a_d );

	printf("\n\tPrograma sem erros CUDA...\n\n"); //se o programa chegou aqui, ele nao apresenta erros.
    return 0;
}
