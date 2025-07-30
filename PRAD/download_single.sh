#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/PRAD"
cd $debugdir


mkdir -p "${debugdir}/debug"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
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

for name in $(cat "./meta/undone.txt");do
    source activate RNA
	echo "Processing SRR: ${name}"
	echo $name > tmp
	/cluster/home/futing/pipeline/Ascp/ascp.sh tmp ./ 20M
	# if [ -s ${name} ];then
	# # prefetch -p -X 60GB ${name}
	# 	jid=$(submit_job "${name}")
	# fi
done

