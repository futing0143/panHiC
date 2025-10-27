#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node3
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/SV/test-%j.log
#SBATCH -J "eagleC"


source activate /cluster2/home/futing/miniforge3/envs/neoloop

dir=/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}
mkdir -p $dir/anno/SV && cd $dir/anno/SV
ln -s /cluster2/home/futing/Project/panCancer/Analysis/SV/EagleC2-models ${dir}/cool/
predictSV --mcool ${dir}/cool/${cell}.mcool \
	-O ${cell} -g hg38 --balance-type ICE -p 15

reformatSV --input ${cell}.SV_calls.txt \
	--output-file ${cell}.SV_calls.reformat.txt

assemble-complexSVs -O ${cell} \
	-B ${cell}.SV_calls.reformat.txt \
	--balance-type ICE --protocol insitu \
	--nproc 15 \
	-H ${dir}/cool/${cell}.mcool::/resolutions/50000 \
	${dir}/cool/${cell}.mcool::/resolutions/10000 \
	${dir}/cool/${cell}.mcool::/resolutions/5000

neoloop-caller -O ${cell}.neo-loops.txt \
	--assembly ${cell}.assemblies.txt \
	--balance-type ICE \
	--protocol insitu \
	--prob 0.95 --nproc 15 \
	-H ${dir}/cool/${cell}.mcool::/resolutions/50000 \
	${dir}/cool/${cell}.mcool::/resolutions/10000 \
	${dir}/cool/${cell}.mcool::/resolutions/5000

###ICE需要先cooler balance
