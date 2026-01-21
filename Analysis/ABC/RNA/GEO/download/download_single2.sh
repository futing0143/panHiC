#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download"
cd $debugdir

source activate ~/miniforge3/envs/RNA

mkdir -p "${debugdir}/debug"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=10
#SBATCH --output=$debugdir/debug/${name}_pair-%j.log
#SBATCH -J "${name}_pair"



date
source activate RNA
cd $debugdir
export TMPDIR=${debugdir}/debug
echo -e "parallel-fastq-dump --sra-id ${name}/${name}.sra --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ./${name}/${name}.sra --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

# for name in $(cat "/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download/srr_undonep2p2.txt");do
# for name in SRR9071976 SRR9071977;do
# while read name; do
    # source activate RNA
	name=SRR15598715
	echo "Processing SRR: ${name}"
	echo $name > tmp
	prefetch -p -X 150GB ${name}

	# /cluster2/home/futing/pipeline/Ascp/ascp2.sh tmp ./ 20M
	if [ -f "${name}/${name}.sra" ];then
		jid=$(submit_job "${name}")
	fi
# done < "dumperr0117nig.txt"

