#!/bin/bash


dir="$1"
reso="${2:-5000}"
name=$(basename "$dir")

coolfile="${dir}/cool/${name}_${reso}.cool"
echo "Processing ${coolfile}..."
# !!!! checking if the cool file is balanced !!!!
if cooler dump -t bins --header "$coolfile" \
| head -1 \
| grep -qw "weight" ; then
# tr '\t' '\n' 将所有制表符替换为换行符
# grep -qxF "weight" 搜索是否有一行完全等于 "weight" (F=固定字符串，X=整行匹配)
    echo "[$(date)] $coolfile is balanced"
else
	echo "[$(date)] ${coolfile} is not ICE balanced!"
	cooler balance "$coolfile"
fi
