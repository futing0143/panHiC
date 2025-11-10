#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/RMS/GSE253894/

for cell in WT P3F1 P7F1;do

	# mkdir -p /cluster2/home/futing/Project/panCancer/RMS/GSE253894/induced_pluripotent_stem_cell_muscle_progenitor_${cell}/{aligned,anno,cool,debug,fastq,splits}
	# mv GSE253894_${cell}_merged_inter_30.hic ./induced_pluripotent_stem_cell_muscle_progenitor_${cell}/aligned/inter_30.hic
	sh /cluster2/home/futing/Project/panCancer/RMS/sbatch.sh GSE253894 induced_pluripotent_stem_cell_muscle_progenitor_${cell} Arima

done