#!/bin/bash
dir=$1
reso=${2:-5000}
name=$(awk -F '/' '{print $NF}' <<< ${dir})

source activate peakachu
coolfile=${dir}/cool/${name}_${reso}.cool

mkdir -p $dir/anno/peakachu
cd $dir/anno/peakachu # /cluster/home/futing/Project/panCancer/CRC/GSE178593/DLD-1
echo -e "\nProcessing $name at $reso using peakachu call dots..."

# calculate depth
if [ ! -e ./${name}_$((reso / 1000))kb_clean.txt ];then
    echo "${name}_$((reso / 1000))kb_clean.txt exists, skip..."
else
    echo "${name}" > ./${name}_$((reso / 1000))kb.txt
    peakachu depth -p ${coolfile} >> ./${name}_$((reso / 1000))kb.txt
    awk '
    {
        if (NR % 28 == 1) {
            line1 = $0
        } else if (NR % 28 == 0) {
            model = $0
            sub(/^.*: /, "", model)  # 移除 "suggested model: " 部分，包括冒号后的空格
            sub(/ million/, "million", model)  # 移除 " million" 前的空格
            sub(/ billion/, "billion", model)  # 移除 " billion" 前的空格
            OFS = "\t"  # 设置输出字段分隔符为制表符
            print line1, model  # 使用逗号分隔变量，避免默认空格
        }
    }' ./${name}_$((reso / 1000))kb.txt > ./${name}_$((reso / 1000))kb_clean.txt
fi

if [ $? -ne 0 ]; then
    echo "***! Problem while running peakachu depth";
    exit 1
fi

# running peakachu
while read -r file depth; do
    echo "Processing ${file} at ${depth}..."
    if [ -f ${file}-peakachu-$((reso / 1000))kb-scores.bedpe ];then
        echo "${file}-peakachu-$((reso /conda  1000))kb-scores.bedpe exists, skip..."
        continue
    else
		weight=/cluster/home/futing/Project/GBM/HiC/10loop/peakachu/peakachu/high-confidence.${depth}.$((reso / 1000))kb.w6.pkl
		if [ ! -e ${weight} ];then
			echo "Weight file ${weight} does not exist, please check!"
			exit 1
		fi
        peakachu score_genome -r ${reso} --clr-weight-name weight \
            -p "${coolfile}" \
            -O ${file}-peakachu-$((reso / 1000))kb-scores.bedpe \
            -m $weight
    fi

	if [ $? -ne 0 ]; then
		echo "***! Problem while running peakachu score_genome";
		exit 1
	fi
    peakachu pool -r ${reso} \
        -i ${file}-peakachu-$((reso / 1000))kb-scores.bedpe \
        -o ${file}-peakachu-$((reso / 1000))kb-loops.0.95.bedpe -t 0.95

done < "./${name}_$((reso / 1000))kb_clean.txt"

if [ $? -eq 0 ]; then
    echo -e "Peakachu finished successfully for ${name} at ${reso} resolution!!!\n"
else
    echo "***! Problem while running peakachu";
    exit 1
fi