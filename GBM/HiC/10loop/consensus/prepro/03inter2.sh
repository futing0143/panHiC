#!/bin/bash

# 这个脚本统计了每个文件中的每个组合的非零值的数量。
# 检查参数
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <output_file> <input_file1> [<input_file2> ...]"
    exit 1
fi

# 输出文件
output_file=$1
shift

# 检查至少有一个输入文件
if [ "$#" -eq 0 ]; then
    echo "Error: At least one input file must be provided."
    exit 1
fi

# 检查所有输入文件是否存在
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Error: Input file '$file' does not exist."
        exit 1
    fi
done

# 读取第一个文件的列名，作为表头（从第4列到倒数第3列）
header=$(head -n 1 "$1" | awk '{
    for(i=4; i<=NF-2; i++) {
        printf "%s%s", $i, (i<NF-2 ? " " : "")
    }
}')

# 生成组合的表头
header_columns=($header)
combinations=()

for ((i=0; i<${#header_columns[@]}; i++)); do
  for ((j=i+1; j<${#header_columns[@]}; j++)); do
    combinations+=("${header_columns[i]}_${header_columns[j]}")
  done
done

# 写入表头
echo "file_name total ${combinations[*]}" > "$output_file"

# 使用 awk 进行统计
awk -v output_file="$output_file" '
BEGIN {
    FS=OFS="\t"
    split("'"${combinations[*]}"'", combos, " ")
}
FNR == 1 {
    if (NR > 1) {
        print_results()
    }
    full_file = FILENAME
    "basename " full_file " _merged.bed" | getline file
    close("basename " full_file " .bed")
    delete counts
    total = 0
    # 存储从第4列到倒数第3列的列名
    for (i = 4; i <= NF-2; i++) {
        col_names[i] = $i
    }
    last_col = NF-2  # 记录最后一列的位置
}
FNR > 1 {
    total++
    # 修改循环范围为第4列到倒数第3列
    for (i = 4; i <= last_col; i++) {
        for (j = i + 1; j <= last_col; j++) {
            if ($i != "0" && $i != "NA" && $j != "0" && $j != "NA") {
                counts[col_names[i] "_" col_names[j]]++
            }
        }
    }
}
END {
    print_results()
}
function print_results() {
    printf "%s %d", file, total >> output_file
    for (i = 1; i <= length(combos); i++) {
        printf " %d", (combos[i] in counts) ? counts[combos[i]] : 0 >> output_file
    }
    printf "\n" >> output_file
}
' "$@"

echo "分析完成，结果保存在 $output_file 文件中。"
