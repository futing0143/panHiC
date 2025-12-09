#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616
# /cluster/home/futing/pipeline/Ascp/ascp2.sh /cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_re.txt ./ctrl 20M
# prefetch -p -X 60GB --option-file /cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_re.txt

debugdir="/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616/debug"
mkdir -p "$debugdir"
submit_job() {
    local name=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -t "5780"
#SBATCH --cpus-per-task=10
#SBATCH --output=$debugdir/${name}_dump-%j.log
#SBATCH -J "${name}_dump"



date
source activate RNA
cd ${debugdir}
echo -e "parallel-fastq-dump --sra-id ${name} --threads 40 --outdir ./ --split-3 --gzip"
parallel-fastq-dump --sra-id ../${name} --threads 40 --outdir ./ --split-3 --gzip
date
EOF
}

for name in $(cat "srr.txt");do
    source activate RNA
	echo "Processing SRR: ${name}"
	# echo $name > tmpp2
	# prefetch -p -X 60GB ${name}
	# /cluster2/home/futing/pipeline/Ascp/ascp2.sh srr.txt ./ 40M
	if [ -s ${name} ];then
	# prefetch -p -X 60GB ${name}
		jid=$(submit_job "${name}")
		# echo $jid >> dumpnum.txt
	fi
done

submit_juicerjob() {
    local jobid=$1
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH --cpus-per-task=15
#SBATCH --nodelist=node4
#SBATCH --output=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616/debug/CRC26616-%j.log
#SBATCH --dependency=afterok:${jobid}
#SBATCH -J "CRC26616"
ulimit -s unlimited
ulimit -l unlimited

date
cd /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616
mv ./debug/SRR20082373_1.fastq.gz ./fastq/SRR20082373_R1.fastq.gz
mv ./debug/SRR20082373_2.fastq.gz ./fastq/SRR20082373_R2.fastq.gz

sh /cluster2/home/futing/Project/panCancer/scripts/juicerv1.3.sh -d /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616 -e mHiC -s "juicer"
date
EOF
}
submit_juicerjob ${jid}