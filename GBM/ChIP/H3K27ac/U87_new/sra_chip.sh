#!bin/bash


cd /cluster/home/futing/Project/GBM/ChIP/H3K27ac/U87_new
prefetch -p -X 60GB --option-file srr.txt
for name in $(cat srr.txt);do
    source activate /cluster/home/futing/anaconda3/envs/download
    echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
    parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
done
cp /cluster/home/futing/Project/GBM/ChIP/H3K4me3/U87_H3K4me3/SRR14862252.fastq.gz .
/cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh "" 30 SRR14862252 rose ""

source activate HiC
name=U87_new
rep1=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/${name}/macs2/SRR14862242_peaks.narrowPeak
rep2=/cluster/home/futing/Project/GBM/ChIP/H3K27ac/${name}/macs2/SRR14862243_peaks.narrowPeak
sort -k8,8nr ${rep1} > ./macs2/rep1_sorted.narrowPeak
sort -k8,8nr ${rep2} > ./macs2/rep2_sorted.narrowPeak


idr --samples ./macs2/rep1_sorted.narrowPeak ./macs2/rep2_sorted.narrowPeak \
        --input-file-type narrowPeak \
        --peak-merge-method avg \
        --output-file ./macs2/${name}-idr.bed \
        --plot \
        --log-output-file ./macs2/rep1_rep2_idr.log

awk -F '\t' 'BEGIN {FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ./macs2/${name}-idr.bed > ./macs2/${name}_idr_merge.bed 
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $7}' ./macs2/${name}_idr_merge.bed > ./macs2/output.bedGraph
# bedgragh 2 bigwigno
LC_ALL=C sort -k1,1 -k2,2n ./macs2/output.bedGraph > ./macs2/sorted_output.bedGraph
bedGraphToBigWig ./macs2/sorted_output.bedGraph /cluster/home/futing/ref_genome/hg38.chrom.sizes ./macs2/U87_H3K27ac.bw

