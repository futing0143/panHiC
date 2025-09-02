#!/bin/bash
datadir=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order
cd /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/scripts/reso
source /cluster/home/futing/miniforge-pypy3/etc/profile.d/conda.sh
conda activate dchic
# python /cluster/home/futing/software/dcHiC-master/utility/preprocess.py -input cool \
#     -file ${datadir}/5000/GBM_5000.cool \
#     -genomeFile /cluster/home/futing/ref_genome/hg38.genome \
#     -res 5000 -prefix GBM
# valid_bin=`awk 'BEGIN{PROCINFO["sorted_in"] = "@ind_num_asc"}{fline[$1]+=$3;sline[$2]+=$3}END{for(i in fline)print fline[i]+sline[i]}' GBM_5000.matrix | awk '$1>1000{valid++}END{print valid}'`
# total_bin=`wc -l  GBM_5000_abs.bed |cut -d " " -f 1`
# awk -v valid_bin=$valid_bin -v total_bin=$total_bin 'BEGIN{print "'GBM'",valid_bin/total_bin}'

coolfile=/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/GBM_1000.cool
python /cluster/home/futing/software/dcHiC-master/utility/preprocess.py -input cool \
    -file $coolfile \
    -genomeFile /cluster/home/futing/ref_genome/hg38.genome \
    -res 1000 -prefix GBM
valid_bin=`awk 'BEGIN{PROCINFO["sorted_in"] = "@ind_num_asc"}{fline[$1]+=$3;sline[$2]+=$3}END{for(i in fline)print fline[i]+sline[i]}' GBM_1000.matrix | awk '$1>1000{valid++}END{print valid}'`
total_bin=`wc -l  GBM_1000_abs.bed |cut -d " " -f 1`
awk -v valid_bin=$valid_bin -v total_bin=$total_bin 'BEGIN{print "'GBM_1000'",valid_bin/total_bin}'