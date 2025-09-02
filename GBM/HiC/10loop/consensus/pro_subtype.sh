#!/bin/bash

# pro_GBMsample.sh 获得每个sample合并不同软件的loop
# 输入：consensus/result/all, meta 09insulation/meta_GBM.txt
# 输出：merge/SM,merge/subtype

# 先合并所有的GBM，再按照meta信息合并各亚型


# 01 合并所有的样本，筛选出现在两个样本的loop
cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/all
files=()
while IFS= read -r line; do
    # awk -v name=${line} 'BEGIN{OFS="\t"}NR>1{print $1"_"$2"_"$3,name}' \
    #     /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${line}/${line}_over2.bed | sort | uniq \
    #     > /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${line}/${line}_mergestr.bed
    file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${line}/${line}_mergestr.bed
    files+=("$file")
#done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt"
done < "/cluster/home/futing/Project/GBM/HiC/09insulation/GBM_fil.txt"
# 合并samples
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh GBMfil.bed ${files[@]}
# 合并anchor有很多anchor相近的loop
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh GBMfil.bed

awk 'BEGIN{OFS="\t"} $NF >2 {print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$NF}' GBMfil_merged.bed > GBMfil_1k.bedpe
pairToBed -a GBMfil_1k.bedpe \
    -b /cluster/home/futing/Project/GBM/HiC/13mutation/mutation/gbm_cptac_2021_hg38.bed > SM_loop_1k.bedpe



# 01 merge subtype loop
# 合并每个subtype的不同样本
cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/subtype
clfiles=()
mesfiles=()
prfiles=()
nefiles=()

while IFS=$'\t' read -r sample subtype dataset;do
    echo "Processing $sample..."
    if [ $subtype == "Classical" ]; then

        file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${sample}/${sample}_mergestr.bed
        clfiles+=("$file")
    elif [ $subtype == "Mesenchymal" ]; then

        file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${sample}/${sample}_mergestr.bed
        mesfiles+=("$file")
    elif [ $subtype == "Neural" ]; then

        file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${sample}/${sample}_mergestr.bed
        nefiles+=("$file")
    elif [ $subtype == "Proneural" ]; then

        file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${sample}/${sample}_mergestr.bed
        prfiles+=("$file")
    else
        echo "${sample} subtype is ${subtype}"
    fi
done < <(sed '1d' "/cluster/home/futing/Project/GBM/HiC/09insulation/meta_GBM.txt")



cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/subtype
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh Classical.bed ${clfiles[@]}
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh Mesenchymal.bed ${mesfiles[@]}
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh Neural.bed ${nefiles[@]}
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh Proneural.bed ${prfiles[@]}

# 02 筛选每个subtype loop数目大于2的loop并且合并到subtye.bed
for name in Classical Mesenchymal Neural Proneural;do
    echo "Merging anchor for $name..."
    sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh ${name}.bed
    awk -v subtype=$name 'BEGIN{OFS="\t"}NR>1 && $NF >2 {print $1"_"$2"_"$3,subtype}' \
        ${name}_merged.bed | sort | uniq > ${name}_str.bed
done
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/01mergev2.sh \
    subtype.bed Classical_str.bed Mesenchymal_str.bed Neural_str.bed Proneural_str.bed

# 03 annotation
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh subtype.bed
awk 'BEGIN{OFS="\t"}NR>1{print $1,$2-15000,$2+15000,$1,$3-15000,$3+15000,$4,$5,$6,$7,$8}' subtype.bed > subtype_flank2.bedpe  # 加10kb的flank
awk 'BEGIN{OFS="\t"}NR>1{print $1,$2-35000,$2+35000,$1,$3-35000,$3+35000,$4,$5,$6,$7,$8}' subtype.bed > subtype_flank1.bedpe  # 加30kb的flank
pairToBed -type xor -a subtype_flank2.bedpe -b /cluster/home/futing/ref_genome/hg38_gencode/GRCh38.promoter_nodot2.bed > subtype_promoter2.bed

# 加个表头 最终结果
echo -e "chr\tstart\tend\tchr\tstart\tend\tclassical\tmesenchymal\tproneural\tneural\tnum\tchr\tstart\tend\tENTREZ\tsymbol\ttype" > subtype_promoter2.bedpe
awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' subtype_promoter2.bed >> subtype_promoter2.bedpe


# 找到meschymal独有的loop
awk 'BEGIN{FS=OFS="\t"}$11=="1"&&$7=="1"{print $0}' subtype_promoter.bedpe > classical_promoter.bedpe
awk 'BEGIN{FS=OFS="\t"}$11=="1"&&$8=="1"{print $0}' subtype_promoter.bedpe > mesenchymal_promoter.bedpe
awk 'BEGIN{FS=OFS="\t"}$11=="1"&&$9=="1"{print $0}' subtype_promoter.bedpe > proneural_promoter.bedpe
awk 'BEGIN{FS=OFS="\t"}$11=="1"&&$10=="1"{print $0}' subtype_promoter.bedpe > neural_promoter.bedpe


