#!/bin/bash

source /cluster/home/chenglong/.bashrc
source activate /cluster/home/chenglong/miniconda3/envs/tag2rose

protein_type=${1:-normal}
thread=${2:-50}
IgG_flag=${3:-no}
rose_flag=${4:-no}
retain_temp_file_flag=${5:-no}

#necessary file index
indexpath="/cluster/share/ref_genome/hg38/index/bowtie2/hg38"
chromosize="/cluster/share/ref_genome/hg38/assembly/hg38.chrom.sizes"
TSS_BED="/cluster/home/chenglong/reference/pcg_gene_tss_v38.bed"
main_chr_list_path="/cluster/home/chenglong/reference/chr_22XY.txt"
homer_hg38_ref="/cluster/home/chenglong/homer/data/genomes/hg38"
# build rose annotation soft link
ln -s /cluster/home/chenglong/ROSE-master/annotation annotation
wd=`pwd`
wd_name=`basename ${wd}`

mkdir -p ./SRR8085199/macs ./SRR8085200/macs

for i in SRR8085199 SRR8085200;do
macs2 callpeak -t ./${i}/bam_files/${i}_final.bam \
    -c ./SRR8085198/bam_files/input.rmdup_sorted.bam \
    -g hs -f BAM -n ${i} --outdir ./${i}/macs2 -q 0.05
ls ./{i}/macs/${i}_peaks.*Peak | grep -v gapped | xargs -i cp {} ./${i}/macs/${i}_macs2peak.bed
done

#rename

