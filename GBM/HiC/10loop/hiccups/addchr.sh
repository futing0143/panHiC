#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/10loop/hiccups
cat /cluster/home/futing/Project/GBM/HiC/10loop/hiccups/name_nochr.txt | while read name;do
    echo $name
    input_file="/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/results/${name}/postprocessed_pixels_10000.bedpe"
    output_file="/cluster/home/futing/Project/GBM/HiC/10loop/hiccups/results/${name}/postprocessed_pixels_10000_chr.bedpe"

    # 处理文件，打印前两行，之后修改第一列和第四列，并输出到新文件
    awk '{OFS=FS="\t"}NR<=2 {print; next} { $1="chr"$1; $4="chr"$4; print }' "$input_file" > "$output_file"
    mv "$output_file" "$input_file"
done


# find ./results/* -type d | while read name; do
#     input_file="${name}/merged_loops.bedpe"
#     echo -e "name is $name" >> res.txt
#     # 计算第三行的差值
#     awk 'NR>2 {print $3-$2}' "$input_file" | sort | uniq >> res.txt
#     echo -e "name is $name"
# done
