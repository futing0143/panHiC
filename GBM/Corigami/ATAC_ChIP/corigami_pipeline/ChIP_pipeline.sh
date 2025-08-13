#!/bin/bash
#SBATCH -J ctcf_pipeline
#SBATCH --output=./ctcf_pipeline_%j.log 
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=10  # 每个任务所需要的核心数，默认为1

#module load seqtk/1.3
#module load git
#module load samtools/1.9
module load anaconda3/2020.02

echo "All files downloaded, merging"
# Merge fastq files
cat ip/* > ip/ip.fastq.gz
cat input/* > input/input.fastq.gz

echo "Files merged, subsampling"
# subsample fastq files
zcat ip/ip.fastq.gz | echo "IP reads: $((`wc -l`/4))"
seqtk sample -s 2021 ip/ip.fastq.gz 30000000 | gzip > ip/sub_ip_R1.fastq.gz
zcat ip/sub_ip_R1.fastq.gz | echo "sub IP reads: $((`wc -l`/4))"

zcat input/input.fastq.gz | echo "input reads: $((`wc -l`/4))"
seqtk sample -s 2021 input/input.fastq.gz 30000000 | gzip > input/sub_input_R1.fastq.gz
zcat input/sub_input_R1.fastq.gz | echo "sub input reads: $((`wc -l`/4))"

echo "Files merged, running pipeline"
# run sns pipeline
mkdir -p sns
cd sns
git clone --depth 1 https://github.com/igordot/sns
sns/generate-settings hg38
sns/gather-fastqs ../fastq
sns/run chip

echo "Pipeline job submitted"
