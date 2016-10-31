#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

__device__ __host__
int mIndex(int i, int j, int n, int m) {
  return i*m + j;
}

int factorial(int n) {
    return tgamma(n + 1);
}

// Calculates the maximum number of open stacks for a given producing sequence
__device__
int maximumOpenStacks(int* sequence,
                      int* orders,
                      int numCustomers,
                      int numProducts) {
    int* toDo = (int*) malloc(numCustomers * sizeof(int));
    int* done = (int*) malloc(numCustomers * sizeof(int));
    for (int customer = 0; customer < numCustomers; customer++) {
        done[customer] = 0;
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
            toDo[customer] -= orders[mIndex(customer, product, numCustomers,
                                            numProducts)];
            done[customer] += orders[mIndex(customer, product, numCustomers,
                                            numProducts)];
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

__global__
void generateSequence(int* sequences, int numProducts) {
    int begin = blockIdx.x * numProducts;
    int end = begin + numProducts;
    int k = blockIdx.x;
    for (int i = begin; i < end; i++) {
        sequences[i] = i;
    }
    for (int i = begin; i < end; i++) {
        int temp = sequences[k % (i + 1)];
        sequences[k % (i + 1)] = sequences[i];
        sequences[i] = temp;
        k = k / (i + 1);
    }
}

__global__
void calculateMaximumOpenStacks(int* sequences,
                                int* stackSizes,
                                int* orders,
                                int numCustomers,
                                int numProducts) {
    int begin = blockIdx.x * numProducts;
    int* sequence = (int*) malloc(numProducts * sizeof(int));
    for (int i = 0; i < numProducts; i++) {
        sequence[i] = sequences[begin + i];
    }

    stackSizes[blockIdx.x] = maximumOpenStacks(sequence,
                                               orders,
                                               numCustomers,
                                               numProducts);
    free(sequence);
}

void bruteForceSolve(int* orders,
                     int numCustomers,
                     int numProducts) {

    int* orders_d;
    int sizeOrders = numCustomers * numProducts * sizeof(int);
    cudaMalloc((void**) &orders_d, sizeOrders);
    cudaMemcpy(orders_d, orders, sizeOrders, cudaMemcpyHostToDevice);

    int* sequences_d;
    int numSequences = factorial(numProducts);
    int sizeSequences = numSequences * numProducts * sizeof(int);
    cudaMalloc((void**) &sequences_d, sizeSequences);

    // Generating all possible sequences
    generateSequence<<<numSequences, 1>>>(sequences_d, numProducts);

    int* stackSizes_d;
    int sizeStacksSizes = numSequences * sizeof(int);
    cudaMalloc((void**) &stackSizes_d, sizeStacksSizes);

    // Calculating maximum stack for each one of them
    calculateMaximumOpenStacks<<<numSequences, 1>>>(sequences_d,
                                                    stackSizes_d,
                                                    orders_d,
                                                    numCustomers,
                                                    numProducts);

    int* stackSizes = (int*) malloc(sizeStacksSizes);
    cudaMemcpy(stackSizes,
               stackSizes_d,
               sizeStacksSizes,
               cudaMemcpyDeviceToHost);

    cudaFree(orders_d);
    cudaFree(sequences_d);
    cudaFree(stackSizes_d);

    // Calculate the global minimum
    int minStacks = numCustomers + 1;
    for (int i = 0; i < numSequences; i++) {
        if (stackSizes[i] < minStacks) {
            minStacks = stackSizes[i];
        }
    }
    cout << "minStacks: " << minStacks << endl;

    free(stackSizes);
}

void dpSolve(int* orders) {
    // for each size of set generate the number of
}

void printOrders(int* orders, int numCustomers, int numProducts) {
    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            cout << orders[mIndex(i, j, numCustomers, numProducts)] << " ";
        }
        cout << endl;
    }
}

int main(int argc, char** argv) {
    ifstream readFile;
    int numCustomers, numProducts;
    int* orders;

    string input;
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
    bruteForceSolve(orders, numCustomers, numProducts);
    return 0;
}