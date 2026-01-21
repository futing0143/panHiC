#!/bin/bash

# 设置严格模式
set -e
set -u
set -o pipefail

# 输入文件
META_FILE="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/00meta/RNA_GSE_srrtest.txt"
SRR_LIST="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/download/dumpdone0117nig.txt"

# 检查必需文件是否存在
if [[ ! -f "$META_FILE" ]]; then
    echo "错误: 未找到 $META_FILE"
    exit 1
fi

if [[ ! -f "$SRR_LIST" ]]; then
    echo "错误: 未找到 $SRR_LIST"
    exit 1
fi

# 从meta文件提取cancer, gsm, srr三列 (假设格式为: name cell_line cancer condition geo gsm srr)
echo "开始处理meta文件..."

# 读取已下载的SRR列表到数组
mapfile -t downloaded_srrs < "$SRR_LIST"
echo "已下载 ${#downloaded_srrs[@]} 个SRR文件"

# 处理每一行meta数据
while read -r line; do
    # 跳过空行
    [[ -z "$line" ]] && continue
    
    # 解析字段 (根据你的数据格式调整列索引)
    fields=($line)
    cancer="${fields[2]}"
    gsm="${fields[5]}"
    srr_field="${fields[6]}"
    
    echo ""
    echo "=== 处理 GSM: $gsm (Cancer: $cancer) ==="
    
    # 分割SRR字段(可能包含分号分隔的多个SRR)
    IFS=';' read -ra srr_array <<< "$srr_field"
    echo "需要的SRR文件: ${srr_array[*]}"
    
    # 检查所有SRR是否都已下载
    all_downloaded=true
    missing_srrs=()
    
    for srr in "${srr_array[@]}"; do
        if ! printf '%s\n' "${downloaded_srrs[@]}" | grep -q "^${srr}$"; then
            all_downloaded=false
            missing_srrs+=("$srr")
        fi
    done
    
    if [[ "$all_downloaded" == false ]]; then
        echo "警告: GSM $gsm 缺少以下SRR文件: ${missing_srrs[*]}"
        echo "跳过此GSM"
        continue
    fi
    
    echo "✓ 所有SRR文件已下载"
    
    # 创建输出目录
    output_dir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/RNA/GEO/${cancer}/fastq"
    mkdir -p "$output_dir"
    
    # 检测是单端还是双端测序
    first_srr="${srr_array[0]}"
    
    # 查找第一个SRR的fastq文件
    if [[ -f "${first_srr}_1.fastq.gz" && -f "${first_srr}_2.fastq.gz" ]]; then
        echo "检测到双端测序数据"
        is_paired=true
    elif [[ -f "${first_srr}.fastq.gz" ]]; then
        echo "检测到单端测序数据"
        is_paired=false
    else
        echo "错误: 未找到 $first_srr 的fastq文件"
        continue
    fi
    
    # 合并fastq文件
    if [[ "$is_paired" == true ]]; then
        # 双端测序
        echo "合并双端数据到 ${output_dir}/${gsm}_1.fastq.gz 和 ${output_dir}/${gsm}_2.fastq.gz"
        
        # 合并 R1
        cat_files_r1=()
        for srr in "${srr_array[@]}"; do
            if [[ -f "${srr}_1.fastq.gz" ]]; then
                cat_files_r1+=("${srr}_1.fastq.gz")
            else
                echo "警告: 未找到 ${srr}_1.fastq.gz"
            fi
        done
        
        if [[ ${#cat_files_r1[@]} -gt 0 ]]; then
            cat "${cat_files_r1[@]}" > "${output_dir}/${gsm}_1.fastq.gz"
            echo "✓ R1 合并完成"
        fi
        
        # 合并 R2
        cat_files_r2=()
        for srr in "${srr_array[@]}"; do
            if [[ -f "${srr}_2.fastq.gz" ]]; then
                cat_files_r2+=("${srr}_2.fastq.gz")
            else
                echo "警告: 未找到 ${srr}_2.fastq.gz"
            fi
        done
        
        if [[ ${#cat_files_r2[@]} -gt 0 ]]; then
            cat "${cat_files_r2[@]}" > "${output_dir}/${gsm}_2.fastq.gz"
            echo "✓ R2 合并完成"
        fi
        
    else
        # 单端测序
        echo "合并单端数据到 ${output_dir}/${gsm}.fastq.gz"
        
        cat_files=()
        for srr in "${srr_array[@]}"; do
            if [[ -f "${srr}.fastq.gz" ]]; then
                cat_files+=("${srr}.fastq.gz")
            else
                echo "警告: 未找到 ${srr}.fastq.gz"
            fi
        done
        
        if [[ ${#cat_files[@]} -gt 0 ]]; then
            cat "${cat_files[@]}" > "${output_dir}/${gsm}.fastq.gz"
            echo "✓ 合并完成"
        fi
    fi
    
    echo "✓ GSM $gsm 处理完成"
    
done < "$META_FILE"

echo ""
echo "=== 所有任务完成 ==="