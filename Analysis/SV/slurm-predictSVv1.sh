#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=3
#SBATCH --nodelist=node3
#SBATCH --output=/cluster2/home/futing/Project/panCancer/ALL/GSE145997/ALL_PDX17/debug/eagleCv1-%j.log
#SBATCH -J "eagleC"


source activate /cluster2/home/futing/miniforge3/envs/eagleCv1

cancer=ALL
gse=GSE145997
cell=ALL_PDX17
dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
mkdir -p $dir/anno/SV && cd $dir/anno/SV


predictSV --hic-5k $dir/cool/${cell}.mcool::/resolutions/5000 \
	--hic-10k $dir/cool/${cell}.mcool::/resolutions/10000  \
	--hic-50k $dir/cool/${cell}.mcool::/resolutions/50000 \
	-O ${cell} -g hg38 --balance-type ICE \
	--output-format NeoLoopFinder --prob-cutoff-5k 0.8 --prob-cutoff-10k 0.8 --prob-cutoff-50k 0.99999

# assemble-complexSVs -O ${cell} \
# 	-B ${cell}.SV_calls.txt \
# 	--balance-type ICE --protocol insitu \
# 	--nproc 15 \
# 	-H ${dir}/cool/${cell}.mcool::/resolutions/50000 \
# 	${dir}/cool/${cell}.mcool::/resolutions/10000 \
# 	${dir}/cool/${cell}.mcool::/resolutions/5000

# neoloop-caller -O ${cell}.neo-loops.txt \
# 	--assembly ${cell}.assemblies.txt \
# 	--balance-type ICE \
# 	--protocol insitu \
# 	--prob 0.95 --nproc 15 \
# 	-H ${dir}/cool/${cell}.mcool::/resolutions/50000 \
# 	${dir}/cool/${cell}.mcool::/resolutions/10000 \
# 	${dir}/cool/${cell}.mcool::/resolutions/5000

# ###ICE需要先cooler balance
