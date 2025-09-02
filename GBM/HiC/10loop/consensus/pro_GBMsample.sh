#!/bin/bash

# 用于合并每个sample的不同软件的loop
# 给 namelist 合并namelist的样本
# 最后统计 namelist.txt 的sloop nloop

top_dir=/cluster/home/futing/Project/GBM/HiC/10loop
flank=5000
name_list=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/sup


# 01 先整合不同软件的loop到一个文件里，分样本存放
while read -r name; do
    date
    echo -e "Processing $name...\n"
    if [ -d ${top_dir}/consensus/mid/${name} ]; then
        echo "Directory ${top_dir}/consensus/mid/${name} exists."
    else
        mkdir -p ${top_dir}/consensus/mid/${name}
    fi

    cd ${top_dir}/consensus/mid/${name}

    #01 preprocess
    peakachu=${top_dir}/peakachu/10000/results/${name}-peakachu-10kb-loops.0.95.bedpe
    mustache=${top_dir}/mustache/10000/${name}_10kb_mustache.bedpe
    cooldots=${top_dir}/cooltools/results/${name}/dots.10000.tsv
    #cooldots_no=${top_dir}/cooltools_noview/${name}/dots.10000.tsv
    hiccups=${top_dir}/hiccups/results/${name}/postprocessed_pixels_10000.bedpe
    fithic=${top_dir}/fithic/outputs/10000/${name}.intraOnly/${name}.merge.bed.gz
    homer=${top_dir}/homer/results/${name}/10000/${name}.loop.2D.bed

    awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"peakachu"}' $peakachu | sort | uniq > ${name}_peakachu_str.bed
    awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"mustache"}' $mustache | sort | uniq > ${name}_mustache_str.bed
    awk 'BEGIN{OFS="\t"} NR > 1 {print $1"_"$2+5000"_"$5+5000,"cooldots"}' $cooldots | sort | uniq > ${name}_cooldots_str.bed
    # awk 'BEGIN{OFS="\t"} NR > 1 {print $1"_"$2+5000"_"$5+5000,"cooldots_no"}' $cooldots_no | sort | uniq > ${name}_cooldots_no_str.bed
    awk 'BEGIN{OFS="\t"} NR > 2 { if ($1 !~ /^chr/) { print "chr"$1"_"$2+5000"_"$5+5000,"hiccups"} else { print $1"_"$2+5000"_"$5+5000,"hiccups"} }' $hiccups | sort | uniq > ${name}_hiccups_str.bed
    zcat $fithic | awk 'BEGIN{OFS="\t"} NR >1 {print $1"_"int($2)"_"int($4),"fithic"}' | sort | uniq > ${name}_fithic_str.bed
    sort -k1,1d -k2,2n -k4,4d -k5,5n $homer | awk 'BEGIN{OFS="\t"} {print $1"_"$2+5000"_"$5+5000,"homer"}' > ${name}_homer_str.bed

    #02 merge
    sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/prepro/01mergev2.sh ${name}.bed \
        ${name}_peakachu_str.bed ${name}_mustache_str.bed ${name}_cooldots_str.bed \
        ${name}_hiccups_str.bed ${name}_fithic_str.bed ${name}_homer_str.bed #A172_2 文件名格式有问题 手动修改

done < "${name_list}"

# 03 合并不同软件间anchor接近的loop 添加新的一列为多少个软件的共同loop
while read -r name;do
    echo "Merging anchor for $name..."
    cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}
    sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/02merge_loops.sh ${name}.bed
done < "${name_list}"

# 04 挑选那些共同loop数大于等于2的loop
while read -r name;do
    echo "Filter loops occur twice for $name..."
    cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}
    awk 'NR ==1{print $0}
    NR>1 && $NF >= 2{print $0}' ${name}_merged.bed > ${name}_over2.bed
done < "${name_list}"



# --------------------------- !!! qc !!! ------------------------
# 05 qc 计算loop数、交集数、交集比例、unique loop数、looppersoft、over2loops数、loop大小
# 第一个文件一定要是软件数最大的文件，因为会读取第一个文件的列名作为表头
files=()
while IFS= read -r line; do
    file=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${line}/${line}_merged.bed
    files+=("$file")
done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt"

names=()
while IFS= read -r line; do
    names+=("$line")
done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt"



qc_result=/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_1118
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03interall.sh \
    ${qc_result}/nloop_all.txt "${files[@]}" 
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03inter2.sh \
    ${qc_result}/inter2.txt "${files[@]}" 
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03interp.sh \
    ${qc_result}/inter2p.txt "${files[@]}"
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/scripts/03nloopv2.sh \
    ${qc_result} "${names[@]}"

# 06 整合所有样本的loop，寻找多样本出现的loop，和上面的整合多软件的loop一样的步骤



# 07 注释loop 挑选多样本出现的loop，并且有RNA和ChIP信号



# #04 annotate with H3K27ac and RNA-seq
# while IFS=$' ' read -r name h3k27ac_bed h3k27ac_bw rna_bed; do
#     awk 'BEGIN{OFS="\t"} {print $1,$2-5000-$flank,$2+5000+$flank,$1,$3-5000-$flank,$3+5000+$flank,$4,$5,$6,$7,$8,$9}' ${name}.bed > ${name}_flank.bed
#     pairToBed -type xor -a ${name}_flank.bed -b $h3k27ac_bed > ${name}_h3k27ac.bed
# done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/consensus_list.txt"

