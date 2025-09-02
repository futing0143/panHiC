for i in U87 U343 SW1088 A172 U118
do
/cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/juicer.sh \
-D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer \
-d /cluster/home/jialu/GBM/hicnew/xu/onedir/${i} \
-g hg38 -p /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome \
-z /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.fa -s MboI -S merge
done
