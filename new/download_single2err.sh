#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/new"
cd $debugdir


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
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ./${name}/${name}.sra --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat "dumperr.txt");do
    source activate RNA
	echo "Processing SRR: ${name}"
	# echo $name > tmp
	prefetch -p -X 150GB ${name}

	# /cluster/home/futing/pipeline/Ascp/ascp2.sh tmp ./ 20M
	if [ -f "${name}/${name}.sra" ];then
		jid=$(submit_job "${name}")
	fi
done

