
/*
 * main.c
 *
 *  Created on: 26/01/2011
 *      Author: einstein/carneiro
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <cuda.h>

#define mat_h(i,j) mat_h[i*N+j]
#define mat_d(i,j) mat_d[i*N_l+j]
#define mat_block(i,j) mat_block[i*N_l+j]
#define proximo(x) x+1
#define anterior(x) x-1
#define MAX 8192
#define INFINITO 999999
#define ZERO 0
#define ONE 1

#define _VAZIO_      -1
#define _VISITADO_    1
#define _NAO_VISITADO_ 0

int qtd = 0;
int custo = 0;
int N;
int melhor = INFINITO;
int upper_bound;

int mat_h[MAX];


static void HandleError( cudaError_t err,
                         const char *file,
                         int line ) {
    if (err != cudaSuccess) {
        printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
                file, line );
        exit( EXIT_FAILURE );
    }
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))


#define HANDLE_NULL( a ) {if (a == NULL) { \
                            printf( "Host memory failed in %s at line %d\n", \
                                    __FILE__, __LINE__ ); \
                            exit( EXIT_FAILURE );}}

void read() {
	int i;
	//scanf("%d", &upper_bound);
	scanf("%d", &N);
	for (i = 0; i < (N * N); i++) {
		scanf("%d", &mat_h[i]);
	}

}

int calculaNPrefixos(int nivelPrefixo, int nVertice) {
	int x = nVertice - 1;
	int i;
	for (i = 1; i < nivelPrefixo-1; ++i) {
		x *= nVertice - i-1;
	}
	return x;
}

void fillFixedPaths(short* preFixo, int nivelPrefixo) {
	char flag[16];
	int vertice[16]; //representa o ciclo
	int cont = 0;
	int i, nivel; //para dizer que 0-1 ja foi visitado e a busca comeca de 1, bote 2


	for (i = 0; i < N; ++i) {
		flag[i] = 0;
		vertice[i] = -1;
	}

	vertice[0] = 0; //aqui!!!! vertice[nivel] = idx vflag[idx] = 1
	flag[0] = 1;
	nivel = 1;
	while (nivel >= 1) { // modificar aqui se quiser comecar a busca de determinado nivel

		if (vertice[nivel] != -1) {
			flag[vertice[nivel]] = 0;
		}

		do {
			vertice[nivel]++;
		} while (vertice[nivel] < N && flag[vertice[nivel]]); //




		if (vertice[nivel] < N) { //vertice[x] vertice no nivel x


			flag[vertice[nivel]] = 1;
			nivel++;

			if (nivel == nivelPrefixo) {
				for (i = 0; i < nivelPrefixo; ++i) {
					preFixo[cont * nivelPrefixo + i] = vertice[i];
//					printf("%d ", vertice[i]);
				}
//				printf("\n");
				cont++;
				nivel--;
			}
		} else {
			vertice[nivel] = -1;
			nivel--;
		}//else
	}//while
}


/*@OK: ter N e UB locais.
	
  @TODO em 7: mat_d por bloco? õ0 Prefixos compartilhados? õ0

*/
__global__ void dfs_cuda_UB(int N, int *mat_d, short *preFixos_d,
		int nPreFixos, int nivelPrefixo, int upper_bound, int *sols_d,int *melhorSol_d) {

	register int idx = blockIdx.x * blockDim.x + threadIdx.x;
	register int flag[16];
	register int vertice[16]; //representa o ciclo
	
	register int N_l = N;
	
	register int i, nivel; //para dizer que 0-1 ja foi visitado e a busca comeca de 1, bote 2
	register int custo;
	register int qtd_solucoes_thread = 0;
	register int UB_local = upper_bound;
	register int nivelGlobal = nivelPrefixo;

	if (idx < nPreFixos) { //(@)botar algo com vflag aqui, pois do jeito que esta algumas threads tentarao descer.
			
		for (i = 0; i < N_l; ++i) {
			vertice[i] = _VAZIO_;
			flag[i] = _NAO_VISITADO_;
		}
		
		vertice[0] = 0;
		flag[0] = _VISITADO_;
		custo= ZERO;
		
		for (i = 1; i < nivelGlobal; ++i) {
			vertice[i] = preFixos_d[idx * nivelGlobal + i];
			flag[vertice[i]] = _VISITADO_;
			custo += mat_d(vertice[i-1],vertice[i]);
		}
		
		nivel=nivelPrefixo;

	

		while (nivel >= nivelGlobal ) { // modificar aqui se quiser comecar a busca de determinado nivel

			if (vertice[nivel] != _VAZIO_) {
				flag[vertice[nivel]] = _NAO_VISITADO_;
				custo -= mat_d(vertice[anterior(nivel)],vertice[nivel]);
			}

			do {
				vertice[nivel]++;
			} while (vertice[nivel] < N_l && flag[vertice[nivel]]); //


			if (vertice[nivel] < N_l) { //vertice[x] vertice no nivel x
				custo += mat_d(vertice[anterior(nivel)],vertice[nivel]);
				flag[vertice[nivel]] = _VISITADO_;
				nivel++;

				if (nivel == N_l) { //se o vértice do nível for == N, entao formou o ciclo e vc soma peso + vertice anterior -> inicio
						
					++qtd_solucoes_thread;

					if (custo + mat_d(vertice[anterior(nivel)],0) < UB_local) {
						UB_local = custo + mat_d(vertice[anterior(nivel)],0);
					}
					nivel--;
				}
				//else {
					//if (custo > custoMin_d[0])
						//nivel--; //poda, LB maior que UB
				//}
			}
			else {
				vertice[nivel] = _VAZIO_;
				nivel--;
			}//else
		}//while

		sols_d[idx] = qtd_solucoes_thread;
		melhorSol_d[idx] = UB_local;

	}//dfs



}//kernel

void checkCUDAError(const char *msg) {
	cudaError_t err = cudaGetLastError();
	if (cudaSuccess != err) {
		fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
}

int main() {

	read();

	int *mat_d;
	int otimo_global = INFINITO;
	int qtd_sols_global = ZERO;

	upper_bound = INFINITO;

    cudaEvent_t start, stop;
    HANDLE_ERROR( cudaEventCreate( &start ) );
    HANDLE_ERROR( cudaEventCreate( &stop ) );

    float elapsedTime;

	int nivelPreFixos = 5;//Numero de niveis prefixados; o que nos permite utilizar mais threads. 
	int nPreFixos = calculaNPrefixos(nivelPreFixos,N);

	int block_size =192; //number threads in a block
	int n_blocks = nPreFixos / block_size + (nPreFixos % block_size == 0 ? 0 : 1); // # of blocks

	int *sols_h, *sols_d;
	int *melhorSol_h, *melhorSol_d;


	short * path_h = (short*) malloc(sizeof(short) * nPreFixos * nivelPreFixos);
	short * path_d;



	sols_h = (int*)malloc(sizeof(int)*nPreFixos);
	melhorSol_h = (int*)malloc(sizeof(int)*nPreFixos);

	for(int i = 0; i<nPreFixos; ++i)		
		melhorSol_h[i] = INFINITO;
	

	
	fillFixedPaths(path_h, nivelPreFixos);




	HANDLE_ERROR( cudaMalloc((void **) &mat_d, N * N * sizeof(int)));
	HANDLE_ERROR( cudaMalloc((void **) &path_d, nPreFixos*nivelPreFixos*sizeof(short)));

	HANDLE_ERROR( cudaMalloc((void **) &sols_d, sizeof(int)*nPreFixos));
	HANDLE_ERROR( cudaMalloc((void **) &melhorSol_d, sizeof(int)*nPreFixos));

	HANDLE_ERROR( cudaMemcpy(mat_d, mat_h, N * N * sizeof(int), cudaMemcpyHostToDevice));
	HANDLE_ERROR( cudaMemcpy(path_d, path_h, nPreFixos*nivelPreFixos*sizeof(short), cudaMemcpyHostToDevice));
	HANDLE_ERROR( cudaMemcpy(melhorSol_d, melhorSol_h, nPreFixos*sizeof(int), cudaMemcpyHostToDevice));

	

	HANDLE_ERROR( cudaThreadSynchronize());

    HANDLE_ERROR( cudaEventRecord( start, 0 ) );

	dfs_cuda_UB<<< n_blocks,block_size >>>(N,mat_d,path_d, nPreFixos , nivelPreFixos,upper_bound, sols_d,melhorSol_d);
	
	
	HANDLE_ERROR( cudaThreadSynchronize());

    HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
    HANDLE_ERROR( cudaEventSynchronize( stop ) );


    HANDLE_ERROR( cudaEventElapsedTime( &elapsedTime,start, stop ) );
    HANDLE_ERROR( cudaEventDestroy( start ) );
    HANDLE_ERROR( cudaEventDestroy( stop ) );

	
	HANDLE_ERROR( cudaMemcpy(sols_h, sols_d, sizeof(int)*nPreFixos, cudaMemcpyDeviceToHost));
	HANDLE_ERROR( cudaMemcpy(melhorSol_h, melhorSol_d, sizeof(int)*nPreFixos, cudaMemcpyDeviceToHost));
	
	for(int i = 0; i<nPreFixos; ++i){
		qtd_sols_global+=sols_h[i];
		if(melhorSol_h[i]<otimo_global)
			otimo_global = melhorSol_h[i];
		//printf("\nSolucoes encontradas pela thread %d: %d", i, sols_h[i]);	
		//printf("\n\tMelhor solucao encontrada pela thread %d: %d", i, melhorSol_h[i]);
	}

	puts("\n\n\n\n");
	printf("\tniveis preenchidos: %d.\n",nivelPreFixos);
	printf("\tthreads por bloco: %d.\n",block_size);
	printf("\tthreads geradas: %d.\n",nPreFixos);
	printf("\tnBlocos: %d.\n",n_blocks);
	printf("\nQuantidade de solucoes encontradas: %d.", qtd_sols_global);
	printf("\n\tOtimo global: %d,", otimo_global);
	printf( "\n\tKernel time:%3.1f ms\n", elapsedTime );
	
	HANDLE_ERROR( cudaFree(mat_d));
	HANDLE_ERROR( cudaFree(sols_d));
	HANDLE_ERROR( cudaFree(path_d));
	HANDLE_ERROR( cudaFree(melhorSol_d));

	return 0;
}
