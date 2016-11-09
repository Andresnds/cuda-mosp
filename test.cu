#include <iostream>
#include <cmath>

using namespace std;

void printDeviceProperties();

void checkOk(cudaError_t err) {
    if (err != cudaSuccess) {
        cout << cudaGetErrorString(err) << endl;
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char** argv) {
    // cout << "ceil(13/2) = " << ceil(13/2) << endl;
    // cout << "ceil(12/2) = " << ceil(12/2) << endl;

    printDeviceProperties();
    return 0;
}

void printDeviceProperties() {

    int device = -1;
    checkOk(cudaGetDevice(&device));
    cout << "Device: " << device << endl;

    cudaDeviceProp prop;
    checkOk(cudaGetDeviceProperties(&prop, device));
    cout << "Properties: "  << endl;

    // Those were added in CUDA 8.0
    // cout << "  hostNativeAtomicSupported: " << prop.hostNativeAtomicSupported << endl;
    // cout << "  concurrentManagedAccess: " << prop.concurrentManagedAccess << endl;
    // cout << "  pageableMemoryAccess: " << prop.pageableMemoryAccess << endl;
    // cout << "  singleToDoublePrecisionPerfRatio: " << prop.singleToDoublePrecisionPerfRatio << endl;


    cout << "  ECCEnabled: " << prop.ECCEnabled << endl;
    cout << "  asyncEngineCount: " << prop.asyncEngineCount << endl;
    cout << "  computeMode: " << prop.computeMode << endl;
    cout << "  concurrentKernels: " << prop.concurrentKernels << endl;
    cout << "  deviceOverlap: " << prop.deviceOverlap << endl;
    cout << "  globalL1CacheSupported: " << prop.globalL1CacheSupported << endl;
    cout << "  integrated: " << prop.integrated << endl;
    cout << "  isMultiGpuBoard: " << prop.isMultiGpuBoard << endl;
    cout << "  kernelExecTimeoutEnabled: " << prop.kernelExecTimeoutEnabled << endl;
    cout << "  l2CacheSize: " << prop.l2CacheSize << endl;
    cout << "  localL1CacheSupported: " << prop.localL1CacheSupported << endl;
    cout << "  major: " << prop.major << endl;
    cout << "  maxSurface1D: " << prop.maxSurface1D << endl;
    cout << "  maxSurface1DLayered[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxSurface1DLayered[i] << ", ";
    cout << endl;
    cout << "  maxSurface2D[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxSurface2D[i] << ", ";
    cout << endl;
    cout << "  maxSurface2DLayered[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxSurface2DLayered[i] << ", ";
    cout << endl;
    cout << "  maxSurface3D[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxSurface3D[i] << ", ";
    cout << endl;
    cout << "  maxSurfaceCubemap: " << prop.maxSurfaceCubemap << endl;
    cout << "  maxSurfaceCubemapLayered[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxSurfaceCubemapLayered[i] << ", ";
    cout << endl;
    cout << "  maxTexture1D: " << prop.maxTexture1D << endl;
    cout << "  maxTexture1DLayered[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxTexture1DLayered[i] << ", ";
    cout << endl;
    cout << "  maxTexture1DLinear: " << prop.maxTexture1DLinear << endl;
    cout << "  maxTexture1DMipmap: " << prop.maxTexture1DMipmap << endl;
    cout << "  maxTexture2D[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxTexture2D[i] << ", ";
    cout << endl;
    cout << "  maxTexture2DGather[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxTexture2DGather[i] << ", ";
    cout << endl;
    cout << "  maxTexture2DLayered[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxTexture2DLayered[i] << ", ";
    cout << endl;
    cout << "  maxTexture2DLinear[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxTexture2DLinear[i] << ", ";
    cout << endl;
    cout << "  maxTexture2DMipmap[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxTexture2DMipmap[i] << ", ";
    cout << endl;
    cout << "  maxTexture3D[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxTexture3D[i] << ", ";
    cout << endl;
    cout << "  maxTexture3DAlt[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxTexture3DAlt[i] << ", ";
    cout << endl;
    cout << "  maxTextureCubemap: " << prop.maxTextureCubemap << endl;
    cout << "  maxTextureCubemapLayered[2]: ";
    for (int i = 0; i < 2; i ++) cout << prop.maxTextureCubemapLayered[i] << ", ";
    cout << endl;
    cout << "  memPitch: " << prop.memPitch << endl;
    cout << "  memoryBusWidth: " << prop.memoryBusWidth << endl;
    cout << "  memoryClockRate: " << prop.memoryClockRate << endl;
    cout << "  minor: " << prop.minor << endl;
    cout << "  multiGpuBoardGroupID: " << prop.multiGpuBoardGroupID << endl;
    cout << "  multiProcessorCount: " << prop.multiProcessorCount << endl;
    cout << "  pciBusID: " << prop.pciBusID << endl;
    cout << "  pciDeviceID: " << prop.pciDeviceID << endl;
    cout << "  pciDomainID: " << prop.pciDomainID << endl;
    cout << "  regsPerBlock: " << prop.regsPerBlock << endl;
    cout << "  regsPerMultiprocessor: " << prop.regsPerMultiprocessor << endl;
    cout << "  sharedMemPerBlock: " << prop.sharedMemPerBlock << endl;
    cout << "  sharedMemPerMultiprocessor: " << prop.sharedMemPerMultiprocessor << endl;
    cout << "  streamPrioritiesSupported: " << prop.streamPrioritiesSupported << endl;
    cout << "  surfaceAlignment: " << prop.surfaceAlignment << endl;
    cout << "  tccDriver: " << prop.tccDriver << endl;
    cout << "  textureAlignment: " << prop.textureAlignment << endl;
    cout << "  texturePitchAlignment: " << prop.texturePitchAlignment << endl;

    cout << "---------------------------------" << endl;
    cout << "  name: " << prop.name << endl;
    cout << "  clockRate: " << prop.clockRate << endl;
    cout << "  canMapHostMemory: " << prop.canMapHostMemory << endl;
    cout << "  managedMemory: " << prop.managedMemory << endl;
    cout << "  maxGridSize[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxGridSize[i] << ", ";
    cout << endl;
    cout << "  maxThreadsDim[3]: ";
    for (int i = 0; i < 3; i ++) cout << prop.maxThreadsDim[i] << ", ";
    cout << endl;
    cout << "  maxThreadsPerBlock: " << prop.maxThreadsPerBlock << endl;
    cout << "  maxThreadsPerMultiProcessor: " << prop.maxThreadsPerMultiProcessor << endl;
    cout << "  totalConstMem: " << prop.totalConstMem << endl;
    cout << "  totalGlobalMem: " << prop.totalGlobalMem << endl;
    cout << "  unifiedAddressing: " << prop.unifiedAddressing << endl;
}