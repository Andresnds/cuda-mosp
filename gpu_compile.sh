nvcc parallel.cu -Wno-deprecated-gpu-targets -o parallel && ./parallel input10.txt dp; rm parallel

