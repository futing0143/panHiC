#!/bin/bash

# 输入文件和结果文件夹
input_file="/cluster/home/futing/Project/GBM/ChIP/H3K27ac/diff/meta_chip_cell10.csv"  # 包含路径的文件
output_dir="results"        # 结果文件夹
temp_dir=$(mktemp -d)       # 临时文件夹

# 创建结果文件夹
mkdir -p "$output_dir"

tail -n +2 /cluster/home/futing/Project/GBM/ChIP/H3K27ac/diff/meta_chip_cell10.csv | cut -d ',' -f10 > test.txt
# 逐行读取路径并执行操作
index=0
while IFS= read -r path; do
    # 对每个路径执行操作（例如，使用 samtools quickcheck）
    cut -f1 "$path" | uniq > "$temp_dir/result_$index.txt" 2>&1

    # 如果操作成功，记录成功；否则记录失败
    if [ $? -eq 0 ]; then
        echo "OK" >> "$temp_dir/status_$index.txt"
    else
        echo "FAIL" >> "$temp_dir/status_$index.txt"
    fi

    index=$((index + 1))
done < "test.txt"

# 按列合并结果
paste "$temp_dir"/result_*.txt > "$output_dir/merged_results.txt"
paste "$temp_dir"/status_*.txt > "$output_dir/merged_status.txt"

# 清理临时文件夹
rm -rf "$temp_dir"
rm test.txt
echo "操作完成！结果已保存到 $output_dir"