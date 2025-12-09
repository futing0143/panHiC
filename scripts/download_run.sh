#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/OV

dir="/cluster2/home/futing/Project/panCancer/OV/GSE229408"
submit_job() {
    local name=$1
	local cell=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH --cpus-per-task=10
#SBATCH --output=${dir}/${cell}/debug/${name}_dump-%j.log
#SBATCH -J "${name}_dump"



date
source activate ~/miniforge3/envs/RNA
cd ${dir}/${cell}/
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}
submit_juicerjob() {
    local jobid=$1
	local srr=$2
	local cell=$3
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --output=${dir}/${cell}/debug/${cell}-%j.log
#SBATCH --dependency=afterok:${jobid}
#SBATCH --distribution=cyclic
#SBATCH -J ${cell}
ulimit -s unlimited
ulimit -l unlimited

date
cd ${dir}/${cell}

sh /cluster2/home/futing/Project/panCancer/scripts/juicerv1.3.sh -d ${dir}/${cell} -e Arima
date
EOF
}
IFS=$'\t'
while read -r gse cell srr other;do
	echo "Processing SRR: ${srr}"
	mkdir -p ${dir}/${cell}/debug
	cd ${dir}/${cell}
	echo $srr > srr.txt

	prefetch -p -X 160GB ${srr}
	# /cluster2/home/futing/pipeline/Ascp/ascp2.sh srr.txt ./ 40M
	if [ -s ${srr} ];then
		jid=$(submit_job "${srr}" "${cell}")
		submit_juicerjob ${jid} ${srr} ${cell}
	fi
done < "/cluster2/home/futing/Project/panCancer/check/meta/manual/OV_meta.txt"

