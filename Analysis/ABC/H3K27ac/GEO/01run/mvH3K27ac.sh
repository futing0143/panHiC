#!/bin/bash

#################################################################################################
# ChIP-seq Data Organization Script
# - Merges SRRs belonging to same GSM
# - Merges all input/control samples into one
# - Generates sample.txt for pipeline
#################################################################################################

# 配置路径
work_dir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/new"
downsrr="/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/new/srr0120.txt"
metadata="/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/new/H3K27acmeta.csv"

cd "${work_dir}"

# 检查参数
if [ ! -f "${downsrr}" ] || [ ! -f "${metadata}" ]; then
    echo "Error: ${downsrr} or ${metadata} not found!"
    exit 1
fi

# 读取已下载的 SRR
mapfile -t downloaded_srrs < "${downsrr}"

# 构建 SRR -> 1 的关联数组，用于快速查找
declare -A downloaded_srr_map
for srr in "${downloaded_srrs[@]}"; do
    downloaded_srr_map["$srr"]=1
done

# 创建关联数组存储信息
declare -A gsm_srrs
declare -A gsm_cancer
declare -A gsm_gse
declare -A gsm_id
declare -A gsm_cell
declare -A gsm_mark

# 用于收集所有input样本
declare -A input_srrs_by_project  # key: cancer_gse_cell, value: SRR list

# 跳过 header，读取 metadata
# 格式: cancer,gse,gsm,srr,cell,mark,,
while IFS=',' read -r cancer gse gsm srr cell mark rest; do
    
    # 跳过空行
    [[ -z "$srr" ]] && continue
    
    echo "Checking SRR: $srr for GSM: $gsm, Mark: $mark"
    
    # 检查 SRR 是否已下载
    if [[ -z "${downloaded_srr_map[$srr]}" ]]; then
        echo "Warning: $srr not found in downloaded_srrs, skipping GSM: $gsm"
        continue
    fi
    
    # 如果是input/control样本，需要特殊处理
    if [[ "$mark" == "input" || "$mark" == "IgG" || "$mark" == "control" ]]; then
        project_key="${cancer}_${gse}_${cell}"
        
        if [[ -z "${input_srrs_by_project[$project_key]}" ]]; then
            input_srrs_by_project[$project_key]="$srr"
        else
            input_srrs_by_project[$project_key]="${input_srrs_by_project[$project_key]} $srr"
        fi
        
        # 保存项目信息用于后续创建目录
        if [[ -z "${gsm_cancer[$project_key]}" ]]; then
            gsm_cancer[$project_key]="$cancer"
            gsm_gse[$project_key]="$gse"
            gsm_cell[$project_key]="$cell"
            gsm_mark[$project_key]="input"
        fi
    else
        # 非input样本，以 GSM 作为 key 聚合 SRR
        if [[ -z "${gsm_srrs[$gsm]}" ]]; then
            gsm_srrs[$gsm]="$srr"
            gsm_cancer[$gsm]="$cancer"
            gsm_gse[$gsm]="$gse"
            gsm_cell[$gsm]="$cell"
            gsm_mark[$gsm]="$mark"
        else
            gsm_srrs[$gsm]="${gsm_srrs[$gsm]} $srr"
        fi
        
        echo "Added: GSM=$gsm, SRRs=${gsm_srrs[$gsm]}"
    fi
    
done < <(grep -v 'H3K4me3' "${metadata}")

# 调试：打印所有GSM键
echo "========== Found IP Samples =========="
for gsm in "${!gsm_srrs[@]}"; do
    echo "GSM: $gsm, Mark: ${gsm_mark[$gsm]}, SRRs: ${gsm_srrs[$gsm]}"
done
echo "======================================"

echo "========== Found Input Groups =========="
for project_key in "${!input_srrs_by_project[@]}"; do
    echo "Project: $project_key, SRRs: ${input_srrs_by_project[$project_key]}"
done
echo "========================================"

#################################################################################################
# 处理每个项目（按 cancer_gse_cell 分组）
#################################################################################################

# 收集所有唯一的项目
declare -A projects
for gsm in "${!gsm_srrs[@]}"; do
    cancer="${gsm_cancer[$gsm]}"
    gse="${gsm_gse[$gsm]}"
    cell="${gsm_cell[$gsm]}"
    project_key="${cancer}_${gse}_${cell}"
    projects[$project_key]=1
done

# 添加只有input的项目
for project_key in "${!input_srrs_by_project[@]}"; do
    projects[$project_key]=1
done

# 处理每个项目
for project_key in "${!projects[@]}"; do
    echo ""
    echo "=========================================="
    echo "Processing Project: $project_key"
    echo "=========================================="
    
    # 从project_key解析信息
    IFS='_' read -ra parts <<< "$project_key"
    cancer="${parts[0]}"
    gse="${parts[1]}"
    cell="${parts[2]}"
    
    # 创建目标目录
    target_dir="/cluster2/home/futing/Project/panCancer/Analysis/ABC/H3K27ac/GEO/${cancer}/${gse}/${cell}"
    mkdir -p "${target_dir}/fastq"
    
    # 创建sample.txt
    sample_file="${target_dir}/sample.txt"
    > "${sample_file}"  # 清空文件
    
    #################################################################################################
    # 1. 处理 Input 样本（如果存在）
    #################################################################################################
    
    if [[ -n "${input_srrs_by_project[$project_key]}" ]]; then
        echo ""
        echo "Processing Input samples for ${project_key}"
        
        input_srr_list="${input_srrs_by_project[$project_key]}"
        read -ra input_srr_array <<< "$input_srr_list"
        
        echo "Input SRRs: ${input_srr_list}"
        echo "Total input SRRs: ${#input_srr_array[@]}"
        
        # 收集所有input的R1、R2和单端文件
        input_r1_files=""
        input_r2_files=""
        input_single_files=""
        
        for srr in "${input_srr_array[@]}"; do
            echo "  Checking input SRR: $srr"
            if [ -f "${srr}_1.fastq.gz" ]; then
                input_r1_files="$input_r1_files ${srr}_1.fastq.gz"
                echo "    Found R1: ${srr}_1.fastq.gz"
            fi
            if [ -f "${srr}_2.fastq.gz" ]; then
                input_r2_files="$input_r2_files ${srr}_2.fastq.gz"
                echo "    Found R2: ${srr}_2.fastq.gz"
            fi
            # 检查单端数据（文件名为 SRR*.fastq.gz，不带_1或_2）
            if [ -f "${srr}.fastq.gz" ]; then
                input_single_files="$input_single_files ${srr}.fastq.gz"
                echo "    Found single-end: ${srr}.fastq.gz"
            fi
        done
        
        # 合并所有input文件
        if [ -n "$input_r1_files" ]; then
            echo "Merging all input R1 files..."
			echo "cat $input_r1_files > "${target_dir}/fastq/input.R1.fastq.gz""
            cat $input_r1_files > "${target_dir}/fastq/input.R1.fastq.gz"
            echo "Created: ${target_dir}/fastq/input.R1.fastq.gz"
        fi
        
        if [ -n "$input_r2_files" ]; then
            echo "Merging all input R2 files..."
			echo "cat $input_r2_files > "${target_dir}/fastq/input.R2.fastq.gz""
            cat $input_r2_files > "${target_dir}/fastq/input.R2.fastq.gz"
            echo "Created: ${target_dir}/fastq/input.R2.fastq.gz"
        fi
        
        if [ -n "$input_single_files" ]; then
            echo "Merging all input single-end files..."
            cat $input_single_files > "${target_dir}/fastq/input.fastq.gz"
			echo "cat $input_single_files > "${target_dir}/fastq/input.fastq.gz""
            echo "Created: ${target_dir}/fastq/input.fastq.gz"
        fi
        
        # 将input写入sample.txt（第一行）
        echo "input" >> "${sample_file}"
        echo "Written 'input' to ${sample_file}"
    fi
    
    #################################################################################################
    # 2. 处理 IP 样本
    #################################################################################################
    
    # 收集属于当前项目的所有GSM
    project_gsms=()
    for gsm in "${!gsm_srrs[@]}"; do
        if [[ "${gsm_cancer[$gsm]}" == "$cancer" ]] && \
           [[ "${gsm_gse[$gsm]}" == "$gse" ]] && \
           [[ "${gsm_cell[$gsm]}" == "$cell" ]]; then
            project_gsms+=("$gsm")
        fi
    done
    
    echo ""
    echo "Processing ${#project_gsms[@]} IP sample(s) for ${project_key}"
    
    for gsm in "${project_gsms[@]}"; do
        echo ""
        echo "  Processing GSM: $gsm (${gsm_mark[$gsm]})"
        
        srr_list="${gsm_srrs[$gsm]}"
        read -ra srr_array <<< "$srr_list"
        srr_count=${#srr_array[@]}
        
        echo "  GSM $gsm has $srr_count SRR(s): ${srr_list}"
        
        if [ $srr_count -eq 1 ]; then
            # 只有一个SRR，直接移动并重命名
            srr="${srr_array[0]}"
            echo "  Processing single SRR: $srr -> ${gsm}"
            
            # 双端数据
            if [ -f "${srr}_1.fastq.gz" ]; then
                mv "${srr}_1.fastq.gz" "${target_dir}/fastq/${gsm}.R1.fastq.gz"
                echo "    Moved: ${srr}_1.fastq.gz -> ${target_dir}/fastq/${gsm}.R1.fastq.gz"
            fi
            if [ -f "${srr}_2.fastq.gz" ]; then
                mv "${srr}_2.fastq.gz" "${target_dir}/fastq/${gsm}.R2.fastq.gz"
                echo "    Moved: ${srr}_2.fastq.gz -> ${target_dir}/fastq/${gsm}.R2.fastq.gz"
            fi
            # 单端数据
            if [ -f "${srr}.fastq.gz" ]; then
                mv "${srr}.fastq.gz" "${target_dir}/fastq/${gsm}.fastq.gz"
                echo "    Moved: ${srr}.fastq.gz -> ${target_dir}/fastq/${gsm}.fastq.gz"
            fi
            
        else
            # 多个SRR，需要合并
            echo "  Processing multiple SRRs for ${gsm}: ${srr_list}"
            
            r1_files=""
            r2_files=""
            single_files=""
            
            for srr in "${srr_array[@]}"; do
                echo "    Checking SRR: $srr"
                if [ -f "${srr}_1.fastq.gz" ]; then
                    r1_files="$r1_files ${srr}_1.fastq.gz"
                    echo "      Found R1: ${srr}_1.fastq.gz"
                fi
                if [ -f "${srr}_2.fastq.gz" ]; then
                    r2_files="$r2_files ${srr}_2.fastq.gz"
                    echo "      Found R2: ${srr}_2.fastq.gz"
                fi
                if [ -f "${srr}.fastq.gz" ]; then
                    single_files="$single_files ${srr}.fastq.gz"
                    echo "      Found single-end: ${srr}.fastq.gz"
                fi
            done
            
            # 合并R1
            if [ -n "$r1_files" ]; then
                echo "    Merging R1 files..."
                cat $r1_files > "${target_dir}/fastq/${gsm}.R1.fastq.gz"
                echo "    Created: ${target_dir}/fastq/${gsm}.R1.fastq.gz"
            fi
            
            # 合并R2
            if [ -n "$r2_files" ]; then
                echo "    Merging R2 files..."
                cat $r2_files > "${target_dir}/fastq/${gsm}.R2.fastq.gz"
                echo "    Created: ${target_dir}/fastq/${gsm}.R2.fastq.gz"
            fi
            
            # 合并单端文件
            if [ -n "$single_files" ]; then
                echo "    Merging single-end files..."
                cat $single_files > "${target_dir}/fastq/${gsm}.fastq.gz"
                echo "    Created: ${target_dir}/fastq/${gsm}.fastq.gz"
            fi
        fi
        
        # 将GSM写入sample.txt
        echo "${gsm}" >> "${sample_file}"
        echo "  Written '${gsm}' to ${sample_file}"
    done
    
    echo ""
    echo "Project ${project_key} completed!"
    echo "Sample list saved to: ${sample_file}"
    echo "Files saved to: ${target_dir}/fastq/"
    
    # 显示sample.txt内容
    echo "Sample list contents:"
    cat "${sample_file}"
    echo "=========================================="
done

echo ""
echo "=========================================="
echo "All processing complete!"
echo "=========================================="