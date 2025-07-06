#!/bin/bash


cd /cluster2/home/futing/Project/panCancer/CML
IFS=$','
while read -r gse srr cell enzyme;do
    gse=$(echo "$gse" | tr -d '[:space:]')
    cell=$(echo "$cell" | tr -d '[:space:]')
    srr=$(echo "$srr" | tr -d '[:space:]')
	if [ ! -d ${gse}/${cell} ];then
		echo -e "...Creating directory: ${gse}/${cell}"
		echo -e "...Moving files from ${srr} to ${gse}/${cell}\n"
		mkdir -p ${gse}/${cell}
		mv ${cell}/${srr}/* ${gse}/${cell}/
	else
		echo "Directory already exists: ${gse}/${cell}"
		mv ${cell}/${srr}/* ${gse}/${cell}/
	fi

done < "/cluster2/home/futing/Project/panCancer/CML/CML_meta.txt"




