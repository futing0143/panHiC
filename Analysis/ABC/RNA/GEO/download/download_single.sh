#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download"
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
parallel-fastq-dump --sra-id ./${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat "/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/GSE_metadata0104_srrp1.txt");do
    source activate RNA
	echo "Processing SRR: ${name}"
	echo $name > tmp1
	# prefetch -p -X 150GB ${name}

	/cluster2/home/futing/pipeline/Ascp/ascp2.sh tmp1 ./ 20M
	if [ -f "${name}" ];then
		jid=$(submit_job "${name}")
	fi
done

