#!/bin/bash

# 全局变量
queue="normal"
queue_time="2880"
debugdir="/cluster/home/futing/Project/GBM/HiC/08TAD/"


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

for name in OPC;do
    jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000")
    echo "OnTAD Job ID of ${name}: $jid"
    jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 10000")
    echo "OnTAD Job ID of ${name}: $jid"
done

# for name in GBM;do
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000")
#     echo "OnTAD Job ID of ${name}: $jid"
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 10000")
#     echo "OnTAD Job ID of ${name}: $jid"
# done

# for name in A172_2 astro1 astro2;do
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000")
#     echo "OnTAD Job ID of ${name}: $jid"
# done

# G351
# cat /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/name_GBMp2.txt | while read name;do
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000 1")
#     echo "OnTAD Job ID of ${name}: $jid"
# done

# cat /cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/name_ctrl.txt | while read name;do
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000 1")
#     echo "OnTAD Job ID of ${name}: $jid"
# done

# cat /cluster/home/futing/Project/GBM/HiC/02data/01fastq/EGA/name.txt | while read name;do
#     jid=$(submit_job "OnTAD" "/cluster/home/futing/Project/GBM/HiC/08TAD/OnTAD/OnTAD_single.sh ${name} 50000 1")
#     echo "OnTAD Job ID of ${name}: $jid"
# done