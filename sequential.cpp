#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

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
    cout << endl;

    // Calculate the global minimum
    int minStacks = numCustomers + 1;
    int bestI = -1;
    for (int i = 0; i < numSequences; i++) {
        if (stackSizes[i] < minStacks) {
            minStacks = stackSizes[i];
            bestI = i;
        }
    }
    cout << "minStacks: " << minStacks << endl;
    cout << "sequence: ";
    for (int i = 0; i < numProducts; i++) {
        cout << sequences[bestI][i] << " ";
    }
    cout << endl;

    for (int i = 0; i < numCustomers; i++) {
        for (int j = 0; j < numProducts; j++)
            cout << orders[i][sequences[bestI][j]] << " ";
        cout << endl;
    }
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

int stacks(vector<bool>* s,
           vector<vector<int>>& orders,
           int numCustomers,
           int numProducts) {
    bool any = false;
    for (int i = 0; i < numProducts; i++) {
        if ((*s)[i] == true) {
            any = true;
            break;
        }
    }
    if (any == false) {
        return 0;
    }

    int min_stacks = s->size() * 10;
    for (int p = 0; p < numProducts; p++) {
        if ((*s)[p] == true) {
            (*s)[p] = false;
            int active = a(p, s, orders, numCustomers, numProducts);
            int after = stacks(s, orders, numCustomers, numProducts);
            // cout << endl << "For set " << p << ", ";
            // printSet(s, numProducts);
            // cout << endl << "active: " << active << " after: " << after << endl;
            int max = (active > after) ? active : after;
            if (max < min_stacks)
                min_stacks = max;
            (*s)[p] = true;
        }
    }
    // cout << endl << "Calculating set ";
    // printSet(s, numProducts);
    // cout << endl << "min_stacks: " << min_stacks << endl;

    return min_stacks;
}

void dpSolve(vector<vector<int>>& orders, int numCustomers, int numProducts) {
    // for each size of set generate the number of
    vector<bool> bag(numProducts);
    for (int i = 0; i < numProducts; i++) {
        bag[i] = true;
    }
    int min_stacks = stacks(&bag, orders, numCustomers, numProducts);
    cout << "minStacks: " << min_stacks << endl;
}

void solve(vector<vector<int>>& orders, int numCustomers, int numProducts) {
    for (vector<int> v : orders) {
        for (int i : v) {
            cout << i << " ";
        }
        cout << endl;
    }

    vector<int> sequence(numProducts);
    for (int i = 0; i < numProducts; i++) sequence[i] = i;
    cout << maximumOpenStacks(sequence, orders, numProducts, numCustomers)
         << endl;
}

int main(int argc, char** argv) {
    ifstream readFile;
    int numCustomers, numProducts;
    vector<vector<int>> orders;
    string input;
    // char output[1000];

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
        for (int i = 0; i < numCustomers; i++) {
            vector<int> v;
            for (int j = 0; j < numProducts; j++) {
                int output;
                readFile >> output;
                v.push_back(output);
            }
            orders.push_back(v);
        }
        // while (!readFile.eof()) {
        //     readFile >> output;
        //     cout << output << endl;
        // }
        readFile.close();
    } else {
        cout << "Not able to open the input file." <<  endl;
    }
    cout << "numCustomers: " << numCustomers << endl
         << "numProducts: " << numProducts << endl;
    // bruteForceSolve(orders, numCustomers, numProducts);
    dpSolve(orders, numCustomers, numProducts);
    return 0;
}