#include <cmath>
#include <iostream>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <time.h>
#include <tuple>
#include <vector>

using namespace std;

void printOrders(vector<vector<int>>& orders) {
    for (vector<int> v : orders) {
        for (int i : v) {
            cout << i << " ";
        }
        cout << endl;
    }
}

void printOrdersInSequence(vector<int>& sequence,
                           vector<vector<int>>& orders,
                           int numCustomers,
                           int numProducts) {
    cout << "Best Sequence: " << endl;
    for (int i = 0; i < numProducts; i++) {
        cout << sequence[i] << " ";
    }
    cout << endl;

    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++)
            cout << orders[i][sequence[j]] << " ";
        cout << endl;
    }
}

// TODO: Test this function
// Calculates the maximum number of open stacks for a given producing sequence
int maximumOpenStacks(vector<int>& sequence,
                      vector<vector<int>>& orders,
                      int numCustomers,
                      int numProducts) {
    vector<int> toDo(numCustomers);
    vector<int> done(numCustomers);
    for (int customer = 0; customer < numCustomers; customer++) {
        done[customer] = 0;
        for (int product = 0; product < numProducts; product++) {
            // suppose that orders has only 1's and 0's
            toDo[customer] += orders[customer][product];
        }
    }

    int numOpenStacks = 0;
    for (int product : sequence) {
        for (int customer = 0; customer < numCustomers; customer++) {
            toDo[customer] -= orders[customer][product];
            done[customer] += orders[customer][product];
        }
        int currentOpenStacks = 0;
        for (int customer = 0; customer < numCustomers; customer++) {
            if (orders[customer][product] > 0 || (done[customer] > 0 &&
                                                  toDo[customer] > 0)) {
                currentOpenStacks++;
            }
        }
        if (currentOpenStacks > numOpenStacks) {
            numOpenStacks = currentOpenStacks;
        }
    }
    return numOpenStacks;
}

long factorial(int n) {
    return tgamma(n + 1);
}

vector<int> generateSequence(int k, int numProducts) {
    vector<int> sequence(numProducts);
    for (int i = 0; i < numProducts; i++) {
        sequence[i] = i;
    }
    for (int i = 0; i < numProducts; i++) {
        swap(sequence[k % (i + 1)], sequence[i]);
        k = k / (i + 1);
    }
    return sequence;
}

void bruteForceSolve(vector<vector<int>>& orders,
                     int numCustomers,
                     int numProducts) {
    // Generate all sequences
    int numSequences = factorial(numProducts);
    vector<vector<int>> sequences(numSequences);
    for (int i = 0; i < numSequences; i++) {
        sequences[i] = generateSequence(i, numProducts);
        // for (int j : sequences[i])
        //     cout << j << " ";
        // cout << endl;
    }

    // Calculate the maximum number of open stacks for each sequence
    vector<int> stackSizes(numSequences);
    for (int i = 0; i < numSequences; i++) {
        stackSizes[i] = maximumOpenStacks(sequences[i],
                                      orders,
                                      numCustomers,
                                      numProducts);
        // cout << stackSizes[i] << " ";
    }
    // cout << endl;

    // Calculate the global minimum
    int minStacks = numCustomers + 1;
    int bestI = -1;
    for (int i = 0; i < numSequences; i++) {
        if (stackSizes[i] < minStacks) {
            minStacks = stackSizes[i];
            bestI = i;
        }
    }
    printOrdersInSequence(sequences[bestI], orders, numCustomers, numProducts);
    cout << "OpenStacks: " << minStacks << endl;
}

void printSet(vector<bool>* s, int numProducts) {
    for (int i = 0; i < numProducts; i++) {
        if((*s)[i] == true)
            cout << i << " ";
    }
}

int a(int p,
      vector<bool>* s,
      vector<vector<int>>& orders,
      int numCustomers,
      int numProducts) {
    vector<bool> before(numCustomers);
    vector<bool> after(numCustomers);
    vector<bool> now(numCustomers);
    for (int i = 0; i < numCustomers; i++) {
        before[i] = false;
        after[i] = false;
        now[i] = false;
    }

    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++) {
            if (j == p && orders[i][j] > 0)
                now[i] = true;
            if ((*s)[j] == true && orders[i][j] > 0)
                after[i] = true;
            else if ((*s)[j] == false && orders[i][j] > 0)
                before[i] = true;
        }
    }

    int active_stacks = 0;
    for (int i = 0; i < numCustomers; i++) {
        if(now[i] || (before[i] && after[i]))
            active_stacks++;
    }

    return active_stacks;
}

string vecToString(vector<bool>* v) {
    string s;
    for (int i = 0; i < v->size(); i++) {
        if ((*v)[i] == true)
            s += to_string(i);
    }
    return s;
}

map<string, tuple<int, vector<int>>> cache;
tuple<int, vector<int>> getCache(vector<bool>* v) {
    string s = vecToString(v);
    if (cache.find(s) != cache.end())
        return cache[s];
    vector<int> sol;
    return make_tuple(-1, sol);
}

void setCache(vector<bool>* v, int value, vector<int> solution) {
    string s = vecToString(v);
    cache[s] = make_tuple(value, solution);
}

void resetCache() {
    cache.clear();
}

tuple<int, vector<int>> stacks(vector<bool>* s,
                               vector<vector<int>>& orders,
                               int numCustomers,
                               int numProducts) {
    tuple<int, vector<int>> cached = getCache(s);
    if (get<0>(cached) > -1)
        return cached;

    bool any = false;
    for (int i = 0; i < numProducts; i++) {
        if ((*s)[i] == true) {
            any = true;
            break;
        }
    }
    if (any == false) {
        vector<int> v;
        setCache(s, 0, v);
        return getCache(s);
    }

    vector<int> solution;
    int min_stacks = s->size() * 10;
    for (int p = 0; p < numProducts; p++) {
        if ((*s)[p] == true) {
            (*s)[p] = false;
            int active = a(p, s, orders, numCustomers, numProducts);
            tuple<int, vector<int>> after_sol = stacks(
                    s, orders, numCustomers, numProducts);
            int after = get<0>(after_sol);
            vector<int> sol = get<1>(after_sol);
            // cout << endl << "For set " << p << ", ";
            // printSet(s, numProducts);
            // cout << endl << "active: " << active << " after: " << after
            //      << endl;
            int max = (active > after) ? active : after;
            if (max < min_stacks){
                min_stacks = max;
                solution = sol;
                solution.push_back(p);
            }
            (*s)[p] = true;
        }
    }
    // cout << endl << "Calculating set ";
    // printSet(s, numProducts);
    // cout << endl << "min_stacks: " << min_stacks << endl;

    setCache(s, min_stacks, solution);
    return getCache(s);
}

void dpSolve(vector<vector<int>>& orders, int numCustomers, int numProducts) {
    // for each size of set generate the number of
    vector<bool> bag(numProducts);
    for (int i = 0; i < numProducts; i++) {
        bag[i] = true;
    }
    tuple<int, vector<int>> minStacks_solution = stacks(
            &bag, orders, numCustomers, numProducts);
    int minStacks = get<0>(minStacks_solution);
    vector<int> solution = get<1>(minStacks_solution);
    printOrdersInSequence(solution, orders, numCustomers, numProducts);
    cout << "OpenStacks: " << minStacks << endl;
}

int main(int argc, char** argv) {
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

    float totalTime = 0;
    float numInstances = 0;
    float minTime = 1000000;
    float maxTime = 0;

    string buffer;
    while (getline(cin, buffer)) {
        // Read input
        cout << "buffer: " << buffer << endl;
        getline(cin, buffer);

        int numCustomers = 0, numProducts = 0;
        istringstream nums(buffer);
        nums >> numCustomers;
        nums >> numProducts;

        vector<vector<int>> orders;
        for (int i = 0; i < numCustomers; i++) {
            getline(cin, buffer);
            istringstream customerOrders(buffer);
            vector<int> v;
            for (int j = 0; j < numProducts; j++) {
                int didOrder;
                customerOrders >> didOrder;
                v.push_back(didOrder);
            }
            orders.push_back(v);
        }

        cout << "numCustomers: " << numCustomers << endl
             << "numProducts: " << numProducts << endl;
        printOrders(orders);
        resetCache();

        // Solve
        clock_t start = clock();
        if (useBruteForce) {
            bruteForceSolve(orders, numCustomers, numProducts);
        }
        else {
            dpSolve(orders, numCustomers, numProducts);
        }
        clock_t end = clock();

        float time = (float)(end - start) / CLOCKS_PER_SEC;
        cout << "Took " << time << " seconds" << endl << endl;
        totalTime += time;
        numInstances++;
        minTime = (time < minTime) ? time : minTime;
        maxTime = (time > maxTime) ? time : maxTime;

        getline(cin, buffer);
    }

    cout << "Solved: " << numInstances << " instances" << endl;
    cout << "totalTime: " << totalTime << " seconds" << endl;
    cout << "minTime: " << minTime << " seconds" << endl;
    cout << "maxTime: " << maxTime << " seconds" << endl;
    cout << "Average: " << totalTime/numInstances << " seconds" << endl;

    return 0;
}
