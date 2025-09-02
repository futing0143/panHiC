#!/bin/bash

hic_dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate homer
name=NPC
text=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC/mega/aligned/merged_nodups_medium.txt


cd /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC/mega/aligned
# 01 hic 2 homer
echo -e "Processing ${name} at $(pwd)...\n"
#gunzip /cluster/home/futing/Project/GBM/HiC/02data/01fastq/NPC/mega/aligned/merged_nodups_medium.txt.gz

cd /cluster/home/futing/Project/GBM/HiC/10loop/homer/NPC
start=$(date +%s) 
step1_start=$(date +%s)
# 01 convert hic 2 homer
awk -F " " 'BEGIN { OFS = "\t" }{if($2 == "0"){$2= "+"} else { $2 ="-" };
    if($6 == "0"){$6 = "+"} else { $6 ="-" };
    print 0, $3, $4, $2, $7, $8, $6}' $text > ./${name}.homer
step1_end=$(date +%s)
echo "convert hic 2 homer cost: $((step1_end - step1_start)) seconds"

# 02 filter
step2_start=$(date +%s)
awk -F '\t' 'BEGIN {
    # 读取 hg38.chrom.sizes 文件中的染色体名字到数组中
    while ((getline < "/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome") > 0) {
        chrom[$1]
    }
}
{
    # 检查第二列和第六列是否在 chrom 数组中
    if (($2 in chrom) && ($5 in chrom)) {
        print $0
    }
}' ./${name}.homer > ./${name}_fil.homer
step2_end=$(date +%s)
echo "filter chr $((step2_end - step2_start)) seconds"

# 02 make tag directory
echo -e "\nmakeTagDirectory TagDir/ -format HiCsummary ${name}_fil.homer -tbp 1\n"
makeTagDirectory TagDir -format HiCsummary ./${name}_fil.homer -tbp 1

# 03 find TADs and loops
for res in 5000 10000;do
    win=$((res * 3))
    echo -e "\nfindTADsAndLoops.pl find TagDir/ -cpu 10 -res ${res} -window ${win} -genome hg38 -p /cluster/home/futing/software/homer/data/badRegions.bed\n"
    findTADsAndLoops.pl find TagDir/ -cpu 10 -res ${res} \
        -window ${win} -genome hg38 \
        -p /cluster/home/futing/software/homer/data/badRegions.bed

    mkdir ${res}
    find TagDir/ -name "TagDir*" -type f -exec mv {} ./${res}/ \;
    rename TagDir ${name} ${res}/*
    ls -l ${res}
done