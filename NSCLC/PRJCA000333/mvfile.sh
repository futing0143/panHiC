#!/bin/bash


for name in A549 5534N 5534T 6405N 6405T
do
	# mkdir -p /cluster2/home/futing/Project/panCancer/NSCLC/PRJCA000333/${name}
	cd /cluster2/home/futing/Project/panCancer/NSCLC/PRJCA000333/
	# mv ${name}*gz /cluster2/home/futing/Project/panCancer/NSCLC/PRJCA000333/${name}/
	sh /cluster2/home/futing/Project/panCancer/NSCLC/sbatch.sh PRJCA000333 ${name} MboI
done