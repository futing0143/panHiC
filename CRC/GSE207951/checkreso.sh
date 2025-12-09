#!/bin/bash


#---- mv logs to 
# ls ./debug/*.log | while read -r logfile;do
# 	path=$(grep 'Directory:' $logfile| sed 's/Directory: //g')
# 	# echo "Processing $path"
# 	echo "mv $logfile ${path}/debug"
# 	mv $logfile ${path}/debug
# done

# --- check ctrl cool
# mapfile -t ctrl_reso < <(cooler ls /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC26616/cool/CRC26616.mcool | awk -F'/' '{print $NF}' | sed 's/\n/ /g')
# cat /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt | while read -r cell;do
# 	mcoolfile=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}/cool/${cell}.mcool
# 	mapfile -t real_reso < <(cooler ls ${mcoolfile} | awk -F'/' '{print $NF}' | sed 's/\n/ /g')
# 	if [ "${ctrl_reso[*]}" == "${real_reso[*]}" ];then
# 		echo "[INFO] $cell cool resolutions match ctrl"
# 	else
# 		echo ${cell} >> /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC_ctrlerr2.txt
# 	fi
# done

# --- check all reso 发现
# cat /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC.txt | while read -r cell;do
# 	mcoolfile=/cluster2/home/futing/Project/panCancer/CRC/GSE207951/${cell}/cool/${cell}.mcool
# 	mapfile -t real_reso < <(cooler ls ${mcoolfile} | awk -F'/' '{print $NF}' | sed 's/\n/ /g')
# 	echo -e "${cell} ${real_reso[*]}" >> /cluster2/home/futing/Project/panCancer/CRC/GSE207951/CRC_reso.txt
# done
