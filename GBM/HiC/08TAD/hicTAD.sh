file=`basename $1`
filename=${file%%.*}

for i in NPC GBMmerge GBMstem 
do 
cooler balance /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/25k/${i}.mcool::resolutions/25000
python add_prefix_to_cool.py /cluster/home/jialu/GBM/HiC/otherGBM/${i}.mcool::resolutions/25000
hicFindTADs -m /cluster/home/jialu/GBM/HiC/otherGBM/${i}.mcool::resolutions/25000 \
    --outPrefix ${i} --correctForMultipleTesting fdr
done

hicDifferentialTAD -tm /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/25k/GBMmerge_25k_normalized6.cool \
    -cm /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/25k/GSM4969660_NHA_25k_normalized6.cool \
    -td /cluster/home/jialu/GBM/HiC/otherGBM/TAD/GBM_merge_normalized_domains.bed -o GBMvsNHA -p 0.01 -t 4 -mr all
