#!/bin/bash

cd /cluster/home/futing/Project/GBM/HiC/13mutation/ICGC
outputdir=/cluster/home/futing/Project/GBM/HiC/13mutation/ICGC
genebed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.bed
genecutbed=/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.cut.bed
loopbed=${outputdir}/SM_loop_1k.bedpe
out=${outputdir}/SM_loop_1k_tss.bedpe 


awk '{OFS="\t"}NR>1{print "chr"$9,$10-1,$11,NR}' \
    /cluster/home/futing/Project/GBM/HiC/13mutation/ICGC/simple_somatic_mutation.open.GBM-US.tsv | sort -k1,1d -k2,2n > ncbi_mutation.bed

liftOver ncbi_mutation.bed /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain \
    ncbi_mutation_hg38.bed ncbi_mutation_hg19_unmapped.bed
# -------------------------------------
# 01 先用 SM 和 loop 的结果取交集

awk 'BEGIN{OFS="\t"}NR>1 && $NF >2 {print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$NF}' \
    /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/GBM/GBM_over2.bed > GBMfil_1k.bedpe

pairToBed -a GBMfil_1k.bedpe \
    -b ncbi_mutation_hg38.bed > SM_loop_1k.bedpe

# -------------------------------------
# 02 用 gene 的 tss 位置和 loop 的结果取交集

# cut -f1-8 $genebed > $genecutbed
# 合并有基因的loop和没有基因的loop
pairToBed -a $loopbed -b $genecutbed > intersect.bedpe # 942374
pairToBed -a $loopbed -b $genecutbed -type neither > no_intersect.bedpe # 38795
awk 'BEGIN{OFS="\t"}{print $0"\t\t\t\t\t\t\t\t" }' no_intersect.bedpe > no_intersect.tmp && mv no_intersect.tmp no_intersect.bedpe
cat no_intersect.bedpe intersect.bedpe | sort -k1,1 -k2,2n > $out #981169
rm intersect.bedpe no_intersect.bedpe

# -------------------------------------
# 03 合并 没有loop交集的SM
# 取出没有loop交集的hg19id 
cut -f8-11 SM_loop_1k.bedpe | sort | uniq > hg19id_overlapped.bed #13141 (11635 unique hg38id)
bedtools subtract -a ncbi_mutation_hg38.bed \
    -b hg19id_overlapped.bed > hg19id_nooverlap.bed #41729
# awk 'BEGIN{OFS="\t"}{print "\t\t\t\t\t\t\t" $0}' hg19id_nooverlap.bed > SM_loop_1k_fil.bedpe

# 用基因的tss位置和没有loop交集的hg19id取交集
bedtools intersect -a hg19id_nooverlap.bed -b /cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.bed \
    -wao | cut -f1-12 > hg19id_nooverlap_gene.bed #51214
awk '{print "\t\t\t\t\t\t\t" $0}' hg19id_nooverlap_gene.bed > hg19id_nooverlap_gene.bedpe
# 合并没有loop交集的和有loop交集的hg19id
cat $out hg19id_nooverlap_gene.bedpe > SM_loop_1k_tss_all.bedpe

# 删掉没有loop交集SM的中间文件
rm hg19id_nooverlap.bed hg19id_overlapped.bed hg19id_nooverlap_gene.bedpe hg19id_nooverlap_gene.bed


# 04 计算 loop anchor 的覆盖范围

#!/bin/bash

awk '{print $1"\t"$2"\t"$3; print $4"\t"$5"\t"$6}' SM_loop_1k.bedpe | 
  sort -k1,1 -k2,2n | 
  uniq |
  bedtools merge | 
  awk '{print $1"\t"($3-$2)}' | 
  datamash -g 1 sum 2 count 2 > loop_coverage.txt
  

awk 'BEGIN{OFS="\t"}NR>4{print $0}' /cluster/home/futing/Project/GBM/HiC/13mutation/gbm_tcga_gdc/data_clinical_patient.txt > \
    /cluster/home/futing/Project/GBM/HiC/13mutation/mutation_tcga/data_clinical_patient.bed
