#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000)
cd /cluster2/home/futing/Project/panCancer/QC/nContacts
scripts=/cluster2/home/futing/Project/panCancer/QC/nContacts/hicInfo.py
source activate HiC

# find /cluster2/home/futing/Project/panCancer -name '*_50000.cool' | while read file;do

while IFS=$'\t' read -r cancer gse cell ncell;do
	file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/cool/${cell}_50000.cool"
	cell=$(cut -f9 -d '/' <<< "$file")
	gse=$(cut -f8 -d '/' <<< "$file")
	cancer=$(cut -f7 -d '/' <<< "$file")
	echo -e "Processing $cell $gse and $cancer.."
	hicInfo -m $file >> hicInfo_0910.log

done < "/cluster2/home/futing/Project/panCancer/check/hic/insul0910.txt"

python $scripts hicInfo_0910.log hicInfo_0910.txt "."
