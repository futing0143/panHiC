# for i in ts667_ck ts667_kd ts543_ck ts543_kd
# do 
# /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/juicer.sh \
# -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer \
# -d /cluster/home/jialu/GBM/hicnew/ourdata/ts667_ck -g hg38 \
# -p /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome \
# -z /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.fa -s HindIII -S merge
# done

/cluster/home/futing/software/juicer_CPU/scripts/common/mega.sh -s HindIII -g hg38 -d /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/ourdata/onedir/ts543 -D /cluster/home/futing/software/juicer_CPU
