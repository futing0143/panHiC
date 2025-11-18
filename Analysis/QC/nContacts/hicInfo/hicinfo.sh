#!/bin/bash

d=$1
resolutions=(5000 10000 25000 50000 100000 250000 500000 1000000)
wkdir=/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo
cd ${wkdir}
scripts=${wkdir}/hicInfo.py
source activate /cluster2/home/futing/miniforge3/envs/juicer

# find /cluster2/home/futing/Project/panCancer -name '*_50000.cool' | while read file;do

while IFS=$'\t' read -r cancer gse cell ncell;do
	file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/cool/${cell}_50000.cool"
	echo -e "Processing $cell $gse and $cancer.."
	hicInfo -m $file >> hicInfo_${d}.log

done < <(grep '\.cool' /cluster2/home/futing/Project/panCancer/check/post/hicdone${d}.txt)
python $scripts hicInfo_${d}.log hicInfo_${d}.txt "."


bash meta.sh ${d}
# 生成唯一cell名称
# 见 meta.sh

# 旧的处理方法
# echo -e "cancer\tgse\tcell\tncell" > hicInfo_${d}.txt.tmp
# awk -F',' 'BEGIN{FS=OFS="\t"}NR>1{
#     count[$3]++
#     if (count[$3]==1) {
#         uniq=$3
#     } else {
#         uniq=$3"_"count[$3]
#     }
#     print $0,uniq
# }' hicInfo_${d}.txt >> hicInfo_${d}.txt.tmp && mv hicInfo_${d}.txt.tmp hicInfo_${d}.txt

# sed -i 's/,//g' hicInfo_${d}.txt