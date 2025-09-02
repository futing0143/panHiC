#!/bin/bash

# 全局变量
queue="normal"
queue_time="5780"
debugdir="/cluster/home/futing/Project/GBM/HiCQTL"
mkdir -p $debugdir

# 定义 submit_job 函数
submit_job() {
    local name=$1
    local script_path=$2
sbatch <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --cpus-per-task=20
#SBATCH --output=$debugdir/debug/$name-%j.log
#SBATCH -J "${name}"



date
sh $script_path
date
EOF
}
#SBATCH -d afterok:29629

# 提交任务
# for cell in GB176 GB180 GB182 GB183 GB238 U343 U118 SW1088 A172 U87 H4 42MGBA U251; do
# 	jid=$(submit_job "$cell" "/cluster/home/futing/Project/GBM/HiCQTL/genotype2/combineGVCF.sh $cell")
# 	echo "Job ID for $cell: $jid"
# done
jid=$(submit_job "SNP" "/cluster/home/futing/Project/GBM/HiCQTL/genotype2/SNP.sh")
echo "Job ID: $jid"

# jid=$(submit_job "GB176" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB176/splits HindIII")
# echo "Job ID: $jid"
# jid=$(submit_job "GB180" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB180/splits HindIII")
# echo "Job ID: $jid"
# jid=$(submit_job "GB182" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB182/splits HindIII")
# echo "Job ID: $jid"
# jid=$(submit_job "GB183" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB183/splits HindIII")
# echo "Job ID: $jid"
# jid=$(submit_job "GB238" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/GB238/splits HindIII")
# echo "Job ID: $jid"


# jid=$(submit_job "U343" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U343/splits MobI")
# echo "Job ID: $jid"
# jid=$(submit_job "U118" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U118/splits MobI")
# echo "Job ID: $jid"
# jid=$(submit_job "SW1088" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/SW1088/splits MobI")
# echo "Job ID: $jid"
# jid=$(submit_job "A172" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/A172/splits MobI")
# echo "Job ID: $jid"
# jid=$(submit_job "U87" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_jialu.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U87/splits MboI")
# echo "U87 Job ID: $jid"

# jid=$(submit_job "H4" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_myfa.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/H4/splits Arima")
# echo "H4Job ID: $jid"
# jid=$(submit_job "42MGBA" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_myfa.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/42MGBA/splits Arima")
# echo "42MGBA Job ID: $jid"
# jid=$(submit_job "U251" "/cluster/home/futing/Project/GBM/HiCQTL/genotype/hicQTL_single_myfa.sh /cluster/home/futing/Project/GBM/HiC/02data/01fastq/GBM/U251/splits DpnII")
# echo "Job ID: $jid"

# jid=$(submit_job "GATKpre" "/cluster/home/futing/Project/GBM/HiCQTL/preGATK.sh")
# echo "Job ID: $jid"