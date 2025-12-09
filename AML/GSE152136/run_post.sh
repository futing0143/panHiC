#!/bin/bash

dir=$1
cell=$(basename ${dir})
resolutions=(10000 100000 250000 500000 1000000)

cd $dir
source activate ~/miniforge3/envs/juicer
echo "---- Processing ${cell} in ${dir}..."
# for resolution in "${resolutions[@]}"; do
# 	echo "Processing resolution $resolution..."
# 	sh /cluster2/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
# 		"$resolution" ./cool/${cell}.mcool ./cool
# done

# cooler coarsen -k 5 -p 8 ./cool/${cell}_10000.cool -o ./cool/${cell}_50000.cool 
# cooler balance ./cool/${cell}_50000.cool

queue="gpu"
queue_time="5780"
debugdir="${dir}/debug"

submit_job() {
local name=$1
local script_path=$2
local dependency=$3

local dep_opt=()
if [ -n "$dependency" ]; then
	dep_opt=(--dependency=afterok:$dependency)
fi

    sbatch "${dep_opt[@]}" <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"

date
sh $script_path
date
EOF
}
scripts=/cluster2/home/futing/Project/panCancer/scripts


echo -e "...Step 3: Generating annotation files\n"
        
# 第一个任务没有依赖
# echo -e "...3-1: Generating GC content file\n"
# jid_PC=$(submit_job "${cell}_PC" "${scripts}/PC_single.sh ${dir}")
# echo "${cell}_PC Job ID: $jid_PC"

# OnTAD 和 insul 依赖 PC 任务
# echo -e "...3-2: running OnTAD\n"
jid_OnTAD=$(submit_job "${cell}_OnTAD" "${scripts}/OnTAD_single.sh ${dir} 50000")
echo "${cell}_OnTAD Job ID: $jid_OnTAD"

jid_insul=$(submit_job "${cell}_insul" "${scripts}/insul_single.sh ${dir} 50000")
echo "${cell}_insul Job ID: $jid_insul"

# stripenn 和 stripecaller 依赖 OnTAD 和 insul 都完成
echo -e "...3-3: running stripe\n"
jid_stripenn=$(submit_job "${cell}_stripenn" "${scripts}/stripenn_single.sh ${dir}" "$jid_OnTAD,$jid_insul")
echo "${cell}_stripenn Job ID: $jid_stripenn"

jid_stripecaller=$(submit_job "${cell}_stripecaller" "${scripts}/stripecaller_single.sh ${dir} 50000" "$jid_OnTAD,$jid_insul")
echo "${cell}_stripecaller Job ID: $jid_stripecaller"

# # 后续任务依赖 stripe 任务完成
# echo -e "...3-4: running loops\n"

# jid_dots2=$(submit_job "${cell}_dots" "${scripts}/dots_single.sh ${dir} 10000" "$jid_stripenn,$jid_stripecaller")
# echo "${cell}_dots Job ID: $jid_dots2"

# jid_peakachu=$(submit_job "${cell}_peakachu" "${scripts}/peakachu_single.sh ${dir} 10000" "$jid_dots2")
# echo "${cell}_peakachu Job ID: $jid_peakachu"

# jid_mustache=$(submit_job "${cell}_mustache" "${scripts}/mustache_single.sh ${dir} 10000" "$jid_dots2")
# echo "${cell}_mustache Job ID: $jid_mustache"

# jid_fithic=$(submit_job "${cell}_fithic" "${scripts}/fithic_single.sh ${dir} 10000" "$jid_dots2")
# echo "${cell}_fithic Job ID: $jid_fithic"
