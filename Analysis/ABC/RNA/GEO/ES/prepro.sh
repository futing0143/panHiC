#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/ES

cut -f1-9 /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/ES/GSE248354_counts.txt | sed 's/\t/,/g' > ES_gene_count.csv