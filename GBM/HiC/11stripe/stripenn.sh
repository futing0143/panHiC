#!/bin/bash

name=$1
reso=${2:-5000}
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
cd /cluster/home/futing/Project/GBM/HiC/11stripe
source activate HiC
stripenn compute --cool ${data_dir}/${reso}/${name}_${reso}.cool \
	--out ./stripenn/${name}_weight -k all -m 0.95,0.96,0.97,0.98,0.99 \
	--norm weight
