# cooltools genome binnify /cluster/home/jialu/genome/hg38.chrom.sizes 100000 >100k_bin.txt
# cooltools genome gc 100k_bin.txt ~/../../share/ref_genome/hg38/assembly/hg38.fa > gc.txt

#for i in NPC GBMmerge pHGG ipsc GBM_common GBMstem 
#cat filename |while read i 
#for i in A172 SW1088 U118 U343 U87
for i in U343
do 
cooler balance /cluster/home/futing/Project/GBM/HiC/02data/03cool/100000//${i}_100000.cool
cooltools eigs-cis \
--phasing-track gc.txt /cluster/home/futing/Project/GBM/HiC/02data/03cool/100000//${i}_100000.cool \
--out-prefix cooltool_new/${i}_cis_100k 
done
