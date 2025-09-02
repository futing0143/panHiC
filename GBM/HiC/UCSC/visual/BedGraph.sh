#!/bin/bash

name=$1
info=$2
input=$3
reso=$4
mkdir -p /cluster/home/futing/Project/GBM/HiC/UCSC/${name}
output=/cluster/home/futing/Project/GBM/HiC/UCSC/${name}/${name}_${info}_${reso}.bedGraph

#echo "track type=bed name=\"${name}_${info}\" description=\"${name}_${info}\" visibility=2" > $output
if [[ $info == "insulation" ]];then
    echo "#chrom  chromStart  chromEnd  IS" > $output
    cat ${input} | awk 'BEGIN{FS=OFS="\t"}NR>1{print $1, $2, $3, $6}' >> $output
elif [[ $info == "boundary" ]];then
    echo "#chrom  chromStart  chromEnd  boundary" > $output
    cat ${input} | awk 'BEGIN{FS=OFS="\t"}NR>1{print $1, $2, $3, $8}' >> $output
elif [[ $info == "compartment" ]];then
    echo "#chrom  chromStart  chromEnd  compartment" > $output
    cat ${input} | awk 'BEGIN{FS=OFS="\t"} NR>1 {for(i=1;i<=NF;i++) if($i=="") $i="nan"; print $1, $2, $3, $5}' >> $output
else
    echo "No such info: ${info}"
    exit 1
fi

# sh /cluster/home/futing/Project/GBM/HiC/09insulation/ucsc.sh A172 insulation \
#     /cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result/A172_insul.tsv
# sh /cluster/home/futing/Project/GBM/HiC/09insulation/ucsc.sh A172 boundary \
#     /cluster/home/futing/Project/GBM/HiC/09insulation/50k_800k/result/A172_insul.tsv
# sh /cluster/home/futing/Project/GBM/HiC/09insulation/ucsc.sh A172 compartment \
#     /cluster/home/futing/Project/GBM/HiC/06compartment/cooltools/100k/A172_cis_100k.cis.vecs.tsv

bedGraphToBigWig "$output" /cluster/home/futing/ref_genome/hg38.genome "${output%.bedGraph}.bw"