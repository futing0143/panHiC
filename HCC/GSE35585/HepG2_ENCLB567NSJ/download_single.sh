#!/bin/bash

debugdir="/cluster2/home/futing/Project/panCancer/HCC/GSE35585/HepG2_ENCLB567NSJ"
cd $debugdir


mkdir -p "${debugdir}/debug"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=10
#SBATCH --nodelist=node2
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

for name in $(cat "srr.txt");do
	echo "Processing SRR: ${name}"
	echo $name > tmp
	prefetch -p -X 120GB ${name}
	# /cluster2/home/futing/pipeline/Ascp/ascp2.sh tmp ./ 20M
	if [ -s ${name}/${name}.sra ];then
	# 
		jid=$(submit_job "${name}")
	fi
done

