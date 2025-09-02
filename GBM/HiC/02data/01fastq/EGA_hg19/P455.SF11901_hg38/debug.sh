#!/bin/bash
dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38
# 问题一： join
# 用前998行测试一下read1 read2 合并
# 发现必须按照字典顺序排序
mkdir -p test
head -n 998 $dir/liftOver/HG38_read1.bed | sort -t $'\t' -k4,4n | cut -f4 > $dir/test/HG38_read1_sorted.bed
head -n 998 $dir/liftOver/HG38_read2.bed | sort -t $'\t' -k4,4n | cut -f4 > $dir/test/HG38_read2_sorted.bed
# 合并 read1 read2
join -t $'\t' $dir/test/HG38_read1_sorted.bed $dir/test/HG38_read2_sorted.bed > $dir/test/read1_read2_hg38.bed
join -t $'\t' -1 3 -2 3 -o 1.1,1.2,2.1,2.2,1.3 $dir/test/HG38_read1_sorted.bed $dir/test/HG38_read2_sorted.bed > $dir/test/read1_read2_hg38.bed

#看一下共有的序列
cat <(head -n 2000 $dir/liftOver/HG38_read1.bed | cut -f 4) <(head -n 2000 $dir/liftOver/HG38_read2.bed | cut -f 4) | sort | uniq -d | wc -l

# 问题 2: 我的文件和jialu的文件有什么不同
# 看一下两个文件的差别
tmp=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38/test
mybed=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38/aligned/merged_nodups.txt
jialu=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_test/aligned/merged_nodups.txt
sort -T $tmp -k2,2d -k6,6d -k4,4n -k8,8n -k1,1n -k5,5n -k3,3n $mybed > ./my.txt
sort -T $tmp -k2,2d -k6,6d -k4,4n -k8,8n -k1,1n -k5,5n -k3,3n $jialu > ./jialu.txt

/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/dups.txt
/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/merged_sort.txt
/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/opt_dups.txt
/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/tmp.txt

# 查看1号染色体和10号染色体的交叉
awk '{if ($2 == "chr1" && $6 == "chr10") {print NR,$0; exit}}' /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38/aligned/merged_nodups.txt
awk '{if ($2 == "chr10" && $6 == "chr1") {print NR,$0; exit}}' /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38/aligned/merged_nodups.txt

awk '{if ($2 <= $6) print $0; else print $1,$6,$7,$8,$9,$2,$3,$4,$5,$11,$10}' aligned/merged_nodups.txt > aligned/merged_nodups_correct.txt
sort -k2,2d -k6,6d aligned/merged_nodups_correct.txt > correct_dijhic006_merge_hg38.input.sorted.txt