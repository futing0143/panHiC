#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=15
#SBATCH --output=/cluster2/home/futing/Project/panCancer/GBM/GSE241592/NHA/debug/NHA_final-%j.log
#SBATCH -J "NHA"
ulimit -s unlimited
ulimit -l unlimited

export _JAVA_OPTIONS=-Xmx256g
export LC_ALL=en_US.UTF-8 
earlyexit=0
splitdir=/cluster2/home/futing/Project/panCancer/GBM/GSE241592/NHA/splits
outputdir=/cluster2/home/futing/Project/panCancer/GBM/GSE241592/NHA/aligned
genomePath="hg38"
juiceDir=/cluster2/home/futing/software/juicer_CPU
site_file=/cluster2/home/futing/software/juicer_CPU/restriction_sites/hg38_Arima.txt
ligation="(GAATAATC|GAATACTC|GAATAGTC|GAATATTC|GAATGATC|GACTAATC|GACTACTC|GACTAGTC|GACTATTC|GACTGATC|GAGTAATC|GAGTACTC|GAGTAGTC|GAGTATTC|GAGTGATC|GATCAATC|GATCACTC|GATCAGTC|GATCATTC|GATCGATC|GATTAATC|GATTACTC|GATTAGTC|GATTATTC|GATTGATC)"


${juiceDir}/scripts/common/juicer_tools pre --threads 20 \
	-s $outputdir/inter.txt -g $outputdir/inter_hists.m \
	-q 1 $outputdir/merged_nodups.txt $outputdir/inter.hic $genomePath



# ${juiceDir}/scripts/common/juicer_tools pre --threads 20 \
# 	-s $outputdir/inter_30.txt -g $outputdir/inter_30_hists.m \
# 	-q 30 $outputdir/merged_nodups.txt $outputdir/inter_30.hic $genomePath 


# ${juiceDir}/scripts/common/juicer_postprocessing.sh \
# 	-j ${juiceDir}/scripts/common/juicer_tools -i ${outputdir}/inter_30.hic -m ${juiceDir}/references/motif -g ${genomeID}

# export early=$earlyexit
# export splitdir=$splitdir
# source ${juiceDir}/scripts/common/check.sh

# bash /cluster2/home/futing/Project/panCancer/NUT/sbatch.sh GSE133163 TC-797 MboI