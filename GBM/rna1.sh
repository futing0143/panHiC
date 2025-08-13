#!/bin/bash

source activate RNAseq
# 设定变量
FASTQ_DIR=$1
if [ ! -d "$FASTQ_DIR" ]; then
    echo "Error: FASTQ directory does not exist."
    exit 1
fi


mkdir -p ${FASTQ_DIR}/{fastqc_before,fastqc_filt,trimmed,aligned,rsem_out}
TRIMMED_DIR=${FASTQ_DIR}/trimmed
ALIGN_DIR=${FASTQ_DIR}/aligned

REF_GENOME="/cluster/home/futing/ref_genome/hg38_gencode/hg38.fa"
GTF="/cluster/home/futing/ref_genome/hg38_gencode/gencode.v43.annotation.gtf"
STAR_INDEX="/cluster/home/futing/ref_genome/hg38_gencode/STAR"

# Step 1: get the name & make dir
cd ${FASTQ_DIR}
rename fq.gz fastq.gz *fq.gz
rename _R1 .R1 *fastq.gz
rename _R2 .R2 *fastq.gz
rename _1 .R1 *fastq.gz
rename _2 .R2 *fastq.gz
ls *.R1.fastq.gz | cut -d"." -f1 > filename.txt

cat ${filename} | while read i
do
    # 质量控制
    echo "Running FastQC..."
    fastqc -o ${FASTQ_DIR}/fastqc_before ${FASTQ_DIR}/${i}.R1.fastq.gz ${FASTQ_DIR}/${i}.R2.fastq.gz

    # 去除接头和低质量序列
    echo "Running Trimmomatic..."
    fq1=${i}.R1.fastq.gz
    fq2=${i}.R2.fastq.gz
    trimmomatic PE -threads 20 ${fq1} ${fq2}\
    ${TRIMMED_DIR}/${i}_trimmed.R1.fastq.gz ${TRIMMED_DIR}/${i}.unpaired.R1.fastq.gz \
    ${TRIMMED_DIR}/${i}_trimmed.R2.fastq.gz ${TRIMMED_DIR}/${i}.unpaired.R2.fastq.gz \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    #ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 \


    # Step 2: qc
    echo "Running FastQC after trimming..."
    fastqc -o ${FASTQ_DIR}/fastqc_filt ${TRIMMED_DIR}/*.gz
    multiqc -o ${FASTQ_DIR}/fastqc_before ${FASTQ_DIR}/fastqc_before/*zip
    multiqc -o ${FASTQ_DIR}/fastqc_filt ${FASTQ_DIR}/fastqc_filt/*_trimmed*.zip


    # Step 3:序列比对
    echo "Running STAR..."
    for trimmed_fq1 in $TRIMMED_DIR/*_trimmed.R1.fastq.gz
    do
        base=$(basename $trimmed_fq1 _trimmed.R1.fastq.gz)
        trimmed_fq2=${trimmed_fq1%_trimmed.R1.fastq.gz}_trimmed.R2.fastq.gz
        STAR --genomeDir ${STAR_INDEX} --readFilesIn ${trimmed_fq1} ${trimmed_fq2} \
        --outSAMtype BAM SortedByCoordinate \
        --quantMode GeneCounts TranscriptomeSAM \
        --readFilesCommand zcat \
        --runThreadN 20 --outFileNamePrefix $ALIGN_DIR/${base}
        #samtools view -bS $ALIGN_DIR/${base}_Aligned.toTranscriptome.out.sam > $ALIGN_DIR/${base}_Aligned.toTranscriptome.out.bam
    done

    # 计算基因表达量
    base=${basename ${FASTQ_DIR}}
    echo "Running featureCounts..."
    featureCounts -T 20 -a ${GTF} -o $ALIGN_DIR/counts.txt $ALIGN_DIR/${i}Aligned.sortedByCoord.out.bam

    echo "Running RSEM..."
    rsem-calculate-expression --paired-end -no-bam-output --alignments -p 20 \
        ${FASTQ_DIR}/aligned/${base}Aligned.toTranscriptome.out.bam \
        /cluster/home/futing/ref_genome/hg38_gencode/RSEM/RSEM \
        ${FASTQ_DIR}/rsem_out/${base}
done
echo "RNA-seq analysis completed!"