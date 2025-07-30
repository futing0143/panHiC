#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/GC"
cd $debugdir


mkdir -p "${debugdir}/debug"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p normal
#SBATCH -t "5780"
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/debug/${name}_dump-%j.log
#SBATCH -J "${name}_dump"



date
source activate RNA
cd $debugdir
export TMPDIR=${debugdir}/debug
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

cat dump.txt | while read -r name;do
	submit_job ${name}
done

find /cluster2/home/futing/Project/panCancer/GC -maxdepth 1 -name '*_2.fastq.gz' -exec basename {} _2.fastq.gz \; > dumpdone1.txt


