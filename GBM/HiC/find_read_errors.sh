#!/bin/bash

# 设置输出文件
OUTPUT_FILE=$2

# 检查参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <目录路径>"
    exit 1
fi

SCAN_DIR="$1"

# 检查目录是否存在
if [ ! -d "$SCAN_DIR" ]; then
    echo "错误: 目录 '$SCAN_DIR' 不存在"
    exit 1
fi

# 创建/清空输出文件
> "$OUTPUT_FILE"

# 检查文件是否有读取错误并记录路径
find "$SCAN_DIR" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
    # 跳过特殊目录
    if [[ "$file" == */proc/* ]] || [[ "$file" == */sys/* ]] || [[ "$file" == */dev/* ]] || [[ "$file" == */run/* ]]; then
        continue
    fi
    
    # 检查文件读取错误
    if head -n 3 "$file" 2>&1 | grep -q "Communication error on send\|Input/output error"; then
        realpath "$file" >> "$OUTPUT_FILE"
    fi
done

echo "扫描完成，结果保存在 $OUTPUT_FILE"