#!/bin/bash

# 确保提供了输入文件
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_bed_file>"
    exit 1
fi

input_file=$1
temp_file=$(mktemp)

# 对输入文件进行排序,确保按染色体和pos1排序
sort -k1,1 -k2,2n -k3,3n "$input_file" > "$temp_file"

# 将标题行写入输出文件，并添加新列的标题
head -n 1 "$temp_file" | awk '{print $0 "\tNonNA_Count"}' > "${input_file%.bed}_merged.bed"

awk '
function add_or_na(a, b) {
    if (a == "NA" && b == "NA") return "NA";
    if (a == "NA") return b;
    if (b == "NA") return a;
    return a + b;
}

function count_non_na(arr, start, end) {
    count = 0;
    for (i = start; i <= end; i++) {
        if (arr[i] != "NA") count++;
    }
    return count;
}

BEGIN {
    FS=OFS="\t";
}
NR>1 {
    if (NR == 2) {
        chr = $1; start = $2; end = $3;
        for (i = 4; i <= NF; i++) col[i] = $i;
    } else {
        # 使用三元运算符计算绝对值
        start_diff = ($2 - start >= 0) ? ($2 - start) : (start - $2);
        end_diff = ($3 - end >= 0) ? ($3 - end) : (end - $3);
        
        if ($1 == chr && start_diff <= 30000 && end_diff <= 30000) {
            end = ($3 > end) ? $3 : end;
            start = ($2 < start) ? $2 : start;
            for (i = 4; i <= NF; i++) col[i] = add_or_na(col[i], $i);
        } else {
            non_na_count = count_non_na(col, 4, NF-1);
            printf "%s\t%d\t%d", chr, start, end;
            for (i = 4; i <= NF; i++) printf "\t%s", col[i];
            printf "\t%d\n", non_na_count;
            chr = $1; start = $2; end = $3;
            for (i = 4; i <= NF; i++) col[i] = $i;
        }
    }
}
END {
    non_na_count = count_non_na(col, 4, NF-1);
    printf "%s\t%d\t%d", chr, start, end;
    for (i = 4; i <= NF; i++) printf "\t%s", col[i];
    printf "\t%d\n", non_na_count;
}
' "$temp_file" >> "${input_file%.bed}_merged.bed"

# 删除临时文件
rm "$temp_file"