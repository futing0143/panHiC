#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=20
#SBATCH --nodelist=node1
#SBATCH --output=/cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/gvcf2vcf-%j.log
#SBATCH -J "gvcf2vcf"
ulimit -s unlimited
ulimit -l unlimited

# bash /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/gvcf_to_vcf.sh \
# 	/cluster2/home/futing/Project/HiCQTL/CRCdone.txt \
# 	/cluster2/home/futing/Project/HiCQTL/CRC_gvcf \
# 	CRC53

bash /cluster2/home/futing/Project/HiCQTL/pipeline/gvcf_hic/gvcf_to_vcf_fix.sh \
	/cluster2/home/futing/Project/HiCQTL/CRCdone.txt \
	/cluster2/home/futing/Project/HiCQTL/CRC_gvcf \
	CRC53