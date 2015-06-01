cudaArray* cu_array;
texture<float, 2> tex;

// Allocate array
cudaMallocArray(&cu_array, cudaCreateChannelDesc<float>(), width, height);

// Copy image data to array
cudaMemcpy(cu_array, image, width*height, cudaMemcpyHostToDevice);

// Bind the array to the texture
cudaBindTexture(tex, cu_array);

// Run kernel
dim3 blockDim(16, 16, 1);
dim3 gridDim(width / blockDim.x, height / blockDim.y, 1);
kernel<<< gridDim, blockDim, 0 >>>(d_odata, width, height);
cudaUnbindTexture(tex);

__global__ void kernel(float* odata, int height, int width)
{
unsigned int x = blockIdx.x*blockDim.x + threadIdx.x;
unsigned int y = blockIdx.y*blockDim.y + threadIdx.y;
float c = texfetch(tex, x, y);
odata[y*width+x] = c;
}
