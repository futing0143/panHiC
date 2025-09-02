#!/bin/bash

# 用于判断 SM,gene 和 loop(bedpe)的交集

# -------------------------------------
# 01 先用 SM 和 loop 的结果取交集

awk 'BEGIN{OFS="\t"}NR>1 && $NF >2 {print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$NF}' GBMfil_merged.bed > GBMfil_1k.bedpe
pairToBed -a /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/all/GBMfil_1k.bedpe \
    -b /cluster/home/futing/Project/GBM/HiC/13mutation/mutation/gbm_cptac_2021_hg38.bed > SM_loop_1k.bedpe

# -------------------------------------
# 02 用 gene 的 tss 位置和 loop 的结果取交集
genebed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.bed
genecutbed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.cut.bed
loopbed=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/all/SM_loop_1k.bedpe
# 13282
out=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/all/SM_loop_1k_tss.bedpe

# intersect.bedpe:36856 unique:10874 total:16112
cut -f1-8 $genebed > $genecutbed

# 合并有基因的loop和没有基因的loop
pairToBed -a $loopbed -b $genecutbed > intersect.bedpe
pairToBed -a $loopbed -b $genecutbed -type neither > no_intersect.bedpe #2408
cat no_intersect.bedpe intersect.bedpe | sort -k1,1 -k2,2n > $out
rm intersect.bedpe no_intersect.bedpe

# -------------------------------------
# 03 合并 没有loop交集的SM
# 取出没有loop交集的hg19id 
cut -f8-11 SM_loop_1k.bedpe | sort | uniq > hg19id_overlapped.bed
bedtools subtract -a /cluster/home/futing/Project/GBM/HiC/13mutation/mutation/gbm_cptac_2021_hg38.bed \
    -b hg19id_overlapped.bed > hg19id_nooverlap.bed
awk 'BEGIN{OFS="\t"}{print "\t\t\t\t\t\t\t" $0}' hg19id_nooverlap.bed > SM_loop_1k_fil.bedpe

# 用基因的tss位置和没有loop交集的hg19id取交集
bedtools intersect -a hg19id_nooverlap.bed -b /cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.bed \
    -wao | cut -f1-12 > hg19id_nooverlap_gene.bed
awk '{print "\t\t\t\t\t\t\t" $0}' hg19id_nooverlap_gene.bed > hg19id_nooverlap_gene.bedpe
# 合并没有loop交集的和有loop交集的hg19id
cat $out hg19id_nooverlap_gene.bedpe > SM_loop_1k_tss_gene.bedpe

# 删掉没有loop交集SM的中间文件
rm hg19id_nooverlap.bed hg19id_overlapped.bed hg19id_nooverlap_gene.bedpe


# 04 计算 loop anchor 的覆盖范围

#!/bin/bash

awk '{print $1"\t"$2"\t"$3; print $4"\t"$5"\t"$6}' SM_loop_1k.bedpe | 
  sort -k1,1 -k2,2n | 
  bedtools merge | 
  awk '{print $1"\t"($3-$2)}' | 
  datamash -g 1 sum 2 count 2 > loop_coverage.txt
  
