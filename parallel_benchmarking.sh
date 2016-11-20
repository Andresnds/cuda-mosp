#!/bin/sh
timeout 30m ./parallel dp < andre_10_14.txt > output/andre_10_14_parallel_dp.txt
echo "Done parallel dp andre_10_14.txt"

timeout 30m ./parallel dp < andre_10_15.txt > output/andre_10_15_parallel_dp.txt
echo "Done parallel dp andre_10_15.txt"

timeout 30m ./parallel dp < andre_10_16.txt > output/andre_10_16_parallel_dp.txt
echo "Done parallel dp andre_10_16.txt"

timeout 30m ./parallel dp < andre_10_17.txt > output/andre_10_17_parallel_dp.txt
echo "Done parallel dp andre_10_17.txt"

timeout 30m ./parallel dp < andre_10_18.txt > output/andre_10_18_parallel_dp.txt
echo "Done parallel dp andre_10_18.txt"

