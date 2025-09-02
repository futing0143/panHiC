cat namelist_667 | while read i
do
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools pre \
-f /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/restriction_sites/hg38_HindIII.txt \
-s merge_all/${i}/aligned/inter_30.txt -g merge_all/${i}/aligned/inter_hists.m \
-q 1 merge_all/${i}/aligned/merged_nodups.txt \
merge_all/${i}/aligned/inter_30.hic hg38 \
-p /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.chrom.sizes 
done
