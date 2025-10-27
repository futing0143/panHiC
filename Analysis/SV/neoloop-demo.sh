#!/bin/bash
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node3
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/SV/test-%j.log
#SBATCH -J "eagleC"


source activate /cluster2/home/futing/miniforge3/envs/eagleC

dir=/cluster2/home/futing/Project/panCancer/AA/GSE81879/AA86
mkdir -p $dir/anno/SV && cd $dir/anno/SV
# ln -s /cluster2/home/futing/Project/panCancer/Analysis/SV/EagleC2-models ${dir}/cool/
predictSV --mcool ${dir}/cool/AA86.mcool \
	-O AA86 -g hg38 --balance-type ICE -p 15

<< 'EOF'
predictSV --hic-5k $dir/cool/${cell}-MboI-allReps-filtered.mcool::/resolutions/5000 \
--hic-10k $dir/cool/${cell}-MboI-allReps-filtered.mcool::/resolutions/10000  \
--hic-50k $dir/cool/${cell}-MboI-allReps-filtered.mcool::/resolutions/50000 \
-O ${cell} -g hg38 --balance-type ICE --output-format NeoLoopFinder --prob-cutoff-5k 0.8 --prob-cutoff-10k 0.8 --prob-cutoff-50k 0.99999


predictSV --mcool ${dir}/cool/FY1199.used_for_SVpredict.mcool --resolutions 25000,50000,100000 \
            --high-res 25000 --prob-cutoff-1 0.5 --prob-cutoff-2 0.5 -O FY1199_EagleC2 \
            -g hg38 --balance-type ICE -p 8 --intra-extend-size 1,1,1 --inter-extend-size 1,1,1

#  calculate the CNV profile
calculate-cnv -H SKNMC-MboI-allReps-filtered.mcool::resolutions/25000 -g hg38 \
                -e MboI --output SKNMC_25k.CNV-profile.bedGraph
# identify CNV segments from the original signals
segment-cnv --cnv-file SKNMC_25k.CNV-profile.bedGraph --binsize 25000 \
              --ploidy 2 --output SKNMC_25k.CNV-seg.bedGraph --nproc 4
# the inferred CNV
plot-cnv --cnv-profile SKNMC_25k.CNV-profile.bedGraph \
           --cnv-segment SKNMC_25k.CNV-seg.bedGraph \
           --output-figure-name SKNMC_25k.CNV.bychrom.png \
           --dot-size 1.5 --dot-alpha 0.3 --line-width 1.5 --boundary-width 1 \
           --label-size 7 --tick-label-size 6 --maximum-value 3 \
           --minimum-value -5 -C 3 4 5 6 7 8
# Remove CNV biases from Hi-C contacts
correct-cnv -H SKNMC-MboI-allReps-filtered.mcool::resolutions/25000 \
              --cnv-file SKNMC_25k.CNV-seg.bedGraph --nproc 4 -f
file=/cluster2/home/futing/Project/panCancer/AA/GSE81879/AA86/anno/SV/SKNMC-MboI-allReps-filtered.mcool
for reso in 50000 10000 5000;do
	file1=/cluster2/home/futing/Project/panCancer/AA/GSE81879/AA86/anno/SV/SKNMC-MboI-allReps-filtered.mcool::/resolutions/${reso}
	if cooler dump -t bins --header "$file1" | head -1 | grep -qw "weight";then
		continue
	else
		echo "${file1} is not ICE balanced!"
	# cooler balance "$file1"
	fi
done

assemble-complexSVs -O AA86 \
	-B AA86.SV_calls.txt \
	--balance-type ICE --protocol insitu \
	--nproc 15 \
	-H ${dir}/cool/AA86.mcool::/resolutions/50000 \
	${dir}/cool/AA86.mcool::/resolutions/10000 \
	${dir}/cool/AA86.mcool::/resolutions/5000

neoloop-caller -O AA86.neo-loops.txt \
	--assembly AA86.assemblies.txt \
	--balance-type ICE \
	--protocol insitu \
	--prob 0.95 --nproc 15 \
	-H ${dir}/cool/AA86.mcool::/resolutions/50000 \
	${dir}/cool/AA86.mcool::/resolutions/10000 \
	${dir}/cool/AA86.mcool::/resolutions/5000
	
EOF



# ###ICE需要先cooler balance
