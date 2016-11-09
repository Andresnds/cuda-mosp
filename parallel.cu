#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <time.h>

#define NUM_BLOCKS 65535

using namespace std;

__device__ __host__
int mIndex(int i, int j, int n, int m) {
    return i*m + j;
}

double factorial(int n) {
    double x = n + 1;
    return tgamma(x);
}

void printOrders(int* orders, int numCustomers, int numProducts) {
    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            cout << orders[mIndex(i, j, numCustomers, numProducts)] << " ";
        }
        cout << endl;
    }
}

void printOrdersInSequence(int* sequence,
                           int* orders,
                           int numCustomers,
                           int numProducts) {
    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            cout << orders[mIndex(i, sequence[j], numCustomers, numProducts)]
                 << " ";
        }
        cout << endl;
    }
}

// Calculates the maximum number of open stacks for a given producing sequence
__device__ __host__
int maximumOpenStacks(int* sequence,
                      int* orders,
                      int numCustomers,
                      int numProducts) {
    int* toDo = (int*) malloc(numCustomers * sizeof(int));
    int* done = (int*) malloc(numCustomers * sizeof(int));
    for (int customer = 0; customer < numCustomers; customer++) {
        done[customer] = 0;
        toDo[customer] = 0;
        for (int product = 0; product < numProducts; product++) {
            // suppose that orders has only 1's and 0's
            toDo[customer] += orders[mIndex(customer, product, numCustomers,
                                            numProducts)];
        }
    }

    int numOpenStacks = 0;
    for (int i = 0; i < numProducts; i++) {
        int product = sequence[i];
        for (int customer = 0; customer < numCustomers; customer++) {
            if (orders[mIndex(customer,
                              product,
                              numCustomers,
                              numProducts)] > 0) {
                toDo[customer]--;
                done[customer]++;
            }
        }
        int currentOpenStacks = 0;
        for (int customer = 0; customer < numCustomers; customer++) {
            if ((done[customer] > 0 && toDo[customer] > 0) ||
                orders[mIndex(customer,
                              product,
                              numCustomers,
                              numProducts)] > 0) {
                currentOpenStacks++;
            }
        }
        if (currentOpenStacks > numOpenStacks) {
            numOpenStacks = currentOpenStacks;
        }
    }

    free(toDo);
    free(done);

    return numOpenStacks;
}

__device__ __host__
void generateSequence(int* sequence, int k, int numProducts) {
    for (int i = 0; i < numProducts; i++) {
        sequence[i] = i;
    }
    for (int i = 0; i < numProducts; i++) {
        int temp = sequence[k % (i + 1)];
        sequence[k % (i + 1)] = sequence[i];
        sequence[i] = temp;
        k = k / (i + 1);
    }
}

__global__
void calculateMaximumOpenStacks(int* stackSizes,
                                int* orders,
                                int numCustomers,
                                int numProducts,
                                int step) {
    int* sequence = (int*) malloc(numProducts * sizeof(int));
    generateSequence(sequence, step * NUM_BLOCKS + blockIdx.x, numProducts);
    stackSizes[blockIdx.x] = maximumOpenStacks(sequence,
                                               orders,
                                               numCustomers,
                                               numProducts);
    free(sequence);
}

void checkOk(cudaError_t err) {
    if (err != cudaSuccess) {
        cout << cudaGetErrorString(err) << endl;
        exit(EXIT_FAILURE);
    }
}

void bruteForceSolve(int* orders,
                     int numCustomers,
                     int numProducts) {
    int* orders_d;
    int sizeOrders = numCustomers * numProducts * sizeof(int);
    checkOk(cudaMalloc((void**) &orders_d, sizeOrders));
    checkOk(cudaMemcpy(orders_d, orders, sizeOrders, cudaMemcpyHostToDevice));

    int* stackSizes_d;
    double numSequences = factorial(numProducts);
    int sizeStacksSizes = NUM_BLOCKS * sizeof(int);
    checkOk(cudaMalloc((void**) &stackSizes_d, sizeStacksSizes));

    cout << "numSequences: " << numSequences << endl;

    int* stackSizes = (int*) malloc(sizeStacksSizes);
    int minStacks = numCustomers + 1;
    int bestK = -1;
    for (int i = 0; i < ceil(numSequences/NUM_BLOCKS); i++) {
        int numSequencesToProcess;
        if (numSequences - i * NUM_BLOCKS >= NUM_BLOCKS)
            numSequencesToProcess = NUM_BLOCKS;
        else
            numSequencesToProcess = numSequences - i * NUM_BLOCKS;

        // cout << "Step " << i << ". Calculating " << numSequencesToProcess
        //      << " More " << numSequences - i * NUM_BLOCKS << " to go." << endl;

        // Calculating maximum stack for each one of them
        calculateMaximumOpenStacks<<<numSequencesToProcess, 1>>>(stackSizes_d,
                                                                 orders_d,
                                                                 numCustomers,
                                                                 numProducts,
                                                                 i);

        checkOk(cudaMemcpy(stackSizes,
                           stackSizes_d,
                           sizeStacksSizes,
                           cudaMemcpyDeviceToHost));

        // Calculate the global minimum
        for (int j = 0; j < numSequencesToProcess; j++) {
            if (stackSizes[j] < minStacks) {
                minStacks = stackSizes[j];
                bestK = j + i * NUM_BLOCKS;
            }
        }
    }

    checkOk(cudaFree(orders_d));
    checkOk(cudaFree(stackSizes_d));

    free(stackSizes);

    // Debugging output

    cout << "minStacks: " << minStacks << endl;

    // Print sequence
    int* sequence = (int*) malloc(numProducts * sizeof(int));
    generateSequence(sequence, bestK, numProducts);
    cout << "Best sequence:" << endl;
    for (int i = 0; i < numProducts; i++) {
        cout << sequence[i] << " ";
    }
    cout << endl;

    // See orders being produced
    printOrdersInSequence(sequence, orders, numCustomers, numProducts);
    cout << "Open stacks: "
         << maximumOpenStacks(sequence, orders, numCustomers, numProducts)
         << endl;

    free(sequence);
    // End of debugging code
}

void dpSolve(int* orders) {
    // for each size of set generate the number of
}

int main(int argc, char** argv) {
    ifstream readFile;
    int numCustomers, numProducts;
    int* orders;

    char* input;
    if (argc > 1) {
        input = argv[1];
    } else {
        input = "input.txt";
    }
    cout << "Reading from " << input << endl;
    readFile.open(input);

    if (readFile.is_open()) {
        readFile >> numCustomers;
        readFile >> numProducts;
        orders = (int*) malloc(numCustomers * numProducts * sizeof(int));
        for (int i = 0; i < numCustomers; i++) {
            for (int j = 0; j < numProducts; j++) {
                int output;
                readFile >> output;
                orders[mIndex(i, j, numCustomers, numProducts)] = output;
            }
        }
        readFile.close();
    } else {
        cout << "Not able to open the input file." <<  endl;
    }
    cout << "numCustomers: " << numCustomers << endl
         << "numProducts: " << numProducts << endl;
    printOrders(orders, numCustomers, numProducts);
    clock_t start = clock();
    bruteForceSolve(orders, numCustomers, numProducts);
    clock_t end = clock();
    float seconds = (float)(end - start) / CLOCKS_PER_SEC;
    cout << "Took " << seconds << " seconds" << endl;
    return 0;
}
