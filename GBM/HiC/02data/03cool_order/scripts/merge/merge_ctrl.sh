#!/bin/bash

reso=$1

cd /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/${reso}
source activate HiC
data_dir=//cluster/home/futing/Project/GBM/HiC/02data/03cool_order/


cooler merge ${data_dir}/${reso}/astro_merge2_${reso}.cool \
	${data_dir}/${reso}/astro1_${reso}.cool ${data_dir}/${reso}/astro2_${reso}.cool #\
	# ${data_dir}/${reso}/NHA_${reso}.cool
cooler balance ${data_dir}/${reso}/astro_merge2_${reso}.cool --max-iters 1000 #&& mv ${data_dir}/${reso}/astro_merge_${reso}.cool ${data_dir}/${reso}/astro_${reso}.cool
# cooler balance ${data_dir}/${reso}/astro_${reso}.cool --force --max-iters 1000
# echo -e "\nMerging NPC ..."
# cooler merge ${data_dir}/${reso}/NPC_merge_${reso}.cool \
# 	${data_dir}/${reso}/NPC_new_${reso}.cool ${data_dir}/${reso}/NPC_${reso}.cool
# cooler balance ${data_dir}/${reso}/NPC_merge_${reso}.cool

# echo -e "\nMerging iPSC ..."
# cooler merge ${data_dir}/${reso}/iPSC_merge_${reso}.cool \
# 	${data_dir}/${reso}/iPSC_new_${reso}.cool ${data_dir}/${reso}/ipsc_${reso}.cool
# cooler balance ${data_dir}/${reso}/iPSC_merge_${reso}.cool
