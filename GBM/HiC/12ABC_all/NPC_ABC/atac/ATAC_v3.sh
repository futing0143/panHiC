#!/bin/bash

##Usage: sh /cluster/home/chenglong/pipeline_suc/atac_pipeline_all/atac_new/ATAC_v3.sh ${thread(d)} ${retain_temp_file_flag(d)}
##d as default,50,you can omit it.
##Built by Xiaorui Zhou and Chenglong Ling on 2022.08.16

source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose

thread=${1:-50}
retain_temp_file_flag=${2:-no}

#necessary file index
indexpath="/cluster/share/ref_genome/hg38/index/bowtie2/hg38"
chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
TSS_BED="/cluster/home/chenglong/reference/pcg_gene_tss_v38.bed"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"
homer_hg38_ref="/cluster/home/chenglong/homer/data/genomes/hg38"
wd=`pwd`
wd_name=`basename ${wd}`


#rename _R1 .R1 *fastq.gz
#rename _R2 .R2 *fastq.gz
#ls *.R1.fastq.gz | cut -d "." -f1 > filename.txt

mkdir -p ./{fastqc,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files}

cat filename.txt | while read i
do
	##QC before filtration
	fastqc -o ./fastqc ./${i}*.fastq.gz
		
	##fastp filtrate
	fastp -i ${i}.R1.fastq.gz -I ${i}.R2.fastq.gz -o ${i}_fil.R1.fastq.gz -O ${i}_fil.R2.fastq.gz -j ./fastp_report/${i}_fastp.json \
	-h ./fastp_report/${i}_fastp.html -t 2 -T 2 -q 20 -u 40 -3 -W 4 -M 20 -w 8
	
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

done

#merge qc result
multiqc -o ./fastqc ./fastqc/*zip
multiqc -o ./fastqc_filt ./fastqc_filt/*zip

##remove not necessary files.
if [ $retain_temp_file_flag = "no" ];then
        rm ./alignment/*sam
        rm ./bam_files/*_bowtie2.bam
        ls ./bam_files/*.sorted.bam* | xargs rm
        ls ./*_fil.R*fastq.gz | xargs rm
fi
