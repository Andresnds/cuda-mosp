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

int64_t cache[100];
int64_t cached = 0;
int64_t factorial(int64_t n) {
    if (n < 2) return 1;
    if (n > cached) {
        cache[n] = n * factorial(n-1);
        cached = n;
        // cout << "Calculating factorial " << n <<": " << cache[n] << endl;
    }
    return cache[n];
}

void printOrders(int* orders, int numCustomers, int numProducts) {
    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            cout << orders[mIndex(i, j, numCustomers, numProducts)] << " ";
        }
        cout << endl;
    }
}

void printSet(int set, int numProducts) {
    for (int i = 0; i < numProducts; i++) {
        cout << set % 2 << " ";
        set /= 2;
    }
    cout << endl;
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
        cout << cudaGetErrorString(err) << " at " << __LINE__ << endl;
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
    int64_t numSequences = factorial(numProducts);
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

int64_t combination(int n, int k) {
    return factorial(n)/factorial(k)/factorial(n-k);
}

__device__
bool contains(int set, int p) {
    for (int i = 0; i < p; i++) {
        set /= 2;
    }
    // cout << set << endl;
    return set % 2;
}

__device__ __host__
int remove(int set, int p) {
    int stack = 0;
    int offset = 1;
    for (int i = 0; i < 32; i++) {
        if (i != p)
            stack += (set % 2) * offset;
        set /= 2;
        offset *= 2;
    }
    return stack;
}

__device__
int a(int p,
      int set,
      int* orders,
      int numCustomers,
      int numProducts) {
    bool* before = (bool*) malloc(numCustomers * sizeof(bool));
    bool* after = (bool*) malloc(numCustomers * sizeof(bool));
    bool* now = (bool*) malloc(numCustomers * sizeof(bool));
    for (int i = 0; i < numCustomers; i++) {
        before[i] = false;
        after[i] = false;
        now[i] = false;
    }

    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            if (j == p &&
                orders[mIndex(i, j, numCustomers, numProducts)] > 0) {
                now[i] = true;
            }
            if (contains(set, j) == true &&
                orders[mIndex(i, j, numCustomers, numProducts)] > 0) {
                after[i] = true;
            }
            if (contains(set, j) == false &&
                orders[mIndex(i, j, numCustomers, numProducts)] > 0) {
                before[i] = true;
            }
        }
    }

    // cout << "Testing after and before for set: " << set << " and product " << p << endl;
    // printSet(set, numProducts);

    int active_stacks = 0;
    for (int i = 0; i < numCustomers; i++) {
        if(now[i] || (before[i] && after[i])) {
            active_stacks++;
            // cout << i << " ";
        }
    }
    // cout << endl;

    free(now);
    free(after);
    free(before);

    // cout << active_stacks << " active" << endl;

    return active_stacks;
}

__global__
void computeStacks(int offset,
                   int* sets,
                   int* stacksResults,
                   int* bestP,
                   int* orders,
                   int numCustomers,
                   int numProducts) {
    int set = sets[offset + blockIdx.x];

    if (set == 0) {
        stacksResults[set] = 0;
        return;
    }

    int best = -1;
    int min_stacks = numCustomers * 10;
    for (int p = 0; p < numProducts; p++) {
        if (contains(set, p)) {
            int newSet = remove(set, p);
            int active = a(p, newSet, orders, numCustomers, numProducts);
            int after = stacksResults[newSet];
            int max = (active > after) ? active : after;
            if (max < min_stacks) {
                min_stacks = max;
                best = p;
            }
        }
    }

    stacksResults[set] = min_stacks;
    bestP[set] = best;
}

int countOnes(int n) {
    int ones = 0;
    while (n > 0) {
        ones += n % 2;
        n /= 2;
    }
    return ones;
}

void dpSolve(int* orders, int numCustomers, int numProducts) {
    int* orders_d;
    int sizeOrders = numCustomers * numProducts * sizeof(int);
    checkOk(cudaMalloc((void**) &orders_d, sizeOrders));
    checkOk(cudaMemcpy(orders_d, orders, sizeOrders, cudaMemcpyHostToDevice));

    int** sorted_sets = (int**) malloc((numProducts + 1) * sizeof(int*));
    int* combinations = (int*) malloc((numProducts + 1) * sizeof(int*));
    for (int i = 0; i < (numProducts + 1); i++) {
        int numCombinations = combination(numProducts, i);
        sorted_sets[i] = (int*) malloc(numCombinations * sizeof(int));
        combinations[i] = 0;
    }

    for (int i = 0; i < pow(2, numProducts); i++) {
        int ones = countOnes(i);
        sorted_sets[ones][combinations[ones]] = i;
        combinations[ones]++;
    }

    int setsSize = pow(2, numProducts) * sizeof(int);
    int* sets = (int*) malloc(setsSize);
    int* sets_d;
    checkOk(cudaMalloc((void**) &sets_d, setsSize));
    int i = 0;
    for (int j = 0; j < (numProducts + 1); j++) {
        for (int k = 0; k < combinations[j]; k++) {
            sets[i] = sorted_sets[j][k];
            i++;
        }
    }
    checkOk(cudaMemcpy(sets_d, sets, setsSize, cudaMemcpyHostToDevice));

    int stacksResultsSize = pow(2, numProducts) * sizeof(int);
    int* stacksResults = (int*) malloc(stacksResultsSize);
    int* stacksResults_d;
    checkOk(cudaMalloc((void**) &stacksResults_d, stacksResultsSize));


    int bestPSize = pow(2, numProducts) * sizeof(int);
    int* bestP = (int*) malloc(bestPSize);
    int* bestP_d;
    checkOk(cudaMalloc((void**) &bestP_d, bestPSize));

    int offset = 0;
    for (int setSize = 0;  setSize < numProducts + 1;  setSize++) {
        computeStacks<<<combinations[setSize], 1>>>(offset,
                                                    sets_d,
                                                    stacksResults_d,
                                                    bestP_d,
                                                    orders_d,
                                                    numCustomers,
                                                    numProducts);
        offset += combinations[setSize];
    }

    checkOk(cudaMemcpy(stacksResults, stacksResults_d, stacksResultsSize, cudaMemcpyDeviceToHost));

    checkOk(cudaMemcpy(bestP, bestP_d, bestPSize, cudaMemcpyDeviceToHost));

    // cout << "bestP" << endl;
    // for (int i = 0; i < pow(2, numProducts); i++) {
    //     cout << bestP[i] << " ";
    // }
    // cout << endl;

    // cout << "stacksResults" << endl;
    // for (int i = 0; i < pow(2, numProducts); i++) {
    //     cout << stacksResults[i] << " ";
    // }
    // cout << endl;

    cout << "Best sequence:" << endl;
    int set = pow(2, numProducts) - 1;
    int* sequence = (int*) malloc(numProducts * sizeof(int));
    for (int i = 0; i < numProducts; i++) {
        int best = bestP[set];
        set = remove(set, best);
        sequence[i] = best;
        cout << best << " ";
    }
    cout << endl;
    printOrdersInSequence(sequence, orders, numCustomers, numProducts);

    cout << "OpenStacks: " << stacksResults[(int) pow(2, numProducts) - 1] << endl;

    // Freeing memory

    checkOk(cudaFree(bestP_d));
    checkOk(cudaFree(stacksResults_d));
    checkOk(cudaFree(sets_d));
    checkOk(cudaFree(orders_d));

    free(bestP);
    free(stacksResults);
    free(sets);
    free(combinations);
    for (int i = 0; i < (numProducts + 1); i++) free(sorted_sets[i]);
    free(sorted_sets);

}

int main(int argc, char** argv) {
    ifstream readFile;
    int numCustomers, numProducts;
    int* orders;

    bool useBruteForce = false;
    if (argc < 1 || (strncmp(argv[1], "bf", 2) != 0 &&
                     strncmp(argv[1], "dp", 2) != 0)) {
        cout << "Specify if should use \"bf\" or \"dp\" as the first argument"
             << endl;
        exit(EXIT_FAILURE);
    } else {
        if (strncmp(argv[1], "bf", 2) == 0) {
            cout << "Solving by Brute Force..." << endl;
            useBruteForce = true;
        } else {
            cout << "Solving by Dynamic Programming..." << endl;
            useBruteForce = false;
        }
    }

    if (argc < 2) {
        cout << "Specify the input file as the second argument" << endl;
        exit(EXIT_FAILURE);
    }

    char* input;
    input = argv[2];
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
    if (useBruteForce) {
        bruteForceSolve(orders, numCustomers, numProducts);
    }
    else {
        dpSolve(orders, numCustomers, numProducts);
    }
    clock_t end = clock();
    float seconds = (float)(end - start) / CLOCKS_PER_SEC;
    cout << "Took " << seconds << " seconds" << endl;


    return 0;
}
