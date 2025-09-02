#!/bin/bash


source activate scRNAseq

cd /cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis/NHA
STAR_INDEX="/cluster/home/futing/ref_genome/hg38_gencode/STAR_711b"

ls ./ | grep 'SRR*' | while read dir;do
	echo -e "Processing ${dir}...\n"
	# trimmed_fq1=${dir}/trimmed/${dir}_trimmed.R1.fastq.gz
	# STAR --genomeDir ${STAR_INDEX} --readFilesIn ${trimmed_fq1} \
	# 	--outSAMtype BAM SortedByCoordinate \
	# 	--quantMode GeneCounts TranscriptomeSAM \
	# 	--readFilesCommand zcat \
	# 	--runThreadN 20 --outFileNamePrefix ${dir}/aligned/${dir}

	samtools sort -o ${dir}/aligned/${dir}.sorted.bam ${dir}/aligned/${dir}Aligned.sortedByCoord.out.bam
	samtools index ${dir}/aligned/${dir}.sorted.bam
done 


sh norm.sh > norm.log 2>&1 &