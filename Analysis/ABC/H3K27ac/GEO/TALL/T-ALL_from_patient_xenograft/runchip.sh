#!/bin/bash
#SBATCH -p normal
#SBATCH --cpus-per-task=15
#SBATCH --output=/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/TALL/T-ALL_from_patient_xenograft/debug/Tpatient_chip-%j.log
#SBATCH -J "Tpatient"

cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/TALL/T-ALL_from_patient_xenograft
while read srr; do
    cat ${srr}.fastq.gz >> input.fastq.gz
done < "None.txt"
while read srr; do
    cat ${srr}.fastq.gz >> H3K27ac.fastq.gz
done < "H3K27ac.txt"


echo -e "input\nH3K27ac" > input.txt
if [ -s input.fastq.gz ] && [ -s H3K27ac.fastq.gz ];then
	bash /cluster2/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite_single.sh \
	"" 20 input "" "" input.txt
fi