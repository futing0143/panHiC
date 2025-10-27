#!/bin/bash

resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000)
cd /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts
scripts=/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo.py
source activate /cluster2/home/futing/miniforge3/envs/juicer

# find /cluster2/home/futing/Project/panCancer -name '*_50000.cool' | while read file;do

while IFS=$'\t' read -r cancer gse cell ncell;do
	file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/cool/${cell}_50000.cool"
	cell=$(cut -f9 -d '/' <<< "$file")
	gse=$(cut -f8 -d '/' <<< "$file")
	cancer=$(cut -f7 -d '/' <<< "$file")
	echo -e "Processing $cell $gse and $cancer.."
	hicInfo -m $file >> hicInfo_1016.log

done < "/cluster2/home/futing/Project/panCancer/check/aligned/aligndone1016.txt"

python $scripts hicInfo_1016.log hicInfo_1016.txt "."

echo -e "cancer\tgse\tcell\tncell" > hicInfo_1016.txt.tmp
awk -F',' 'BEGIN{FS=OFS="\t"}NR>1{
    count[$3]++
    if (count[$3]==1) {
        uniq=$3
    } else {
        uniq=$3"_"count[$3]
    }
    print $0,uniq
}' hicInfo_1016.txt >> hicInfo_1016.txt.tmp && mv hicInfo_1016.txt.tmp hicInfo_1016.txt
