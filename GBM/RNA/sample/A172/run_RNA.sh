#!/bin/bash
cd /cluster/home/futing/Project/GBM/RNA/A172

find /cluster/home/futing/Project/GBM/RNA/A172/ -name "*.fastq.gz" -exec mv {} . \;

/cluster/home/futing/pipeline/RNA/rna_pe.sh /cluster/home/futing/Project/GBM/RNA/A172
