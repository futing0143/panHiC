#!/bin/bash

# 设置错误处理
set -e
set -u

# 定义输入和输出路径
INPUT_LIST="/cluster/home/futing/Project/GBM/HiC/10loop/consensus/namelist.txt"
OUTPUT_FILE="/cluster/home/futing/Project/GBM/HiC/10loop/consensus/result/QC_6/num_loop.txt"
BASE_DIR="/cluster/home/futing/Project/GBM/HiC/10loop/consensus/mid"

# 定义所有可能的工具名称
TOOLS=("peakachu" "mustache" "cooldots" "hiccups" "fithic" "homer")

# 写入标题行
echo -e "file_name\t${TOOLS[*]}" > "$OUTPUT_FILE"

# 处理每个文件
while IFS= read -r name; do
    echo "Processing $name..."
    
    # 检查输入文件
    input_file="${BASE_DIR}/${name}/${name}_merged.bed"
    if [ ! -f "$input_file" ]; then
        echo "Warning: File $input_file not found, skipping..."
        continue
    fi
    
    # 执行awk命令，统计工具使用情况
    result=$(awk -v name="$name" -v tools="${TOOLS[*]}" '
    BEGIN {
        split(tools, tool_list, " ")
        for (i in tool_list) {
            tool_counts[tool_list[i]] = 0
        }
    }
    
    # 处理标题行，找到每个工具对应的列号
    NR == 1 {
        for (i = 1; i <= NF; i++) {
            for (tool in tool_counts) {
                if (tolower($i) == tool) {
                    tool_cols[tool] = i
                }
            }
        }
    }
    
    # 统计每个工具的非NA值
    NR > 1 {
        for (tool in tool_cols) {
            col = tool_cols[tool]
            if ($col != "NA" && $col != "na" && $col != "-" && $col != "") {
                tool_counts[tool]++
            }
        }
    }
    
    END {
        # 输出结果
        printf "%s", name
        for (tool in tool_list) {
            printf "\t%d", tool_counts[tool_list[tool]]
        }
        printf "\n"
    }
    ' "$input_file")
    
    # 将结果添加到输出文件
    echo -e "$result" >> "$OUTPUT_FILE"
    
done < "$INPUT_LIST"

echo "Processing complete. Results saved in $OUTPUT_FILE"

# 为了便于查看，打印前几行结果
echo -e "\nFirst few lines of the output:"
head -n 5 "$OUTPUT_FILE"
