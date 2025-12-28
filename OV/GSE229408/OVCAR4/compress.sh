#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=10
#SBATCH --output=/cluster2/home/futing/Project/panCancer/OV/GSE229408/OVCAR4/debug/compress-%j.log
#SBATCH -J "Compress"

cd /cluster2/home/futing/Project/panCancer/OV/GSE229408/OVCAR4
source activate /cluster2/home/futing/miniforge3/envs/juicer
cancer="OV"
gse="GSE229408"
cell="OVCAR4"
srr=SRR24134016
echo -e "Processing ${cancer}/${gse}/${cell}...\n"
root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}

if ! command -v samtools &> /dev/null; then
	echo "samtools could not be found, please install it first."
	exit 1
fi

find "${root_directory}/splits_err" -type f -name "${srr}*.sam" -print0 |
while IFS= read -r -d '' file; do
# file=${root_directory}/splits_err/${srr}.fastq.gz.sam
bam_path="${file%.sam}.bam"
echo -e "[$(date)] Converting SAM to BAM for file: $file\n"
samtools view -@ 20 -bS "$file" > "$bam_path" &&
rm "$file" &&
echo "[$(date)] Converted and deleted: $file" &&
echo "[$(date)] Created BAM file: $bam_path"
done


# echo -e "Processing ${cancer}/${gse}/${cell} for txt...\n"
# root_directory=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/aligned_err
# root_directory2=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/splits_err
# find "$root_directory" "$root_directory2" -type f -name "*.txt" -print0 |
# while IFS= read -r -d '' file; do
# 	file="${file%$'\r'}"
# 	gzip "$file"
# 	echo "compress gzip: $file"
# done