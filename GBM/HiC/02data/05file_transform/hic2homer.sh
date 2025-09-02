#!/bin/bash

text=$1
name=$2
start=$(date +%s) 
step1_start=$(date +%s)
# 01 convert hic 2 homer
awk -F " " 'BEGIN { OFS = "\t" }{if($1 == "0"){$1= "+"} else { $1 ="-" };
    if($5 == "0"){$5 = "+"} else { $5 ="-" };
    print 0, $2, $3, $1, $6, $7, $5}' $text > ./${name}.homer
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