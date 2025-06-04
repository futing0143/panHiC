#!/bin/bash

enzyme=$1
dir=$2
post=${3:-}
cell=$(awk -F '/' '{print $NF}' <<< ${dir})

time
cd $dir
rm -r ./cool ./anno
mkdir -p ./{fastq,cool,anno}
rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
rename .R1 _R1 *fastq.gz
rename .R2 _R2 *fastq.gz  

mv *.fastq.gz ./fastq
source activate juicer

# ------ Step 1: Run Juicer ------
if [ -n "$post" ]; then  # 如果 post 非空（等同于 ! -z）
    echo -e "...Post-processing is enabled, skipping Juicer step.\n"
else
	echo -e "...Step 1: Running Juicer of ${cell} with enzyme ${enzyme} in directory ${dir}\n"
	/cluster/home/futing/software/juicer_CPU/scripts/juicer.sh \
		-D /cluster/home/futing/software/juicer_CPU/ \
		-d ${dir} -g hg38 -t 20 \
		-p /cluster/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
		-z /cluster/home/futing/software/juicer_CPU/references/hg38.fa -s ${enzyme}

	# ------ Step 2: Convert HiC to cool files ------
	echo -e "...Step 2: Converting HiC to cool files\n"
	source activate HiC
	hicConvertFormat -m ./aligned/inter_30.hic \
		--inputFormat hic --outputFormat cool \
		-o ./cool/${cell}.mcool

	resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
	for resolution in "${resolutions[@]}";do
		cooler balance ./cool/${cell}.mcool::resolutions/${resolution}
	done

	for resolution in ${resolutions[@]};do
		/cluster/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
		${resolution} ./cool/${cell}.mcool ./cool
	done
fi

# ------ Step 3: Generate annotation files ------
# loop
if [ -z $post ];then
	echo -e "...Post-processing is not enabled, skipping annotation generation.\n"
	exit 1
fi

# define sbatch parameters
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
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
script=/cluster/home/futing/Project/panCancer/scripts

if [ ! -f ${dir}/cool/${cell}_1000.cool ];then 
	echo -e "...Cool files not found, skipping annotation generation.\n"
	exit 1
else
	echo -e "...Step 3: Generating annotation files\n"
	echo -e "...3-1: Generating GC content file\n"
	jid=$(submit_job "${cell}_PC" "${scripts}/PC_single.sh ${dir}")
	echo "${cell}_PC Job ID: $jid"

	echo -e "...3-2: running OnTAD\n"
	jid=$(submit_job "${cell}_OnTAD" "${scripts}/OnTAD_single.sh ${dir} 50000")
	echo "${cell}_OnTAD Job ID: $jid"

	echo -e "...3-3: running stripe\n"
	jid=$(submit_job "${cell}_stripenn" "${scripts}/stripecaller.sh ${dir}")
	echo "${cell}_stripenn Job ID: $jid"
	jid=$(submit_job "${cell}_stripecaller" "${scripts}/OnTAD_single.sh ${dir} 50000")
	echo "${cell}_stripecaller Job ID: $jid"

	echo -e "...3-3: running loops\n"
	jid=$(submit_job "${cell}_dots" "${scripts}/dots_single.sh ${dir}")
	echo "${cell}_dots Job ID: $jid"
	jid=$(submit_job "${cell}_peakachu" "${scripts}/peakachu_single.sh ${dir}")
	echo "${cell}_peakachu Job ID: $jid"
	jid=$(submit_job "${cell}_mustache" "${scripts}/mustache_single.sh ${dir}")
	echo "${cell}_mustache Job ID: $jid"
	jid=$(submit_job "${cell}_fithic" "${scripts}/fithic_single.sh ${dir}")
	echo "${cell}_fithic Job ID: $jid"

fi