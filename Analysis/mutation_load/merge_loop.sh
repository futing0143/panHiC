#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/Analysis/mutation_load


metadata=/cluster2/home/futing/Project/panCancer/check/meta/PanmergedMeta_0106.txt
wkdir=/cluster2/home/futing/Project/panCancer/

tagged_list=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCACancer_mustache_list.txt
> $tagged_list
IFS=$'\t'
while read -r cancer gse cell clcell;do
    file="${wkdir}/${cancer}/${gse}/${cell}/anno/mustache/${cell}_10kb_mustache.bedpe"


    if [ ! -s $file ];then
        echo "$file not found, skip"
    else
        echo "Processing $file ..."
        # awk -v s=${clcell} 'BEGIN{OFS="\t"}{print $0,s}' ${file} \
        # > ${file%.bedpe}.tagged.bedpe
		linecount=$(wc -l < ${file})
		if [[ $linecount -gt 1000 ]]; then
        echo "${file%.bedpe}.tagged.bedpe" >> ${tagged_list}
		fi
    fi

done < <(grep "BRCA" $metadata | awk 'BEGIN{OFS="\t"}NR>1{if ($5 == 0){print $1,$2,$3,$4}}')

xargs -a $tagged_list cat > BRCACan.mustache.bedpe
sort -k1,1 -k2,2n -k3,3n \
     -k4,4 -k5,5n -k6,6n \
  BRCACan.mustache.bedpe > BRCACan.mustache.sorted.bedpe

python /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/loop_dbsacna_sonsensus.py \
-i BRCACan.mustache.sorted.bedpe \
   -d 10000 \
   -o BRCA_Cancer

