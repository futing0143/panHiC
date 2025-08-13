#!/bin/bash
#SBATCH -J test
#SBATCH --output=./fq2bigwig_%j.log
#SBATCH --cpus-per-task=10

FASTQ_DIR="/cluster/home/futing/Project/GBM/Corigami/Training_data/GBM/G523/input/SRR8085201/"
OUT_NAME="G523_input"
REF_GENOME="/cluster/home/futing/ref_genome/GRCh38.fa"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"

# Step 1: get the name & make dir
ls *.R1.fastq.gz | cut -d"." -f1 > filename.txt
#mkdir -p ${FASTQ_DIR}/{fastqc,filter,fastp_report,fastqc_filt,alignment,fragmentLen,bam_files,bigwig}

cat filename.txt | while read i
do    
    # Step 3: mapping
    bwa mem -M -t 50 ${REF_GENOME} $FASTQ_DIR/filter/*.gz -o ./alignment/${i}.sam #&> ./alignment/${i}.txt
    echo "mapping completed"
	
	# Step 4: filter
	#filter other chromosomes
	samtools view -h -F 4 ./alignment/${i}.sam > ./alignment/${i}.mapped.sam
	head -n 300 ./alignment/${i}.mapped.sam | grep ^@SQ | tr ":" "\t" | cut -f3 | grep -v -w -f ${main_chr_list_path} > ./alignment/${i}_delchr.txt
	grep -v -f ./alignment/${i}_delchr.txt ./alignment/${i}.mapped.sam > ./alignment/${i}_fil.sam
	##assess mapped fragment size distribution
	samtools view ./alignment/${i}_fil.sam | awk -F '\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | \
	sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > ./fragmentLen/${i}_fragmentLen.txt
	
	##sam to bam
	samtools view -bS ./alignment/${i}_fil.sam > ./bam_files/${i}.bam
	samtools sort -o ./bam_files/${i}.sorted.bam ./bam_files/${i}.bam
	samtools index ./bam_files/${i}.sorted.bam
	
	##remove PCR duplicate
	picard MarkDuplicates I=./bam_files/${i}.sorted.bam O=./bam_files/${OUT_NAME}_final.bam REMOVE_DUPLICATES=true \
	M=./bam_files/${i}.rmdup.txt
	samtools index ./bam_files/${OUT_NAME}_final.bam

    # Step 5: BAM2BigWIg 
    bamCoverage -b ${FASTQ_DIR}/alignment/${OUT_NAME}_final.bam -o ${FASTQ_DIR}/bigwig/${OUT_NAME}_final.bw --normalizeUsing RPKM
    echo "BAM2BigWig completed!"

done


# Cleanup intermediate files
#rm ${FASTQ_DIR}/align/aligned.bam ${FASTQ_DIR}/align/sorted.bam ${FASTQ_DIR}/align/sorted.bam.bai ${FASTQ_DIR}/align/dedup.bam ${FASTQ_DIR}/align/dedup.bam.bai 
#rm ${FASTQ_DIR}/align/final.bam ${FASTQ_DIR}/align/final.bam.bai
echo "ChIP-seq analysis completed!"
