#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCA/Cancer
loopbedpe=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCA/Cancer/BRCACancer.consensus_loops.bedpe

snp=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/PCAWG/BRCA_noncodeSNP.tsv
snpbed=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/PCAWG/BRCA_noncodeSNP.bed
gene_tss=/cluster2/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.tss.bed
gene_tss_updown2k=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/anno/gencode.v43.gene.tss.up2k.bed
ENSG_tss_updown2k=/cluster2/home/futing/Project/panCancer/Analysis/mutation_load/anno/gencode.v43.ENSG.tss.up2k.bed
# --- 处理 SNP & gene TSS
awk 'BEGIN{OFS="\t"}{
  if($6=="+"){
    start = ($2-2000 > 0) ? $2-2000 : 0
    end = $2+2000
    print $1, start, end, $7
  } else {
    start = ($3-2000 > 0) ? $3-2000 : 0
    end = $3+2000
    print $1, start, end, $7
  }
}' "${gene_tss}" > "${gene_tss_updown2k}"

awk 'BEGIN{OFS="\t"}{
  # 先处理第四列，去掉点号及其后面的内容
  sub(/\..*/, "", $4)
  
  if($6=="+"){
    start = ($2-2000 > 0) ? $2-2000 : 0
    end = $2+2000
    print $1, start, end, $4,$7
  } else {
    start = ($3-2000 > 0) ? $3-2000 : 0
    end = $3+2000
    print $1, start, end, $4,$7
  }
}' "${gene_tss}" | sort -k1,1d -k2,2n -k3,3n -u > "${ENSG_tss_updown2k}"

tail -n +2 ${snp} > ${snpbed}

# SNP 在 A 端，gene 在 B 端
bedtools pairtobed \
  -a <(cut -f2-8 ${loopbedpe}) \
  -b ${snpbed} \
  -type both \
  -f 1e-9 \
| bedtools pairtobed \
  -a stdin \
  -b ${ENSG_tss_updown2k} \
  -type both \
  -f 1e-9 \
> /cluster2/home/futing/Project/panCancer/Analysis/mutation_load/BRCA/Cancer/BRCACancer_loop_SNP_ENSG.bedpe

awk 'BEGIN{OFS="\t"}{
  # overlap conditions
  snp_in_A = ($8==$1 && $9<$3 && $10>$2)
  snp_in_B = ($8==$4 && $9<$6 && $10>$5)

  gene_in_A = ($17==$1 && $18<$3 && $19>$2)
  gene_in_B = ($17==$4 && $18<$6 && $19>$5)

  if ( (snp_in_A && gene_in_B) || (snp_in_B && gene_in_A) )
    print
}' BRCACancer_loop_SNP_ENSG.bedpe > BRCACancer_loop_SNP_ENSG.AB.bedpe

# ======== 提取出 SNP 和 gene 信息 ========
'''
1  chr1
2  2210000
3  2220000
4  chr1
5  2310000
6  2320000
7  1                    ← loop_id / cluster_id
8  chr1
9  2211188
10 2211188
11 chr1_2211188_2211188 ← SNP ID
12 DO220828             ← sample / donor
13 C1orf86              ← SNP 注释基因（线性注释）
14 Intron               ← SNP 功能
15 T
16 G
17 chr1
18 2210720
19 2214720
20 FAAP20               ← loop 另一端 TSS gene
'''

awk 'BEGIN{OFS="\t"}{
  print \
    $11,        # snp_id
    $8,         # snp_chr
    $9,         # snp_pos
    $20,        # gene_3D (loop target),ENSG
	$21,        # gene_3D (loop target),SYMBOL
    $13,        # gene_linear
    $7,         # loop_id
    $12,        # sample
    $14         # snp_function
}' BRCACancer_loop_SNP_ENSG.AB.bedpe \
> BRCACancer_SNP_ENSG_3D.tsv

# 3D gene 和 线性基因 对比
awk '$4 != $5' SNP_gene_3D.tsv | wc -l #16432

awk '$6>=5 && $4!=$5' SNP_gene_3D.tsv | wc -l #6097