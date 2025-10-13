#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --output=/cluster2/home/futing/Project/HiCQTL/GVCF-%j.log
#SBATCH --mem=250G 
#SBATCH -J "hapGVCF"
ulimit -s unlimited
ulimit -l unlimited

source activate /cluster/home/futing/miniforge-pypy3/envs/HiC
# 全局变量
debugdir="/cluster2/home/futing/Project/HiCQTL/CRC_gvcf"
mkdir -p "$debugdir/debug"
cd /cluster2/home/futing/Project/HiCQTL/ 

# cat /cluster2/home/futing/Project/HiCQTL/cell_hap0908.txt | while read -r cell;do
# cat /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/missing_gvcf.txt | while read -r cell;do
# cat /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/meta/cellhap1004.txt | while read -r cell;do
cat /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/meta/cellall1007.txt | while read -r cell;do
	echo "Processing ${cell}...\n"
	log_file="$debugdir/debug/${cell}-$(date +%Y%m%d_%H%M%S).log"
	sh "/cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/callSNP.sh" \
       "/cluster2/home/futing/Project/HiCQTL/CRC_gvcf/${cell}/${cell}.sorted.bam" >> "$log_file" 2>&1
done