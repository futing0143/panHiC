#!/bin/bash

readonly WKDIR="/cluster2/home/futing/Project/panCancer/"
cd "${WKDIR}" || exit 1

submit_job() {
local name=$1
local file=$2

# 定义并行执行函数
sbatch --export=ALL,file="$file",name="$name" \
	-J "${name}" \
	--output="/cluster2/home/futing/Project/panCancer/Analysis/SV/${name}-%j.log" <<- 'EOF' | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p gpu
#SBATCH --nodelist=node3
#SBATCH --cpus-per-task=15
ulimit -s unlimited
ulimit -l unlimited

date
source /cluster2/home/futing/miniforge3/etc/profile.d/conda.sh
conda activate neoloop

if [ ! -f "${file}" ]; then
	echo "Input file ${file} not found!"
	exit 1
fi
IFS=$'\t'
while read -r cancer gse cell; do
	date
	echo -e "Processing ${cell} in ${cancer}/${gse}...\n"
	sh "/cluster2/home/futing/Project/panCancer/scripts/SV_single.sh" \
		"${cancer}" "${gse}" "${cell}" > "/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/debug/${cell}_SV.log" 2>&1
done < "$file"

date
EOF
}

jid_1=$(submit_job "PC1" "/cluster2/home/futing/Project/panCancer/check/hic/mcool1018p1.txt")
jid_2=$(submit_job "PC2" "/cluster2/home/futing/Project/panCancer/check/hic/mcool1018p2.txt")
jid_3=$(submit_job "PC3" "${WKDIR}/check/hic/mcool1018p3.txt")
jid_4=$(submit_job "PC4" "${WKDIR}/check/hic/mcool1018p4.txt")
echo "Submitted SV jobs with IDs: $jid_1, $jid_2, $jid_3, $jid_4"