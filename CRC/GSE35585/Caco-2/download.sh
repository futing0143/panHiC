#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE35585/Caco-2
# /cluster/home/futing/pipeline/Ascp/ascp2.sh /cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_re.txt ./ctrl 20M
# prefetch -p -X 60GB --option-file /cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_re.txt

debugdir="/cluster2/home/futing/Project/panCancer/CRC/GSE35585/Caco-2"
mkdir -p "$debugdir"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/${name}_dump-%j.log
#SBATCH -J "${name}_dump"



date
source activate RNA
cd ${debugdir}
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat "srr.txt");do
    source activate RNA
	echo "Processing SRR: ${name}"
	# echo $name > tmpp2
	prefetch -p -X 60GB ${name}
	# /cluster/home/futing/pipeline/Ascp/ascp2.sh tmpp2 ./ 20M
	if [ -s ${name} ];then
	# prefetch -p -X 60GB ${name}
		jid=$(submit_job "${name}")
		echo $jid >> dumpnum.txt
	fi
done

