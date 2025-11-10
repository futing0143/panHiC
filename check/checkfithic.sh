#!/bin/bash


metafile=/cluster2/home/futing/Project/panCancer/check/aligned/aligndone1027.txt
outputfile=/cluster2/home/futing/Project/panCancer/check/unpost/fithic_1027.txt
>$outputfile

IFS=$'\t'
while read -r cancer gse cell; do
	echo "Checking ${cancer} - ${gse} - ${cell}"
    for reso in 10000 5000; do
        file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/anno/fithic/${reso}/fragmentLists/frags_${reso}.gz"
        
        if [[ ! -f "$file" ]] || [[ $(zcat "$file" 2>/dev/null | wc -l) -eq 0 ]]; then
            echo -e "${cancer}\t${gse}\t${cell}\t${reso}" >> "$outputfile"
        fi
    done
done < "$metafile"
IFS=$'\t'
while read -r cancer gse cell reso;do
	file="/cluster2/home/futing/Project/panCancer/${cancer}/${gse}/${cell}/anno/fithic/${reso}/fragmentLists/frags_${reso}.gz"
	rm ${file}
done < "$outputfile"