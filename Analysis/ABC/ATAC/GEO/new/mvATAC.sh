#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new

downsrr=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/srr0121done.txt
metadata=/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/new/ATACtest.tsv

# 检查参数
if [ ! -f "${downsrr}" ] || [ ! -f "${metadata}" ]; then
    echo "Error: ${downsrr} or ${metadata} not found!"
    exit 1
fi

# 读取已下载的 SRR（示例：第21–24行）
mapfile -t downloaded_srrs < "${downsrr}"

# 构建 SRR -> 1 的关联数组，用于快速查找
declare -A downloaded_srr_map
for srr in "${downloaded_srrs[@]}"; do
    downloaded_srr_map["$srr"]=1
done

# 创建关联数组存储 GSM 相关信息
declare -A gsm_srrs
declare -A gsm_cancer
declare -A gsm_gse
declare -A gsm_id

# 跳过 header，读取 metadata

while IFS=$'\t' read -r cancer gse cell clcell ncell final atac gsm srr id; do

    echo "Checking SRR: $srr for GSM: $gsm in ${cancer}"

    # 使用 downloaded_srr_map 判断 SRR 是否已下载
    if [[ -z "${downloaded_srr_map[$srr]}" ]]; then
        echo "Warning: $srr not found in downloaded_srrs, skipping GSM: $gsm"
        continue
    fi

    # 以 GSM 作为 key 聚合 SRR
    if [[ -z "${gsm_srrs[$gsm]}" ]]; then
        gsm_srrs[$gsm]="$srr"
        gsm_cancer[$gsm]="$cancer"
        gsm_gse[$gsm]="$gse"
        gsm_id[$gsm]="$id"
    else
        gsm_srrs[$gsm]="${gsm_srrs[$gsm]} $srr"
    fi

    echo "Added: GSM=$gsm, SRRs=${gsm_srrs[$gsm]}"
done < <(tail -n +2 "${metadata}")

# 调试：打印所有GSM键
echo "========== Found GSMs =========="
for gsm in "${!gsm_srrs[@]}"; do
    echo "GSM: $gsm, SRRs: ${gsm_srrs[$gsm]}"
done
echo "================================"

# 处理每个GSM
for gsm in "${!gsm_srrs[@]}"; do
    echo -e "Processing GSM: $gsm\n"
    
    cancer="${gsm_cancer[$gsm]}"
    gse="${gsm_gse[$gsm]}"
    id="${gsm_id[$gsm]}"
    srr_list="${gsm_srrs[$gsm]}"
    
    # 正确地将空格分隔的字符串分割成数组
    read -ra srr_array <<< "$srr_list"
    
    # 创建目标目录
    target_dir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/ATAC/GEO/${cancer}/${gse}/${id}"
    mkdir -p "${target_dir}/fastq"
    
    # 写入GSM号到srr.txt文件
    srr_file="${target_dir}/srr.txt"
	> "${srr_file}"
    echo "${gsm}" >> "${srr_file}"
    echo "Written GSM to: ${srr_file}"
    
    # 统计该GSM对应的SRR数量
    srr_count=${#srr_array[@]}
    echo "GSM $gsm has $srr_count SRR(s): ${srr_list}"
    
    if [ $srr_count -eq 1 ]; then
        # 只有一个SRR，直接重命名
        srr="${srr_array[0]}"
        echo "Processing single SRR: $srr -> ${gsm}"
        
        for fastq in ${srr}*.fastq.gz; do
            if [ -f "$fastq" ]; then
                # 提取读段信息 (_1 或 _2)
                if [[ $fastq =~ _1\.fastq\.gz$ ]]; then
                    mv "$fastq" "${target_dir}/fastq/${gsm}_1.fastq.gz"
                    echo "Moved: $fastq -> ${target_dir}/fastq/${gsm}_1.fastq.gz"
                elif [[ $fastq =~ _2\.fastq\.gz$ ]]; then
                    mv "$fastq" "${target_dir}/fastq/${gsm}_2.fastq.gz"
                    echo "Moved: $fastq -> ${target_dir}/fastq/${gsm}_2.fastq.gz"
                else
                    mv "$fastq" "${target_dir}/fastq/${gsm}.fastq.gz"
                    echo "Moved: $fastq -> ${target_dir}/fastq/${gsm}.fastq.gz"
                fi
            fi
        done
    else
        # 多个SRR，需要合并
        echo "Processing multiple SRRs for ${gsm}: ${srr_list}"
        
        # 分别合并 _1 和 _2 reads
        r1_files=""
        r2_files=""
        single_files=""
        
        for srr in ${srr_array[@]}; do
            echo "  Checking SRR: $srr"
            if [ -f "${srr}_1.fastq.gz" ]; then
                r1_files="$r1_files ${srr}_1.fastq.gz"
                echo "    Found R1: ${srr}_1.fastq.gz"
            fi
            if [ -f "${srr}_2.fastq.gz" ]; then
                r2_files="$r2_files ${srr}_2.fastq.gz"
                echo "    Found R2: ${srr}_2.fastq.gz"
            fi
            # 处理单端数据
            if [ -f "${srr}.fastq.gz" ]; then
                single_files="$single_files ${srr}.fastq.gz"
                echo "    Found single-end: ${srr}.fastq.gz"
            fi
        done
        
        # 合并R1
        if [ -n "$r1_files" ]; then
            echo "Merging R1 files: $r1_files"
            cat $r1_files > "${target_dir}/fastq/${gsm}_1.fastq.gz"
            echo "Created: ${target_dir}/fastq/${gsm}_1.fastq.gz"
        fi
        
        # 合并R2
        if [ -n "$r2_files" ]; then
            echo "Merging R2 files: $r2_files"
            cat $r2_files > "${target_dir}/fastq/${gsm}_2.fastq.gz"
            echo "Created: ${target_dir}/fastq/${gsm}_2.fastq.gz"
        fi
        
        # 合并单端文件
        if [ -n "$single_files" ]; then
            echo "Merging single-end files: $single_files"
            cat $single_files > "${target_dir}/fastq/${gsm}.fastq.gz"
            echo "Created: ${target_dir}/fastq/${gsm}.fastq.gz"
        fi
    fi
done

echo "Processing complete!"