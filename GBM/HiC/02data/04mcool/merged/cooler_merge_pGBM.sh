cat filename_GBM | while read i
do 
    cooler dump --join ${i}::resolutions/5000 | cooler load --format bg2 /cluster/home/jialu/genome/hg38.chrom.sizes:5000 - 5k/${i%.*}_5k.cool
done

##bins_1M.txt是1M的bin文件，bins_1M_d.txt是去掉chr的bin文件
cooltools genome binnify /cluster/home/jialu/genome/hg38.chrom.sizes  1000000 > bins_1M.txt
sed "s/chr//"  /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/bins_1M.txt > /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/bins_1M_d.txt

#------------------执行的代码------------------
#for i in 10k 25k 100k 1M
for i in 5k 50k
do
    cooler merge ${i}/DIPG-3810_${i}.cool ${i}/GSM4969658_DIPG007_${i}.cool ${i}/SF9427_${i}.cool ${i}/DIPGXIII_${i}.cool 
done
