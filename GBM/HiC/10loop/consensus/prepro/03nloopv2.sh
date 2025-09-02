#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <output_path> <input_file1> [<input_file2> ...]"
    exit 1
fi

# 获取输出路径
output_path=$1
shift  # 移除第一个参数

# 将剩余参数存储到数组 files 中
files=("$@")



# ------ 统计每个软件的 loop 数 ------
# 01 loop num
output_file="${output_path}/nloop6.txt"
echo "file_name peakachu mustache cooldots hiccups fithic homer" > "$output_file"

for name in ${files[@]};do
    # Initialize the line with the file name
    line="$name"
    NF=$(awk 'END{print NF}' "${name}/${name}_merged.bed")
    if [ $NF -gt 10 ]; then
        for i in {4..9}; do
            count=$(awk -v col="$i" '$col != "NA" && NR >1{count++} END {print count+0}' "${name}/${name}_merged.bed")
            line+=" $count"
        done
    elif [ $NF -eq 10 ]; then
        for i in {4..8}; do
            count=$(awk -v col="$i" '$col != "NA" && NR >1{count++} END {print count+0}' "${name}/${name}_merged.bed")
            line+=" $count"
        done
    else
        echo "$name error $NF"
    fi
    # Append the line to the output file
    echo "$line" >> "$output_file"
done


echo "Processing complete. Results saved in $output_file"

# -------- 统计每个软件的 unique loop 数 --------
# 02 unique loop num
output_file="${output_path}/nuniq6.txt"
echo "file_name peakachu mustache cooldots hiccups fithic homer" > "$output_file"

# Read the list of files
for name in ${files[@]};do
    line="$name"
    NF=$(awk 'END{print NF}' "${name}/${name}_merged.bed")
    if [ $NF -gt 10 ]; then
        for i in {4..9}; do
            count=$(awk -v col="$i" '$col != "NA" && $NF =="1"{count++} END {print count+0}' "${name}/${name}_merged.bed")
            line+=" $count"
        done
    elif [ $NF -eq 10 ]; then
        for i in {4..8}; do
            count=$(awk -v col="$i" '$col != "NA" && $NF =="1"{count++} END {print count+0}' "${name}/${name}_merged.bed")
            line+=" $count"
        done
    else
        echo "$name error $NF"
    fi

    # Append the line to the output file
    echo "$line" >> "$output_file"
done
echo "Processing complete. Results saved in $output_file"

# -------- 统计被检测大于2的loop --------
output_file="${output_path}/nloop_over2.txt"
# Read the list of files
for name in ${files[@]};do
    echo "Processing $name..."
    # Initialize the line with the file name
    line="$name"
    count=$(tail -n +2 "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid/${name}/${name}_over2.bed" | wc -l | cut -d ' ' -f 1)
    line+=" $count"
    # Append the line to the output file
    echo "$line" >> "$output_file"
done
echo "Sum the number over2. Results saved in $output_file"