#!/bin/bash
#SBATCH -J atac
#SBATCH --output=./atac_pipeline_%j.log 
#SBATCH --time=48:00:00
#SBATCH -N 8
#SBATCH --cpus-per-task=10  # 每个任务所需要的核心数，默认为1

#module load seqtk/1.3
#module load git
#module load samtools/1.9
module load anaconda3/2020.02
echo "All files downloaded, merging"
## Cat different replicates
cat end1/rep1/* end1/rep2/* > end1/merged1.fastq.gz
cat end2/rep1/* end2/rep2/* > end2/merged2.fastq.gz

echo "Files merged, subsampling end 1"
zcat end1/merged1.fastq.gz | echo "end 1 reads: $((`wc -l`/4))"
seqtk sample -s 2021 end1/merged1.fastq.gz 40000000 | gzip > sub_merged_R1.fastq.gz
zcat sub_merged_R1.fastq.gz | echo "sub end 1 reads: $((`wc -l`/4))"

echo "Files merged, subsampling end 2"
zcat end2/merged2.fastq.gz | echo "end 2 reads: $((`wc -l`/4))"
seqtk sample -s 2021 end2/merged2.fastq.gz 40000000 | gzip > sub_merged_R2.fastq.gz
zcat sub_merged_R2.fastq.gz | echo "sub end 2 reads: $((`wc -l`/4))"

echo "Files merged, running sns pipeline"
mkdir -p sns
cd sns
git clone --depth 1 https://github.com/igordot/sns
sns/generate-settings hg38
sns/gather-fastqs ../
sns/run atac

echo "Pipeline job submitted"
