#include<stdio.h>
#include <cuda.h>
#include <string.h>


typedef struct cudaDeviceProp cudaDevProp_t;

int main(int argc, char** argv){
    int ct,dev;
    cudaDevProp_t prop;
 
    cudaGetDeviceCount(&ct); //Verificar se existe dispositivo cuda. Passa o endereco de uma variavel inteira.

    if(ct == 0){
        printf("\nNo CUDA device found.\n");
        exit(0);
    }
    else{euahieaiueuiaeaihea
	cudaGetDevice(&dev); /*verificara qual dos dispositivos esta ativo*/

	/*
	    Se existirem multiplos dispositivos, funcao cudaSetDevice pode ser utilizada
	    
	*/
        cudaGetDeviceProperties(&prop,dev);
        
	printf("\n%d Device Found\n",ct);
        printf("\nThe Device ID is %d\n",dev);
	printf("\tDevice Name : %s",prop.name);
        printf("\nThe Properties of the Device with ID %d are:\n",dev);
	printf("\n\tCompute capability: %d.%d", prop.major, prop.minor);
	printf("\n\tCompute mode: %d", prop.computeMode);
	printf("\n\tNumber of multiprocessors: %d", prop.multiProcessorCount);	
	printf("\n\tDevice clock rate (Khz): %d", prop.clockRate);
	
	printf("\n\tDevice Memory Size (in Mbytes) : %lu",(unsigned long)prop.totalGlobalMem/1000000);
	printf("\n\tShared memory per block (in bytes): %lu",(unsigned long)prop.sharedMemPerBlock);
	printf("\n\tNumber of registers per block: %d", prop.regsPerBlock);
	puts("\n");
	printf("\n\tNumber of threads per warp: %d", prop.warpSize);
	printf("\n\tNumber of threads per block: %d", prop.maxThreadsPerBlock);
	printf("\n\tMax dimensions of a block:\n\t\tX:%d, Y:%d, Z:%d", prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);
	printf("\n\tMax dimensions of a grid:\n\t\tX:%d, Y:%d, Z:%d", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
	
    }

        
        /*
	char name[256]; *
        size_t totalGlobalMem; *
        size_t sharedMemPerBlock; *
        int regsPerBlock; *
        int warpSize; *
        size_t memPitch;
        int maxThreadsPerBlock;*
        int maxThreadsDim[3];*
        int maxGridSize[3];*

        size_t totalConstMem;
        int major;*
        int minor;*
        int clockRate;*
        size_t textureAlignment;
        int deviceOverlap;
        int multiProcessorCount*;
        int kernelExecTimeoutEnabled;
        int integrated;
        int canMapHostMemory;
        int computeMode;*/

    printf("\n");

    return 0;
}

