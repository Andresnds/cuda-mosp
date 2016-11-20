#!/bin/sh
timeout 30m ./parallel bf < andre_10_2.txt > output/andre_10_2_parallel_bf.txt
echo "Done parallel bf andre_10_2.txt"

timeout 30m ./parallel bf < andre_10_3.txt > output/andre_10_3_parallel_bf.txt
echo "Done parallel bf andre_10_3.txt"

timeout 30m ./parallel bf < andre_10_4.txt > output/andre_10_4_parallel_bf.txt
echo "Done parallel bf andre_10_4.txt"

timeout 30m ./parallel bf < andre_10_5.txt > output/andre_10_5_parallel_bf.txt
echo "Done parallel bf andre_10_5.txt"

timeout 30m ./parallel bf < andre_10_6.txt > output/andre_10_6_parallel_bf.txt
echo "Done parallel bf andre_10_6.txt"

timeout 30m ./parallel bf < andre_10_7.txt > output/andre_10_7_parallel_bf.txt
echo "Done parallel bf andre_10_7.txt"

timeout 30m ./parallel bf < andre_10_8.txt > output/andre_10_8_parallel_bf.txt
echo "Done parallel bf andre_10_8.txt"

timeout 30m ./parallel bf < andre_10_9.txt > output/andre_10_9_parallel_bf.txt
echo "Done parallel bf andre_10_9.txt"