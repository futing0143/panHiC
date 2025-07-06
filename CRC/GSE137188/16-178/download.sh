#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE137188/16-178
source activate RNA
# /cluster/home/futing/pipeline/Ascp/ascp2.sh srr.txt ./ 20M
prefetch -p -X 60G SRR10093272
debugdir="/cluster2/home/futing/Project/panCancer/CRC/GSE137188/16-178/debug"
mkdir -p "$debugdir"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p normal
#SBATCH -t "5780"
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/${name}_dump-%j.log
#SBATCH -J "${name}_dump"



date
source activate RNA
export TMPDIR=$debugdir
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

if [ -s ./SRR10093272/SRR10093272.sra ];then
	submit_job "SRR10093272"
fi