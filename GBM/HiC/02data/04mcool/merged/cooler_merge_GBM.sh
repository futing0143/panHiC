for i in 5000 10000 25000 50000 100000 250000 500000 1000000 2500000
do
    for j in ts543 ts667
    do
    #cooler dump --join /cluster/home/jialu/GBM/HiC/juicer_hind3/mergeall.mcool::/resolutions/${i} \
    #| cooler load --format bg2 /cluster/home/jialu/genome/hg38_24chrm.chrom.size:${i} \
    #- /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMour_${i}.cool

       cooler dump --join /cluster/home/futing/Project/GBM/HiC/02data/04mcool/${j}.mcool::/resolutions/${i} \
       | cooler load --format bg2 /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/hg38_24chr_nochr.chromsize:${i} \
       - /cluster/home/futing/Project/GBM/HiC/02data/03cool/${i}/${j}_${i}.cool

        python /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/add_prefix_to_cool.py \
        /cluster/home/futing/Project/GBM/HiC/02data/03cool/${i}/${j}_${i}.cool


    #cooler merge /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMstem_${i}.cool \
    #/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GBMour_${i}.cool \
    #/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/G523_${i}.cool \
    #/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB583_${i}.cool \
    #/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/${i}/GB567_${i}.cool
    done
done

# cooler dump --join GBMraw.mcool::/resolutions/100000 \
#| cooler load --format bg2 /cluster/home/jialu/genome/hg38_24chr_nochr.chromsize:100000 \
#- /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/100k/GBMraw_100k.cool

# python /cluster/home/jialu/GBM/HiC/otherGBM/add_prefix_to_cool.py \
#/cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/100k/GBMraw_100k.cool

