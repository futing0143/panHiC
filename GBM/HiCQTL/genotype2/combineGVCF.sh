#!/bin/bash


name=$1
cd /cluster/home/futing/Project/GBM/HiCQTL/genotype2/${name}
declare -A valid_options=(
    ["U251"]=1
    ["H4"]=1
    ["42MGBA"]=1
)
if [[ -n "${valid_options[$name]}" ]]; then
    reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/bwa/hg38.fa
else
    reference=/cluster/home/futing/ref_genome/hg38_primary_assembly/jialu/hg38.fa
fi

threads=$(find . -name 'raw_*.vcf' | wc -l)
arg=$(seq 1 $threads | parallel --will-cite -k "printf -- \" -V %s\" raw_{}.vcf")
# gatk --java-options "-Xmx4G" GatherVcfs -R $reference $arg -O raw.vcf
gatk --java-options "-Xmx4G" CombineGVCFs -R $reference $arg -O raw.vcf
[ $? -eq 0 ] || { echo ":( Failed at GATK GatherVcfs. See err stream for more info. Exiting!" | tee -a /dev/stderr && exit 1; }

# cleanup
seq 1 $threads | parallel --will-cite "rm raw_{}.vcf raw_{}.vcf.idx"