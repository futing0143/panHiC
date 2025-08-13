#!/bin/bash


cd /cluster/home/futing/Project/GBM/ChIP/H3K4me3/NHA_new

# 01 download file
# source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
# conda activate RNA

# prefetch -p -X 60GB --option-file srr.txt > download.log
# # sh /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt . 10M
# for name in $(cat srr.txt);do

#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done

# 02 mapping SRR22197612
source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose

i=SRR22197612
thread=30
indexpath="/cluster/share/ref_genome/hg38/index/bowtie2/hg38"
chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"

mkdir -p ./{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow,all_transfer_result}
mkdir -p ./all_transfer_result/{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow}


##QC before filtration
fastqc -o ./fastqc ./${i}*.fastq.gz
	
##fastp filtrate
fastp -i ${i}.R1.fastq.gz -I ${i}.R2.fastq.gz -o ${i}_fil.R1.fastq.gz -O ${i}_fil.R2.fastq.gz -j ./fastp_report/${i}_fastp.json \
-h ./fastp_report/${i}_fastp.html -t 2 -T 2 -q 20 -u 40 -3 -W 4 -M 20 -w 8

## strict cutoff
#fastp -i ${i}.R1.fastq.gz -I ${i}.R2.fastq.gz -o ${i}_fil.R1.fastq.gz -O ${i}_fil.R2.fastq.gz -j ./fastp_report/${i}_fastp.json \
#-h ./fastp_report/${i}_fastp.html -t 2 -T 2 -q 25 -u 20 -3 -W 4 -M 25 -w 8

##QC after filtration
fastqc -o ./fastqc_filt ./${i}_fil*
	
##bowtie2 mapping
bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p $thread -x ${indexpath} \
-1 ${i}_fil.R1.fastq.gz -2 ${i}_fil.R2.fastq.gz -S ./alignment/${i}_bowtie2.sam &> ./alignment/${i}_bowtie2.txt

samtools view -h -F 4 ./alignment/${i}_bowtie2.sam > ./alignment/${i}_bowtie2.mapped.sam

##filter other chromosomes
head -n 300 ./alignment/${i}_bowtie2.mapped.sam | grep ^@SQ | tr ":" "\t" | cut -f3 | grep -v -w -f ${main_chr_list_path} > ./alignment/${i}_delchr.txt
grep -v -f ./alignment/${i}_delchr.txt ./alignment/${i}_bowtie2.mapped.sam > ./alignment/${i}_bowtie2_fil.sam

##assess mapped fragment size distribution
samtools view ./alignment/${i}_bowtie2_fil.sam | awk -F '\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | \
sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > ./fragmentLen/${i}_fragmentLen.txt

##sam to bam
samtools view -bS ./alignment/${i}_bowtie2_fil.sam > ./bam_files/${i}_bowtie2.bam

##sort bam
samtools sort -o ./bam_files/${i}.sorted.bam ./bam_files/${i}_bowtie2.bam

##make index for sorted bam
samtools index ./bam_files/${i}.sorted.bam

##remove PCR duplicate
picard MarkDuplicates -I ./bam_files/${i}.sorted.bam -O ./bam_files/${i}.rmdup_sorted.bam --REMOVE_DUPLICATES true \
--METRICS_FILE ./bam_files/${i}.rmdup.txt --VALIDATION_STRINGENCY LENIENT --QUIET true

##remake index for rmdup bam files
samtools index ./bam_files/${i}.rmdup_sorted.bam

##bigwig
bamCoverage -b ./bam_files/${i}.rmdup_sorted.bam -o ./bigwig/${i}.rpkm.bw --normalizeUsing RPKM
	
	
sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_last_v1.2.sh "" 30 SRR22197596 rose "" srr.txt

