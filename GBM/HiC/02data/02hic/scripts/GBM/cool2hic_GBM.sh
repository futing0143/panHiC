#!/bin/bash
chrom_sizes=/cluster/home/futing/ref_genome/hg38.chrom.sizes
juicer_tools_jar=/cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar
name=GBM
mcool_file=/cluster/home/futing/Project/GBM/HiC/02data/03cool/5000/GBM_5000.cool
cd /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM

# 01 try1 log不见了
sh /cluster/home/futing/Project/GBM/HiC/02data/05file_transform/mcool2hic.sh ${mcool_file} 5000

# 02 try2 pre > addnorm有问题
source activate ~/anaconda3/envs/juicer
java -Xmx200G -jar /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar pre \
    -j 40 --threads 80 -r 5000,10000,25000 -d /cluster/home/futing/Project/GBM/HiC/02data/02hic/GBM/GBM_5000.5000.bedpe.short.sorted \
    ./${name}.hic /cluster/home/futing/ref_genome/hg38.chrom.sizes

# 03 try3 addNorm > norm_hiccups.log norm_hiccups_re.log
source activate ~/miniforge-pypy3/envs/juicer
java -Xmx300G -jar ${juicer_tools_jar} AddNorm -j 40 ./GBM.hic
sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    -g hg38 -i ./GBM.hic

# 04 try3 hiccups > hiccups_re.log
sh /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_hiccups.sh \
    -j /cluster/home/futing/software/juicer_CPU/scripts/common/juicer_tools.jar \
    -g hg38 -i ./GBM.hic

date
#/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/GBM/42MGBA/cool2hic_GSC.log


# 05 try5 hiccups > hiccups_re2.log
export PATH=/cluster/apps/cuda/11.7/bin:$PATH
export LD_LIBRARY_PATH=/cluster/apps/cuda/11.7/lib64:$LD_LIBRARY_PATH
java -jar ${juicer_tools_jar} hiccups ${name}.hic ${name}"_loops_re"
#java -jar ${juicer_tools_jar} apa ${name}.hic ${name}"_loops" "apa_results"