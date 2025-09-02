#!/bin/bash
data=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901
dir=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38
tmp=/cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901_hg38/tmp
mkdir -p $tmp
cd ${dir}
mkdir -p ${dir}/aligned ${dir}/liftOver

# 01分割文件 准备liftOver
awk '{print $0, NR}' "$data/liftOver/merged_nodups_hg19.txt" > "$dir/liftOver/merged_nodups_hg19NR.bed"     
awk '{print $2"\t"($3-1)"\t"$3"\t"NR}' "$dir/liftOver/merged_nodups_hg19NR.bed" > "$dir/liftOver/HG19_read1.bed"
awk '{print $6"\t"($7-1)"\t"$7}' "$dir/liftOver/merged_nodups_hg19NR.bed" > "$dir/liftOver/HG19_read2.bed"

# 02liftOver
liftOver $dir/HG19_read1.bed /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain "$dir/liftOver/HG38_read1.bed" "$dir/liftOver/HG38_read1_unmap.bed"
liftOver $dir/HG19_read2.bed /cluster/home/futing/ref_genome/liftover/hg19ToHg38.over.chain "$dir/liftOver/HG38_read2.bed" "$dir/liftOver/HG38_read2_unmap.bed"

# 03合并 read1 read2 再合并merged_nohups_hg19
sort -t $'\t' -k4,4 $dir/liftOver/HG38_read1.bed > $dir/liftOver/HG38_read1_sorted.bed
sort -t $'\t' -k4,4 $dir/liftOver/HG38_read2.bed > $dir/liftOver/HG38_read2_sorted.bed
# 合并 read1 read2
join -t $'\t' -1 4 -2 4 -o 1.1,1.3,2.1,2.3,1.4 $dir/liftOver/HG38_read1_sorted.bed $dir/liftOver/HG38_read2_sorted.bed > $dir/liftOver/read1_read2_hg38.bed
# 合并 read1_read2 merged_nohups_hg19
sed -i 's/\t/ /g' $dir/liftOver/read1_read2_hg38.bed

sort -k17,17 $dir/liftOver/merged_nodups_hg19NR.bed > $dir/liftOver/merged_nodups_hg19_sorted.bed
join -1 5 -2 17 -o 2.1,1.1,1.2,2.4,2.5,1.3,1.4,2.8,2.9,2.10,2.11,2.12,2.13,2.14,2.15,2.16 \
    $dir/liftOver/read1_read2_hg38.bed \
    $dir/liftOver/merged_nodups_hg19_sorted.bed > $dir/liftOver/merged_nodups_hg38.bed
# join 后检查 1_10 10_1的问题
awk '{if ($2 <= $6) print $0; else print $1,$6,$7,$8,$5,$2,$3,$4,$12,$13,$14,$9,$10,$11,$16,$15}' ./liftOver/merged_nodups_hg38.bed > ./liftOver/merged_nodups_correct.txt
sort -k2,2d -k6,6d ./liftOver/merged_nodups_correct.txt > aligned/merged_nodups.txt


# 04准备 juicer
cp /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/aligned/header ./aligned/
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/fastq .
ln -s /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA_hg19/P455.SF11901/splits .

source activate juicer
/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
	-S final \
	-g hg38 \
	-d $dir \
	-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
	-y /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt \
	-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa \
	-D /cluster/home/futing/software/juicer_CPU/ 