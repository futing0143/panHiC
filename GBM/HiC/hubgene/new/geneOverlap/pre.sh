#!/bin/bash

# 输入为 NHA_merged.bedpe iPSC_merged.bedpe NPC_merged.bedpe GBM_merge.bedpe
# 输出 ${name}_G.bedpe
# 用于 loop 和 genebed 取交集


##01 loop与基因取交集
for i in NHA_merged.bedpe iPSC_merged.bedpe NPC_merged.bedpe; do
  # 获取文件名（不带扩展名）
  filename=$(basename "$i" .bedpe)

  # 执行 pairToBed 并格式化输出
  pairToBed -a "$i" -b /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.tss.bed | \
  awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$11"\t"$12"\t"$13"\t"$17}' > "${filename}_G.bedpe"
  
  # 输出处理完成的文件
  echo "Processed: ${i} -> ${filename}_G.bedpe"
done

pairToBed -a /cluster/home/tmp/GBM/HiC/hubgene/new/GBM_over2.bedpe \
    -b /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.tss.bed \
    | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$14"\t"$15"\t"$16"\t"$20}' > /cluster/home/tmp/GBM/HiC/hubgene/new/GBM_over2_G.bedpe

# newer version
# by Futing at 25Feb21

loopdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/flank0k

for i in NHA iPSC NPC GBM;do 
	awk '{OFS="\t"}NR>1{print $1,$2,$3,$4,$5,$6,$NF}' ${loopdir}/${i}_flank0k.bedpe > tmp
	pairToBed -a tmp -b /cluster/share/ref_genome/hg38/annotation/gencode.v38.gene.tss.bed \
		| awk '{OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$14}'> ${i}_Gover.bedpe
	rm tmp; 
done
