#!/bin/bash


file=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/GBM_10000.cool

source activate HiC
cooler balance --max-iters 1000 -f $file
