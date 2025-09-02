/cluster/home/futing/software/juicer/scripts/juicer.sh \
-D /cluster/home/futing/software/juicer \
-d /cluster/home/futing/Project/GBM/HiC/00data/GBM/ourdata/ts667_kd -g hg38 \
-p /cluster/home/futing/software/juicer/restriction_sites/hg38.genome \
-z /cluster/home/futing/software/juicer/references/hg38.fa \
-s HindIII -t 20 -S final -q gpu -l gpu
##原本不是这个名称 这个是从fa中提取的