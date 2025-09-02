#!/bin/bash

# 处理 loop 与基因的 intersect
# 输出：GBM NPC iPSC NHA _flank0k.bedpe，loop_anno.bedpe
# 用于后续 classify loop（已弃用）

cd /cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/cytoscape
out=/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/cytoscape/loop_anno.bedpe


awk 'BEGIN{OFS="\t"}NR>1 && $NF >2 {print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/GBM/GBM_over2.bed > GBMfil_1k.bedpe
loopbed=GBMfil_1k.bedpe

awk 'BEGIN{OFS="\t"}NR>1 && $NF >2 {print $1,$2-5000,$2+5000,$1,$3-5000,$3+5000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/GBM/GBM_over2.bed > GBM_flank0k.bedpe
awk 'BEGIN{OFS="\t"}NR>1 {print $1,$2-5000,$2+5000,$1,$3-5000,$3+5000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/ctrl/iPSC_merged.bed > iPSC_flank0k.bedpe
awk 'BEGIN{OFS="\t"}NR>1 {print $1,$2-5000,$2+5000,$1,$3-5000,$3+5000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/ctrl/NPC_merged.bed > NPC_flank0k.bedpe
awk 'BEGIN{OFS="\t"}NR>1 {print $1,$2-5000,$2+5000,$1,$3-5000,$3+5000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/ctrl/astro_merged.bed > astro_flank0k.bedpe

# 01 loop与基因
loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k
genecutbed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.cut.bed

pairToBed -a $loopbed -b $genecutbed > intersect.bedpe # 33466 
pairToBed -a $loopbed -b $genecutbed -type neither > no_intersect.bedpe # 4866 
awk 'BEGIN{OFS="\t"}{print $0"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" }' no_intersect.bedpe \
    > no_intersect.tmp && mv no_intersect.tmp no_intersect.bedpe
cat no_intersect.bedpe intersect.bedpe | sort -k1,1 -k2,2n > $out # 38332
cut -f1-11,14-15 $out > $out.tmp && mv $out.tmp $out
rm intersect.bedpe no_intersect.bedpe


# 02 loop 和 Enhancer
enbed=/cluster/home/futing/Project/GBM/HiC/hubgene/new/chip/midata/GBM.merge_BS_detail.bed

pairToBed -a $out -b $enbed > intersect.bedpe # 
pairToBed -a $out -b $enbed -type neither > no_intersect.bedpe #
awk 'BEGIN{OFS="\t"}{print $0"\tNA\tNA\tNA\tNA\tNA" }' no_intersect.bedpe \
    > no_intersect.tmp && mv no_intersect.tmp no_intersect.bedpe
cat no_intersect.bedpe intersect.bedpe | sort -k1,1 -k2,2n > loop_anno.tmp && mv loop_anno.tmp $out
rm intersect.bedpe no_intersect.bedpe




