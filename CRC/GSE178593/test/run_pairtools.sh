#!/bin/bash

source activate HiC # Activate your conda environment
cd /cluster2/home/futing/Project/panCancer/CRC/GSE178593/test

sh /cluster2/home/futing/Project/panCancer/CRC/GSE178593/test/pairtools_microC.sh \
	/cluster2/home/futing/Project/panCancer/CRC/GSE178593/test
