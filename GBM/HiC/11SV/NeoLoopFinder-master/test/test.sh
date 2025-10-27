#!/usr/bin/env bash
# install the NeoLoopFinder package
# detailed documentation can be found at /code/README.rst
pip install -v .

# 01 download the example data
wget -O SKNMC-MboI-allReps-filtered.mcool -L https://www.dropbox.com/s/tuhhrecipkp1u8k/SKNMC-MboI-allReps-filtered.mcool?dl=0


for res in 10000 5000;do   #25000 
	resk=$(($res/1000))
	# 02 calculate CNV profiles
	# calculate-cnv -H SKNMC-MboI-allReps-filtered.mcool::resolutions/${res} -g hg38 \
	# 				-e MboI --output SKNMC_${resk}.CNV-profile.bedGraph

	# 03 identify CNV segments from the original signal
	segment-cnv --cnv-file SKNMC_${resk}.CNV-profile.bedGraph --binsize ${res} \
				--ploidy 2 --output SKNMC_${resk}.CNV-seg.bedGraph --nproc 4
				# --ploidy mean 几倍体
	plot-cnv --cnv-profile SKNMC_${resk}.CNV-profile.bedGraph \
			--cnv-segment SKNMC_${resk}.CNV-seg.bedGraph \
			--output-figure-name SKNMC_${resk}.CNV.genome-wide.png \
			--dot-size 0.5 --dot-alpha 0.2 --line-width 1 --boundary-width 0.5 \
			--label-size 7 --tick-label-size 6 --clean-mode 
			#--maximum-value 3 \
			#--minimum-value -5 -C 3 4 5 6 7 8 -C means chromosome

	# 04 remove CNV biases from HiC contact
	correct-cnv -H SKNMC-MboI-allReps-filtered.mcool::resolutions/${res} \
				--cnv-file SKNMC_${resk}.CNV-seg.bedGraph --nproc 4 -f
done
# 储存在 sweight

# 05 assemble complex SVs
# 以下分析基于sweight，但 --balance-type ICE 可以使用ICE来balance
# 多个 cool 则类似于 hiccups 分别 call 再合并在一起
# 输入需要来源于 Eagle-C ，例子如下，6列txt
# chr7    chr14   ++      14000000        37500000        translocation
wget -O SKNMC-EagleC.SV.txt -L https://www.dropbox.com/s/g1wa799wgwta9p4/SK-N-MC.EagleC.txt?dl=0
assemble-complexSVs -O SKNMC -B SKNMC-EagleC.SV.txt --balance-type CNV \
					--protocol insitu --nproc 15 \
					-H SKNMC-MboI-allReps-filtered.mcool::resolutions/25000 \
						SKNMC-MboI-allReps-filtered.mcool::resolutions/10000 \
						SKNMC-MboI-allReps-filtered.mcool::resolutions/5000

# result 
# SKNMC.assemblies.txt
# C0  translocation,1,10260000,+,X,21495000,- 1,9380000       X,22205000

# 06 detect neo-loops
neoloop-caller -O SKNMC.neo-loops.txt --assembly SKNMC.assemblies.txt \
                 --balance-type CNV --protocol insitu --prob 0.95 --nproc 4 \
                 -H SKNMC-MboI-allReps-filtered.mcool::resolutions/25000 \
                    SKNMC-MboI-allReps-filtered.mcool::resolutions/10000 \
                    SKNMC-MboI-allReps-filtered.mcool::resolutions/5000 \

# result
# last column SVid, the genomic distance between two loop anchors on the assembly, whether this is a neo-loop
# chr1        9490000 9500000 chr1    9860000 9870000 C0,370000,0

# # detect and assemble complex SVs in K562 using the example data
# assemble-complexSVs -O ../results/K562 -B ../data/K562-test-SVs.txt \
# 	-H ../data/K562-MboI-allReps-hg38.10K.cool

# # detect neo-loops for each assembly
# neoloop-caller -O ../results/K562.neo-loops.txt -H ../data/K562-MboI-allReps-hg38.10K.cool \
# 	--assembly ../results/K562.assemblies.txt --no-clustering --prob 0.95

# # reproduce the figure 1b
# python visualize-example-assembly.py
