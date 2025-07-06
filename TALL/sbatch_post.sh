#!/bin/bash

gse=$1
cell=$2
tools=$3

dir=/cluster2/home/futing/Project/panCancer/TALL/${gse}/${cell}
queue="gpu"
queue_time="5780"
debugdir="${dir}/debug"
submit_job() {
	local name=$1
	local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --mem=32G
#SBATCH --cpus-per-task=10
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
scripts=/cluster2/home/futing/Project/panCancer/scripts

if [ ! -f ${dir}/cool/${cell}_1000.cool ];then 
	echo -e "...Cool files not found, skipping annotation generation.\n"
	exit 1
elif [ $tools == 'cooltools' ];then
	echo -e "...Step 3: Generating annotation files\n"
	echo -e "...3-1: Generating GC content file\n"
	jid=$(submit_job "${cell}_dots" "${scripts}/dots_single.sh ${dir}")
	echo "${cell}_dots Job ID: $jid"
else
	echo -e "...3-2: running ${tools}\n"
	jid=$(submit_job "${cell}_${tools}" "${scripts}/${tools}_single.sh ${dir}")
	echo "${cell}_${tools} Job ID: $jid"
fi 