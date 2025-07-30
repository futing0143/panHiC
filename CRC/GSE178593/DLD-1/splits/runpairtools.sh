#!/bin/bash



source activate HiC
FileName=SRR14872103
genomesize=/cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome
cd /cluster2/home/futing/Project/panCancer/CRC/GSE178593/DLD-1/splits/
# samtools view -bhS -@ 16 -o SRR14872103.fastq.gz.bam SRR14872103.fastq.gz.sam

# pairtools parse SRR14872103.fastq.gz.sam -c ${genomesize} \
# 	--drop-sam --drop-seq --output-stats SRR14872103.stats \
# 	--no-flip \
# 	--add-columns mapq \
# 	--walks-policy all \
# 	-o SRR14872103.pairs.gz
#QC select
pairtools select '(pair_type == "UU") or (pair_type == "UR") or (pair_type == "RU")' ${FileName}.pairs.gz -o ${FileName}.filted.pairs.gz
#Sort pairs
pairtools sort --nproc 10 ${FileName}.filted.pairs.gz -o ${FileName}.sorted.pairs.gz

pairtools dedup \
    --max-mismatch 3 \
    --mark-dups \
    --output >( pairtools split --output-pairs ${FileName}.nodups.pairs.gz --output-sam ${FileName}.nodups.bam ) \
    --output-unmapped >( pairtools split --output-pairs ${FileName}.unmapped.pairs.gz --output-sam ${FileName}.unmapped.bam ) \
    --output-dups >( pairtools split --output-pairs ${FileName}.dups.pairs.gz --output-sam ${FileName}.dups.bam ) \
    --output-stats ${FileName}.dedup.stats \
    ${FileName}.sorted.pairs.gz
