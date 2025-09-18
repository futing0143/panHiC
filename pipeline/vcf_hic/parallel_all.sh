#!/bin/bash

# 全局变量
debugdir="/cluster2/home/futing/Project/HiCQTL/CRC"
mkdir -p "$debugdir/debug"

# 定义并行执行函数
parallel_execute() {
    local gse=$1
    local cell=$2
    
    # 为每个任务创建单独的日志文件
    local log_file="$debugdir/debug/${cell}-$(date +%Y%m%d_%H%M%S).log"
    
    echo "Starting $cell at $(date)" > "$log_file"
    sh "/cluster2/home/futing/Project/HiCQTL/hicQTL_single_all.sh" \
       "/cluster2/home/futing/Project/panCancer/CRC/${gse}/${cell}/splits" >> "$log_file" 2>&1
    echo "Finished $cell at $(date)" >> "$log_file"
}

# 导出函数和环境变量以便parallel使用
export -f parallel_execute
export debugdir

# 设置并行度
PARALLEL_JOBS=4

# 使用:::传递参数
parallel -j $PARALLEL_JOBS --colsep ' ' --progress --eta \
  "parallel_execute {1} {2}" :::: "/cluster2/home/futing/Project/HiCQTL/snpall.txt"

# CRCJun26
# CRC_bam.txt bam没转换 
# CRC_undone.txt bam转换了，没跑SNP
# GSE160235,DLD-1,Arima
# GSE160235,HCT116,Arima

# 第一批 包含了所有的 有几个样本有问题
# find /cluster2/home/futing/Project/HiCQTL/CRC -type d -exec basename {} \; > CRC_done.txt
# grep -w -v -F -f CRC_donemeta.txt /cluster2/home/futing/Project/panCancer/CRC/meta/CRC_meta.txt > CRC_undone.txt


# 第二批 手动去除了所有有问题的bam
# find /cluster2/home/futing/Project/HiCQTL/CRC -type d -exec basename {} \; > CRC_right.txt
# find /cluster2/home/futing/Project/HiCQTL/CRC -name 'snp.out.vcf' | cut -f8 -d '/' > snp.txt
# grep -w -F -v -f snp.txt CRC_right.txt > snpundone.txt
# awk -F ',' '{print "GSE137188",$0,"MboI"}' snpundone.txt > tmp && mv tmp snpundone.txt

# 第三批