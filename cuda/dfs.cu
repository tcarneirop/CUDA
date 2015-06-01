// cuda_example3.cu : Defines the entry point for the console application.
//


#include <stdio.h>
#include <string.h>
#include <cuda.h>

#define N_h(x,y) N_h[(dimension)*(x-1)+(y-1)]
#define N_d(x,y) N_d[dimension*(x-1)+(y-1)]

#define MAX 100
#define ZERO 0
#define ONE  1
#define INICIO 1
#define TRUE 1
#define INFINITO 999999
void checkCUDAError(const char* msg);

struct nodo{

	int nivel;
	int index;
	int custo;
	int nodo_pai;
	int vflag[MAX];
};

typedef struct nodo nodo_t;

int vflag[MAX];

int N_h[] = {999999, 436, 636, 119, 131, 150, 999999, 668, 224, 305, 386, 802, 999999, 906, 31, 756, 226, 131, 999999, 602, 440, 107, 915, 275, 999999};


int dimension = 5;

// Kernel that executes on the CUDA device
__global__ void dfs(int *N_d, nodo_t *matriz_de_nodos, int *matriz_de_solucoes,int dimension ){

	/*
		@TODO: Tornar a matriz de solucoes compartilhada.
	*/

	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	nodo_t auxiliar;
	nodo_t pilha[25];
	int topo = 0;
	//int contador = 0;
	int verificados = 0;
	int posicao_solucao = idx;

	pilha[topo] = matriz_de_nodos[idx];

	/*while(topo>=ZERO){
		auxiliar = pilha[topo];
		if(auxiliar.nivel == dimension){
			matriz_de_solucoes[posicao_solucao] = auxiliar.custo;
			++posicao_solucao;
			topo--;
		}
		else{
			verificados = ZERO;
			for(int i = 1; i<=dimension; ++i){
				if(auxiliar.vflag[i] == TRUE){
					++verificados;
					continue;
				}
				else{
					auxiliar.custo+=N_d(auxiliar.index, i);
					auxiliar.index = i;
					auxiliar.nivel++;
					auxiliar.vflag[i] = TRUE;
					++topo;
					pilha[topo] = auxiliar;
					break;
				}

			}
			if(verificados == dimension){
				topo--; //desempilha
			}
		}//else
	}//while*/

}


int inline fat(int a){
	return 1;
}

nodo_t matriz[MAX];

// main routine that executes on the host
int main( void )
{


	int contador  = 0;
	//int custo = 0;
	int nivel;
	nodo_t *matriz_de_nodos_d;
	int *matriz_solucao_d;
	int *matriz_solucao_h;
	int *N_d;

	int n_blocks;
	const int block_size = 32;

	size_t size_nodos = (24)*sizeof(nodo_t);
	size_t size = (dimension)*(dimension)*(sizeof(int));
	size_t size_mat_sols = (24)*sizeof(int);


	cudaMalloc( (void **)&N_d, size );
	cudaMalloc( (void **)&matriz_de_nodos_d, size_nodos );
	cudaMalloc( (void **)&matriz_solucao_d,size_mat_sols  );

	cudaMemcpy( N_d, N_h, size, cudaMemcpyHostToDevice );// passando custo para GPU

	//inicializando vflag e matriz de solucoes
	memset(vflag,ZERO, sizeof(vflag));

	matriz_solucao_h = (int *)malloc(size_mat_sols);
	for(int i = 0;i<24; ++i)
		matriz_solucao_h[i] = INFINITO;




	/*
		inicio do DFS
	*/

	/*
	*/
	vflag[INICIO] = TRUE;
	nivel = INICIO;

	for(int i = 1; i<=dimension; ++i){
		if(vflag[i] == TRUE){
			continue;}
		else{
			matriz[contador].index  = i;
			matriz[contador].custo  = N_h(INICIO,i);
			matriz[contador].nivel = nivel+1;
			matriz[contador].nodo_pai = INICIO;
			memcpy(matriz[contador].vflag, vflag, sizeof(vflag));
			matriz[contador].vflag[i] = TRUE;
			++contador;
		}
	}



	/*for(int i = 0; i<contador; ++i){
		printf("\n\t Nodo de numero %d:", i);
		printf("\nIndice: %d",matriz[i].index);
		printf("\nNivel: %d",matriz[i].nivel);
		printf("\nCusto: %d",matriz[i].custo);
		printf("\nFlag do nodo %d: ",i);
		for(int j = 1; j<=dimension; ++j){
			printf("%d",matriz[i].vflag[j]);
		}
	}

	node = matriz[0];

	printf("\n\nNodo dps da copia:");


	printf("\nIndice: %d",node.index);
	printf("\nNivel: %d",node.nivel);
	printf("\nCusto: %d",node.custo);
	printf("\nFlag do nodo:");
	for(int j = 1; j<=dimension; ++j){
		printf("%d",node.vflag[j]);
	}*/


	cudaMemcpy(matriz_de_nodos_d, matriz, contador*(sizeof(nodo_t)), cudaMemcpyHostToDevice );
    checkCUDAError("memcpy1");

	cudaMemcpy(matriz_solucao_d, matriz_solucao_h, size_mat_sols, cudaMemcpyHostToDevice );
    checkCUDAError("memcpy2");

	n_blocks   = contador / block_size + ( contador % block_size == 0 ? 0 : 1 );

	cudaThreadSynchronize();
	dfs<<<n_blocks, block_size>>>(N_d, matriz_de_nodos_d, matriz_solucao_d, dimension);
	checkCUDAError("kernel invocation");
    cudaThreadSynchronize();
	cudaMemcpy( matriz_solucao_h, matriz_solucao_d, size_mat_sols, cudaMemcpyDeviceToHost );
 	checkCUDAError("memcpy-d-h");

	puts("\nSolucoes");
	for(int i = 0; i<24; ++i){
		printf("\nSulcao %d: %d", i, matriz_solucao_h[i]);
	}

	cudaFree( N_d );
 	/*
		colocar o free das outras variaveis
	*/

   return 0;
}

void checkCUDAError(const char *msg)
{
    cudaError_t err = cudaGetLastError();
    if( cudaSuccess != err)
    {
        fprintf(stderr, "Cuda error: %s: %s.\n", msg,
                             cudaGetErrorString( err) );
        exit(EXIT_FAILURE);
    }
}
