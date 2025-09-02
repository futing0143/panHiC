for i in U343 U118 SW1088 A172 U87
do
hicConvertFormat -m ${i}/mega/aligned/inter_30.hic --inputFormat hic --outputFormat cool -o ${i}.mcool
python /cluster/home/jialu/GBM/HiC/otherGBM/add_prefix_to_cool.py ${i}.mcool::resolutions/100000
cooler dump --join ${i}.mcool::resolutions/100000 | cooler load --format bg2 /cluster/home/jialu/genome/hg38_24chrm.chrom.size:100000 - /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/100k/${i}_100k.cool

done
