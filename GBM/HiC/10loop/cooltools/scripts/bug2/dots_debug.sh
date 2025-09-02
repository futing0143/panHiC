#!/bin/bash
filelist=$1
resolutions=(5000 10000 25000)
top_folder=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/
source activate ~/anaconda3/envs/hic
cd /cluster/home/futing/Project/GBM/HiC/10loop/cooltools


# NPC 25000 not balance
mcool_file=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/02NPC/NPC.mcool
name=NPC
cd $name
echo -e "\nProcessing $name...\n"
#cooler balance ${mcool_file}::resolutions/25000
python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py -i ${mcool_file}::resolutions/25000 -n $name
echo -e "\nRunning expected-cis...\n"
cooltools expected-cis --nproc 6 -o ./expected.cis.25000.tsv \
    --view ./${name}_view_hg38.tsv ${mcool_file}::resolutions/25000
echo -e "\nRunning dots...\n"
cooltools dots --nproc 6 -o ./dots.25000.tsv --view ./${name}_view_hg38.tsv \
    ${mcool_file}::resolutions/25000 ./expected.cis.25000.tsv 

cd ..

# 208 213 chrom id diff
for name in G208 G213;do
    cd $name
    echo -e "\nProcessing $name...\n"
    mcool_file=/cluster/home/futing/Project/GBM/HiC/02data/04mcool/01GBM/${name}.mcool
    
    python /cluster/home/futing/Project/GBM/HiC/10loop/cooltools/view_hg38.py -i ${mcool_file}::resolutions/25000 -n ${name}_25000
    
    echo -e "\nRunning expected-cis for ${name}...\n"
    cooltools expected-cis --nproc 6 -o ./expected.cis.25000.tsv \
        --view ./${name}_25000_view_hg38.tsv ${mcool_file}::resolutions/25000
    
    echo -e "\nRunning dots for ${name}...\n"
    cooltools dots --nproc 6 -o ./dots.25000.tsv --view ./${name}_25000_view_hg38.tsv \
        ${mcool_file}::resolutions/25000 ./expected.cis.25000.tsv 
    cd ..
done