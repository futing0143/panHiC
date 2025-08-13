#!/bin/bash

# by Futing at Feb18

cd /cluster/home/futing/Project/GBM/ChIP/H3K4me3/NHA

# 01 先下载文件
# source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
# source activate RNA
# conda list | grep 'sra-tools'

# for name in SRR14716873 SRR13238390;do

#     echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
#     parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
# done

# ln -s /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NHA/SRR13238390.R1.fastq.gz ./SRR13238390.R1.fastq.gz
# ln -s /cluster/home/futing/Project/GBM/ChIP/H3K27ac/NHA/SRR13238390.R2.fastq.gz ./SRR13238390.R2.fastq.gz



# 02 处理ChIP文件
rename _R1 .R1 *fastq.gz
rename _R2 .R2 *fastq.gz
rename _1 .R1 *fastq.gz
rename _2 .R2 *fastq.gz

source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose

thread=30
indexpath="/cluster/share/ref_genome/hg38/index/bowtie2/hg38"
chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"

mkdir -p ./{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow,all_transfer_result}
mkdir -p ./all_transfer_result/{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig,heatmap,macs2,motif,rose,reads_flow}

for i in SRR13238390 SRR14716873;do
	echo -e "Processing ${i}..."
	

	if [[ "${i}" == "SRR13238390" ]]; then
		
		fastp -i ${i}.R1.fastq.gz -I ${i}.R2.fastq.gz -o ${i}_fil.R1.fastq.gz -O ${i}_fil.R2.fastq.gz -j ./fastp_report/${i}_fastp.json \
		-h ./fastp_report/${i}_fastp.html -t 2 -T 2 -q 20 -u 40 -3 -W 4 -M 20 -w 8

		fastqc -o ./fastqc_filt ./${i}_fil*

		##bowtie2 mapping
		bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p $thread -x ${indexpath} \
		-1 ${i}_fil.R1.fastq.gz -2 ${i}_fil.R2.fastq.gz -S ./alignment/${i}_bowtie2.sam &> ./alignment/${i}_bowtie2.txt
	else
		fastqc -o ./fastqc ./${i}*.fastq.gz
		##fastp filtrate
		fastp -i ${i}.fastq.gz -o ${i}_fil.fastq.gz -j ./fastp_report/${i}_fastp.json \
		-h ./fastp_report/${i}_fastp.html -t 2 -T 2 -q 20 -u 40 -3 -W 4 -M 20 -w 8
		
		##QC after filtration
		fastqc -o ./fastqc_filt ./${i}_fil*
			
		##bowtie2 mapping
		bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p $thread -x ${indexpath} \
		-U ${i}_fil.fastq.gz -S ./alignment/${i}_bowtie2.sam &> ./alignment/${i}_bowtie2.txt
		
	fi
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
done

sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_last_v1.2.sh "" \
	30 SRR13238390 rose "" srr.txt
