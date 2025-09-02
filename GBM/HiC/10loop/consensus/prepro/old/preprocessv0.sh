#!/bin/bash


#------ 这个脚本用的是 用multiinter 合并所有的loop结果 ------

top_dir=/cluster/home/futing/Project/GBM/HiC/10loop
#cat /cluster/home/futing/Project/GBM/HiC/02data/04mcool/name.txt | while read name;do
for name in G351;do
    echo -e "\nProcessing $name...\n"
    mkdir ${name}
    cd ${name}
    #01 preprocess
    peakachu=${top_dir}/peakachu/10k/${name}-peakachu-10kb-loops.0.95.bedpe
    mustache=${top_dir}/mustache/10k/${name}_10k_mustache.bedpe
    cooldots=${top_dir}/cooltools/${name}/dots.10000.tsv
    cooldots_no=${top_dir}/cooltools_noview/${name}/dots.10000.tsv
    hiccups=${top_dir}/hiccups/results/${name}/postprocessed_pixels_10000.bedpe
    fithic=${top_dir}/fithic/outputs/10000/${name}.intraOnly/${name}.merge.bed.gz

    awk 'BEGIN{OFS="\t"} {print $1,$2+5000,$5+5000}' $peakachu | sort -k1,1d -k2,2n > ${name}_peakachu.bed
    awk 'BEGIN{OFS="\t"} {print $1,$2+5000,$5+5000}' $mustache | sort -k1,1d -k2,2n > ${name}_mustache.bed
    awk 'BEGIN{OFS="\t"} NR > 1 {print $1,$2+5000,$5+5000}' $cooldots | sort -k1,1d -k2,2n > ${name}_cooldots.bed
    awk 'BEGIN{OFS="\t"} NR > 1 {print $1,$2+5000,$5+5000}' $cooldots_no | sort -k1,1d -k2,2n > ${name}_cooldots_no.bed

    awk 'BEGIN{OFS="\t"} NR > 2 { if ($1 !~ /^chr/) { print "chr"$1, $2+5000, $5+5000} else { print $1, $2+5000, $5+5000} }' $hiccups | sort -k1,1d -k2,2n > ${name}_hiccups.bed
    zcat $fithic | awk 'BEGIN{OFS="\t"} NR >1 {print $1,int($2),int($4)}' | sort -k1,1d -k2,2n | uniq > ${name}_fithic.bed

    #02 merge
    bedtools multiinter -i ${name}_peakachu.bed ${name}_mustache.bed ${name}_cooldots.bed \
        ${name}_hiccups.bed ${name}_fithic.bed > ${name}.bed
done
