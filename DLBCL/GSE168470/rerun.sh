#!/bin/bash


cell=$1
dir=/cluster2/home/futing/Project/panCancer/DLBCL/GSE168470/${cell}

cd ${dir}
ls ${dir}/fastq/*_R2.fastq.gz | xargs -I {} basename {} _R2.fastq.gz > ${dir}/srr.txt

cat ${dir}/srr.txt | while read -r srr;do
	echo "Converting bam 2 sam of ${srr}..."
	samtools view -h -@ 20 -o ${dir}/splits/${srr}.fastq.gz.sam ${dir}/splits/${srr}.fastq.gz.bam
done

mv ${dir}/aligned ${dir}/aligned_Arima
sh /cluster2/home/futing/Project/panCancer/DLBCL/sbatch.sh GSE168470 ${cell} MboI
