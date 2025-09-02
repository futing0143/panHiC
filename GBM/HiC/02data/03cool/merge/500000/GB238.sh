#!/bin/bash

cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/GB238.mcool::/resolutions/500000 | \
cooler load --format bg2 /cluster/home/futing/ref_genome/hg38_24.chrom.sizes:500000 \
- /cluster/home/futing/Project/GBM/HiC/02data/03cool/500000/GB238_500000.cool
cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/500000/GB238_500000.cool