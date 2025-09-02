#!/bin/bash

# 检查是否提供了至少两个参数（输出文件名和至少一个输入文件）
if [ $# -lt 2 ]; then
    echo "Usage: $0 output_file input_file1 input_file2 ..."
    exit 1
fi

# 第一个参数是输出文件名
output_file="$1"
shift  # 移除第一个参数，剩下的都是输入文件

# 使用 awk 来处理文件
awk '
    BEGIN {
        FS=OFS="\t"  # 设置输入和输出的字段分隔符为制表符
        
        # 构建表头
        header = "chr\tstart\tend"
        for (i = 1; i <= ARGC - 1; i++) {
            file = ARGV[i]
            # 移除路径和后缀
            gsub(/^.*\//, "", file)  # 移除路径，现在是 GBM_cooldots_str.bed
            gsub(/\.[^.]*$/, "", file)  # 移除后缀，现在是 GBM_cooldots_str
            gsub(/^[^_]*_/, "", file)  # 移除第一个下划线前的内容，现在是 cooldots_str
            gsub(/_.*$/, "", file)  # 移除最后一个下划线及其后的内容，最终得到 cooldots
            header = header "\t" file
        }
        header = header "\tnum"
        print header
    }
    {
        key = $1     # 第一列作为键
        file = FILENAME  # 当前文件名
        gsub(/^.*\//, "", file)  # 移除文件路径，只保留文件名
        gsub(/\.[^.]*$/, "", file)  # 移除文件后缀
        
        # 存储每个键对应的所有值
        if (!(key in data)) {
            keys[++num_keys] = key  # 保持键的顺序
        }
        data[key][file] = ($2 != "") ? 1 : "NA"  # 如果有值则存储1，否则存储NA
        
        # 计算每个键出现的次数
        count[key]++
    }
    END {
        # 按原始顺序打印数据
        for (k = 1; k <= num_keys; k++) {
            key = keys[k]
            split(key, key_parts, "_")  # 将键按下划线分割
            
            # 打印前三列（分割后的键）
            printf "%s\t%s\t%s", key_parts[1], key_parts[2], key_parts[3]
            
            # 打印其他列
            for (i = 1; i <= ARGC - 1; i++) {
                file = ARGV[i]
                gsub(/^.*\//, "", file)  # 移除路径
                gsub(/\.[^.]*$/, "", file)  # 移除后缀
                value = (file in data[key]) ? data[key][file] : "NA"
                printf "\t%s", value
            }
            # 打印每个键出现的次数为最后一列
            printf "\t%d\n", count[key]
        }
    }
' "$@" > "$output_file"
sort -k1,1 -k2,2n "$output_file" > "${output_file%.bed}_sorted.bed"
mv "${output_file%.bed}_sorted.bed" "$output_file"
echo "合并完成，结果保存在 $output_file 文件中。"