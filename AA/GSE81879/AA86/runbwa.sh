#!/bin/bash
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/panCancer/AA/GSE81879/AA86/bwa-%j.log
#SBATCH -J "AA_bwa"

cd /cluster2/home/futing/Project/panCancer/AA/GSE81879/AA86
echo "Running: bwa mem -SP5M $threadstring $refSeq $name1$ext $name2$ext > $name$ext.sam"
# mkdir -p ./{fastq,cool,anno,splits}
# rename _1 _R1 *fastq.gz
# rename _2 _R2 *fastq.gz
# rename .R1 _R1 *fastq.gz
# rename .R2 _R2 *fastq.gz  
mv *.fastq.gz ./fastq
source activate juicer
# ln -s ./fastq/* ./splits

cd splits
threadstring="-t 20"
refSeq=/cluster/home/futing/software/juicer_CPU/references/hg38.fa
ext=".fastq.gz"

# 01
name=SRR3586203
name1=${name}_R1
name2=${name}_R2
echo "Running: bwa mem -SP5M $threadstring $refSeq $name1$ext $name2$ext > $name$ext.sam"
bwa mem -SP5M $threadstring $refSeq $name1$ext $name2$ext > "$name$ext.sam"
# 02
name=SRR3586204
name1=${name}_R1
name2=${name}_R2
echo "bwa mem -SP5M $threadstring $refSeq $name$ext > $name$ext.sam"
bwa mem -SP5M $threadstring $refSeq $name$ext > $name$ext.sam
