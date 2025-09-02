
#cat filename | while read i
#for i in 250000 500000 2500000
#do
for j in G523 GB567 GB583
do
    for i in 25000 10000 250000 500000 1000000 2500000 5000 50000 100000
    for i in 25000 10000 250000 500000 1000000 2500000
    do
        cooler dump --join ${j}.mcool::/resolutions/${i} | cooler load --format bg2 /cluster/home/jialu/genome/hg38_24chr_nochr.chromsize:${i} - /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/${j}_${i}.cool
        python /cluster/home/jialu/GBM/HiC/otherGBM/add_prefix_to_cool.py  /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/G523_${i}.cool
        python /cluster/home/jialu/GBM/HiC/otherGBM/add_prefix_to_cool.py  /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB567_${i}.cool
        python /cluster/home/jialu/GBM/HiC/otherGBM/add_prefix_to_cool.py  /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB583_${i}.cool
        ##合并 GBM_raw G523  GB567  GB583
        cooler merge /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMmerge_${i}.cool \
        /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMraw_${i}.cool /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/G523_${i}.cool \
        /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB583_${i}.cool /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB567_${i}.cool

        hicInfo -m /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMraw_${i}.cool
        hicInfo -m /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/G523_${i}.cool
        hicInfo -m /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB567_${i}.cool
        hicInfo -m /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB583_${i}.cool
    done
done


hicConvertFormat -m ./5000/GBMraw_5000.cool ./10000/GBMraw_10000.cool ./25000/GBMraw_25000.cool ./2500000/GBMraw_2500000.cool ./500000/GBMraw_500000.cool ./1000000/GBMraw_1000000.cool ./250000/GBMraw_250000.cool ./50000/GBMraw_50000.cool ./100000/GBMraw_100000.cool  \
    --inputFormat cool --outputFormat mcool -o GBM_9reso.mcool

#------------------执行的代码------------------
hicConvertFormat -m ./5000/GBMstem_5000.cool ./10000/GBMstem_10000.cool ./25000/GBMstem_25000.cool ./2500000/GBMstem_2500000.cool ./500000/GBMstem_500000.cool ./1000000/GBMstem_1000000.cool ./250000/GBMstem_250000.cool ./50000/GBMstem_50000.cool ./100000/GBMstem_100000.cool  \
    --inputFormat cool --outputFormat mcool -o GBMstem_9reso.mcool




