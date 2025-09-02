#!/bin/bash

# 这个版本是4-9列为字符串的版本
# ------ 统计每个软件的 loop 数 ------
# 01 loop num
# Define the output file
output_file="loop_num.txt"

# Write the header
echo "file_name peakachu mustache cooldots hiccups fithic" > "$output_file"

# Read the list of files
while read -r name; do
    # Initialize the line with the file name
    line="$name"
    
    # Count occurrences of each term and append to the line
    for term in peakachu mustache cooldots hiccups fithic; do
        count=$(grep -w "$term" "${name}/${name}.bed" | wc -l) # 统计每个软件的loop数
        count=$((count > 0 ? count - 1 : 0)) # 去掉第一行
        line+=" $count"
    done
    
    # Append the line to the output file
    echo "$line" >> "$output_file"
done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/donep1.txt"

echo "Processing complete. Results saved in $output_file"

# -------- 统计每个软件的 unique loop 数 --------
# 02 unique loop num
output_file="unique_loop_num.txt"

# Write the header
echo "file_name peakachu mustache cooldots hiccups fithic" > "$output_file"

# Read the list of files
while read -r name; do
    # Initialize the line with the file name
    line="$name"
    
    for term in peakachu mustache cooldots hiccups fithic; do
        count=$(grep -w "$term" "${name}/${name}.bed" | grep -w '1' | wc -l)  # 统计 peackachu 且最后一列为1 的行数 
        count=$((count > 0 ? count - 1 : 0))
        line+=" $count"
    done
    
    # Append the line to the output file
    echo "$line" >> "$output_file"
done < "/cluster/home/futing/Project/GBM/HiC/10loop/consensus/donep1.txt"

# count consensus loop num
output_file="consensus_loop_num.txt"
sh /cluster/home/futing/Project/GBM/HiC/10loop/consensus/qc_all.sh ${files[@]} > "$output_file"
