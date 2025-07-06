#!/bin/bash

# 01 移动所有文件
file=/cluster/home/futing/Project/panCancer/CRC/04CRC_anno.csv
cd /cluster/home/futing/Project/panCancer/CRC
IFS=$','
while read -r gse gsm srr cell other;do
    gse=$(echo "$gse" | tr -d '[:space:]')
    cell=$(echo "$cell" | tr -d '[:space:]')
    srr=$(echo "$srr" | tr -d '[:space:]')
	if [ ! -d ${gse}/${cell} ];then
		echo -e "...Creating directory: ${gse}/${cell}"
		echo -e "...Moving files from ${srr} to ${gse}/${cell}\n"
		mkdir -p ${gse}/${cell}
		mv ${srr}/* ${gse}/${cell}/
	else
		echo "Directory already exists: ${gse}/${cell}"
		mv ${srr}/* ${gse}/${cell}/
	fi

done < <(tail -n +2 "$file")

# find . -type d -empty -delete
# 02 ctrl 移动文件
ctrlfile=/cluster2/home/futing/Project/panCancer/CRC/meta/ctrl.txt
IFS=$'\t'
while read -r gse srr gsm cell other;do
    # gse=$(echo "$gse" | tr -d '[:space:]')
    # cell=$(echo "$cell" | tr -d '[:space:]')
    # srr=$(echo "$srr" | tr -d '[:space:]')
	if [ ! -d ${gse}/${cell}_${other} ];then
		echo -e "...Creating directory: ${gse}/${cell}_${other}"
		echo -e "...Moving files from ${srr} to ${gse}/${cell}_${other}\n"
		mkdir -p ${gse}/${cell}_${other}
		mv ${gse}/${srr}/* ${gse}/${cell}_${other}/
	else
		echo "Directory already exists: ${gse}/${cell}_${other}"
		mv ${gse}/${srr}/* ${gse}/${cell}_${other}/
	fi

done < <(grep 'Normal' "$ctrlfile")


# 03 ctrl 删除文件
IFS=$','
while read -r gse dir other;do  #other
	echo -e "rm -r ${gse}/${dir}/{cool,anno,debug,splits,aligned,HIC_tmp}"
	# rm -r ${gse}/${dir}/{cool,anno,debug,splits,aligned,HIC_tmp}

done < <(tail -n +2 "/cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_meta.txt")

