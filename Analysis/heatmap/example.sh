#!/bin/bash


grep 'KLRD1' /cluster2/home/futing/Project/panCancer/Analysis/SV/summary/loop_gene.raw \
| cut -f4,5,6 | sort -u > KLRD1_samples.txt