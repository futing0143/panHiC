#!/bin/bash

echo -e "\nProcessing rep1 191...\n\n\n"
sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_v1.2.sh "" 30 SRR8085191 rose "" ./rep1.txt 
echo -e "\nProcessing rep2 193...\n\n\n" # 之前写的是193 但是实际上是192
sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_last_v1.2.sh "" 30 SRR8085192 rose "" ./rep2.txt 