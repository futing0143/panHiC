#!/bin/bash
current_dir='/cluster/home/futing/Project/GBM/CTCF/GSE121601/G583'


# 使用 find 命令递归查找所有文件，并使用 xargs 和 sed 来重命名
find "$current_dir" -type f -exec bash -c '
    for file in "$@"; do
        # 检查文件名是否包含 _1 或 _2
        if [[ "$file" == *"_1"* ]] || [[ "$file" == *"_2"* ]]; then
            # 使用 sed 替换 _1 为 .R1 和 _2 为 .R2
            new_name=$(echo "$file" | sed -e "s/_1/.R1/" -e  "s/_2/.R2/")
            # 构造移动命令来重命名文件
            mv "$file" "$new_name" && echo "Renamed $file to $new_name"
        fi
    done
' bash {} +

# 注意：bash -c 是为了在 find 命令中执行 shell 命令
# {} + 表示对 find 命令的输出进行批处理，以减少 find 命令的调用次数
for dir in "$current_dir"/*/; do
    # 获取子文件夹的名称
    folder_name=$(basename "$dir")
    if [[ "$folder_name" == SRR* ]]; then
    echo "Processing $folder_name"
    # 如果是文件，则执行shell脚本并传递子文件夹名称作为参数
    #sh /cluster/home/futing/pipeline/ChIP_CUTTAG/cut2rose_lite.sh "" 30 input rose ""
    #sh /cluster/home/futing/pipeline/fq2bigwig_v3.sh /cluster/home/futing/Project/GBM/CTCF/GSE121601/G583/rep1 g583_rep1
    #sh /cluster/home/futing/pipeline/fq2bigwig_v3.sh /cluster/home/futing/Project/GBM/CTCF/GSE121601/G583/SRR8085200 g583_ip
    #bamCoverage -b ${dir}/bam_files/${folder_name}_final.bam -o ${dir}/bigwig/${folder_name}_final.bw --normalizeUsing RPKM
    echo -e "BAM2BigWig completed! \n \n \n"
    fi
done