#!/bin/bash

# 合并datadir里的control样本 
# 新的脚本，之前的坏掉了
# by futing at Feb17

datadir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/


# 01 合并conrtol的不同样本
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/prepro/01mergev2.sh astro.bed \
    ${datadir}/astro1/astro1_mergestr.bed ${datadir}/astro2/astro2_mergestr.bed

sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh NPC.bed \
    ${datadir}/NPC/NPC_mergestr.bed ${datadir}/NPCnew/NPCnew_mergestr.bed

sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh iPSC.bed \
    ${datadir}/ipsc/ipsc_mergestr.bed ${datadir}/iPSCnew/iPSCnew_mergestr.bed

sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh astro.bed
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh iPSC.bed
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh NPC.bed

# flank0k
outdir=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/
for name in astro iPSC NPC; do
    awk 'BEGIN{OFS="\t"} 
        #NR==1 {print "chr1","start1","end1","chr2","start2","end2",$4,$5,$6,$7} 
        NR>1  {print $1,($2-5000>0 ? $2-5000 : 0),$2+5000,$1,($3-5000>0 ? $3-5000 : 0),$3+5000,$NF}' \
        ${outdir}/ctrl/${name}_merged.bed > ${outdir}/flank0k/${name}_flank0k.bedpe
done

# 02-1 合并对照组loop 不筛选了
for name in astro NPC iPSC;do
    awk -v subtype=$name 'BEGIN{OFS="\t"}NR>1{print $1"_"$2"_"$3,subtype}' \
        ${name}.bed | sort | uniq > ${name}_str.bed
done

# 合并control
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh \
    control.bed astro_str.bed NPC_str.bed iPSC_str.bed

# 合并亚型和astro NPC iPSC
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh \
    all.bed astro_str.bed NPC_str.bed iPSC_str.bed \
    ../subtype/Classical_str.bed ../subtype/Mesenchymal_str.bed ../subtype/Neural_str.bed ../subtype/Proneural_str.bed

# annotate with gene
awk 'BEGIN{OFS="\t"}NR>1{print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$4,$5,$6,$7}' control.bed > control_flank.bedpe
awk 'BEGIN{OFS="\t"}NR>1{print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$4,$5,$6,$7,$8,$9,$10,$11}' all.bed > all_flank.bedpe
pairToBed -type xor -a control_flank.bedpe -b /cluster/home/futing/ref_genome/hg38_gencode/GRCh38.promoter_nodot2.bed > control_promoter.bed
pairToBed -type xor -a all_flank.bedpe -b /cluster/home/futing/ref_genome/hg38_gencode/GRCh38.promoter_nodot2.bed > all_promotor.bed


# 加个表头 最终结果
echo -e "chr\tstart\tend\tchr\tstart\tend\tastro\tNPC\tiPSC\tclassical\tmesenchymal\tproneural\tneural\tnum\tchr\tstart\tend\tENTREZ\tsymbol\ttype" > all_promotor.bedpe
awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20}' all_promotor.bed >> all_promotor.bedpe

# 02-2 分开来得到对照组的loop
# 不再筛选，直接合并不同对照组
for name in astro NPC iPSC;do
    awk 'BEGIN{OFS="\t"}NR>1{print $1,$2-35000,$2+35000,$1,$3-35000,$3+35000,$4,$5,$6,$7,$8}' \
        /cluster/home/futing/Project/GBM/HiC/10loop/consensus/merged/subtype/${name}.bed > ${name}_flank.bedpe

    pairToBed -type xor -a ${name}_flank.bedpe \
        -b /cluster/home/futing/ref_genome/hg38_gencode/GRCh38.promoter.bed \
        > ${name}_promoter.bed
    echo -e "chr\tstart\tend\tchr\tstart\tend\tclassical\tmesenchymal\tproneural\tneural\tnum\tchr\tstart\tend\tsymbol\ttype" \
        > ${name}_promoter.bedpe
    awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$16,$17}' \
        ${name}_promoter.bed >> ${name}_promoter.bedpe

done

