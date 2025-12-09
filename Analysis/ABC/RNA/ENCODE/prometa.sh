#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/

files=()
cell_names=()  # 存储细胞系名称的数组

while IFS= read -r cell; do
    metafile_pattern="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/${cell}/*.tsv"
    
    # 获取具体的tsv文件路径
    metafiles=( $metafile_pattern )
    if [ ${#metafiles[@]} -eq 0 ]; then
        echo "Warning: No TSV file found for cell line: $cell"
        continue
    fi
    
    metafile="${metafiles[0]}"  # 取第一个匹配的文件
    cd "/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/${cell}"
    
    # 确保输出文件名不包含通配符
    output_file="${metafile%.tsv}_IDmap.txt"
	# 5: expected count 6:TPM
    tail -n +2 "$metafile" | cut -f1,5 | sort -k1,1n > "$output_file"
    
    files+=("$output_file")
    cell_names+=("$cell")  # 存储细胞系名称
done < "/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/ENCODE_list.txt"

if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No files were processed"
    exit 1
fi

tmp="${files[0]}"
for f in "${files[@]:1}"; do
    join -a1 -a2 -e '.' -o auto "$tmp" "$f" > tmp_merged
    mv tmp_merged tmp_merged_file
    tmp="tmp_merged_file"
done

header="gene_id"
for cell in "${cell_names[@]}"; do
    header="$header\t$cell"
done

final_output="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/ENCODE/ENCODE_expected_count.txt"
echo -e "$header" > "$final_output"
cat "$tmp" >> "$final_output"

# 清理临时文件
if [ -f "tmp_merged_file" ]; then
    rm "tmp_merged_file"
fi


# 去掉.
awk '
NR==1 {
    header = $0; 
    next;
}
{
    split($1, a, ".");
    id = a[1];
    ids[id] = 1;

    for (i=2; i<=NF; i++) {
        sum[id][i] += $i;
    }
}
END {
    print header;

    n = asorti(ids, sorted);   # 如果你想按 ID 排序输出

    for (k=1; k<=n; k++) {
        id = sorted[k];
        printf "%s", id;
        for (i=2; i<=NF; i++) {
            printf "\t%s", sum[id][i];
        }
        printf "\n";
    }
}' "$final_output" > tmp && mv tmp "$final_output"

