#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/TALL
# /cluster/home/futing/pipeline/Ascp/ascp2.sh ./TALL_srr.txt ./ 20M


# prefetch ./GC.txt 
# prefetch -p -X 60GB --option-file TALL_srr.txt

debugdir="/cluster2/home/futing/Project/panCancer/TALL/debug"
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
export TMPDIR="/cluster2/home/futing/Project/panCancer/TALL/debug"
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat srr_Jun22.txt);do
	echo "Processing SRR: ${name}"
	# prefetch -p -X 60GB ${name}
	echo ${name} > srr.txt
	/cluster/home/futing/pipeline/Ascp/ascp2.sh ./srr.txt ./ 20M

	if [ $? -ne 0 ]; then
		echo -e "Downloading error.\n" >&2
		continue  # 非零退出码表示错误
	fi
	jid=$(submit_job "${name}")
	echo "${name} Job ID: $jid" >> TALL_srr_jid.txt
done

