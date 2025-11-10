#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node3
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/dchic/debug/dchic_p-%j.log
#SBATCH -J "dchic"

cd /cluster2/home/futing/Project/panCancer/Analysis/dchic
mkdir -p pca && cd pca
source activate /cluster2/home/futing/miniforge3/envs/dchic
###生成_PCA 文件夹

Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/input1106.txt \
	--pcatype cis --dirovwt T 
Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/input1106.txt \
	--pcatype select --dirovwt T --genome hg38 

# cat ../cancer_list.txt | while read line;do
# 	echo -e "Processing $line...\n"
# 	grep "$line" ../input.txt > ../tmp
# 	Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 		--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/tmp \
# 		--pcatype cis --dirovwt T 
# 	Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 		--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/tmp \
# 		--pcatype select --dirovwt T --genome hg38 
# done

# python /path/to/dchic.py -res 100000 -inputFile input.txt 	-chrFile /cluster2/home/futing/Project/panCancer/Analysis/dchic/hg38.genome \
# 	-input 2 -alignData /path/to/mm10_goldenpathData -genome mm10 -blacklist mm10blacklist_sorted.bed

	# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
	# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/tmp \
	# 	--pcatype cis --dirovwt T 
	# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
	# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/tmp \
	# 	--pcatype select --dirovwt T --genome hg38 

###生成DifferentialResult/GBM_vs_3type 文件夹
# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/NPC.txt \
# 	--pcatype analyze --dirovwt T --diffdir NPC
# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/NPC.txt \
# 	--pcatype subcomp --dirovwt T --diffdir NPC
# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/NPC.txt \
# 	--pcatype viz --diffdir NPC --genome hg38 
# Rscript /cluster2/home/futing/software/dcHiC-master/dchicf.r \
# 	--file /cluster2/home/futing/Project/panCancer/Analysis/dchic/NPC.txt \
# 	--pcatype enrich --genome hg38  \
#   	--diffdir NPC --exclA F --region anchor \
# 	--pcgroup pcQnm --interaction intra --pcscore F --compare F
