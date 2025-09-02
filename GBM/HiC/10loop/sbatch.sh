#!/bin/bash

# sbatch history
# 全局变量
queue="normal"
queue_time="5760"
debugdir="/cluster/home/futing/Project/GBM/HiC/10loop"
name="GBM"

# 定义 submit_job 函数
submit_job() {
local tool_name=$1
local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/$tool_name/debug/$name-%j.log
#SBATCH -J "${name}_${tool_name}"

date
sh $script_path
date
EOF
}

# 提交任务
# jid=$(submit_job "peakachu" "/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu_single.sh 10000 $name")
# echo "Peakachu Job ID: $jid"

# jid=$(submit_job "mustache" "/cluster/home/futing/Project/GBM/HiC/10loop/mustache/mustache_single.sh 1000 $name")
# echo "Mustache Job ID: $jid"

# jid=$(submit_job "cooltools" "/cluster/home/futing/Project/GBM/HiC/10loop/cooltools/dots_single.sh 1000 ${name}")
# echo "Cooltools Job ID: $jid"

jid=$(submit_job "fithic" "/cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 1000 ${name}" no 0.2)
echo "Fithic Job ID: $jid"

# jid=$(submit_job "fithic" "/cluster/home/futing/Project/GBM/HiC/10loop/fithic/scripts/fithic_single.sh 5000 ${name} no 0.2 ")
# echo "Fithic Job ID: $jid"




# # homer 10kb
# cat /cluster/home/futing/Project/GBM/HiC/10loop/homer/scripts/name1.txt | while read name;do
#     jid=$(submit_job "homer" "/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh 10000 ${name} ")
#     echo "Fithic Job ID of ${name}: $jid"
# done

# cat /cluster/home/futing/Project/GBM/HiC/10loop/homer/scripts/name2.txt | while read name;do
#     jid=$(submit_job "homer" "/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh 10000 ${name} yes")
#     echo "Fithic Job ID of ${name}: $jid"
# done

# jid=$(submit_job "homer" "/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh 5000 ${name}")
# echo "Fithic Job ID: $jid"

# cat /cluster/home/futing/Project/GBM/HiC/10loop/homer/scripts/undone.txt | while read name;do
#     jid=$(submit_job "homer" "/cluster/home/futing/Project/GBM/HiC/10loop/homer/homer_single.sh 10000 ${name} ")
#     echo "Homer Job ID of ${name}: $jid"
# done