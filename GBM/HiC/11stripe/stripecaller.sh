#!/bin/bash


# XiaoTaoWang
name=$1
reso=${2:-5000}
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
cd /cluster/home/futing/Project/GBM/HiC/11stripe
source activate HiC

call-stripes -p ${data_dir}/${reso}/${name}_${reso}.cool \
	-O ./stripecaller/${name} \
	--nproc 10