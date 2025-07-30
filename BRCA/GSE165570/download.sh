#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/BRCA/GSE165570
# /cluster/home/futing/pipeline/Ascp/ascp2.sh ./TALL_srr.txt ./ 20M


# prefetch ./GC.txt 
# prefetch -p -X 60GB --option-file TALL_srr.txt

debugdir="/cluster2/home/futing/Project/panCancer/BRCA/GSE165570/debug"
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
export TMPDIR="/cluster2/home/futing/Project/panCancer/BRCA/GSE165570/debug"
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat srr.txt);do
	echo "Processing SRR: ${name}"
	# prefetch -p -X 60GB ${name}
	echo ${name} > srr1.txt
	/cluster/home/futing/pipeline/Ascp/ascp2.sh ./srr1.txt ./ 20M
	if [ -f ${name} ];then
		jid=$(submit_job "${name}")
	fi
done

