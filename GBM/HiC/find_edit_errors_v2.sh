#!/bin/bash

# 设置输出文件
OUTPUT_FILE=$2
SCAN_DIR="$1"

# 检查参数
if [ $# -lt 2 ]; then
    echo "使用方法: $0 <目录路径> <错误文件列表>"
    exit 1
fi

# 检查目录是否存在
if [ ! -d "$SCAN_DIR" ]; then
    echo "错误: 目录 '$SCAN_DIR' 不存在"
    exit 1
fi

# 创建/清空输出文件
> "$OUTPUT_FILE"

# 检查文件是否有读取错误并测试写入权限（不实际修改）
find "$SCAN_DIR" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
    # 跳过特殊目录
    if [[ "$file" == */proc/* ]] || [[ "$file" == */sys/* ]] || [[ "$file" == */dev/* ]] || [[ "$file" == */run/* ]] || [[ "$file" == */.git/* ]]; then
        continue
    fi
    
    # 检查文件读取错误
    if ! head -n 1 "$file" &>/dev/null; then
        echo "读取错误: $file"
        realpath "$file" >> "$OUTPUT_FILE"
        continue
    fi
    
    # 测试文件写入权限而不实际修改
    if [ -f "$file" ] && [ -r "$file" ]; then
        # 检查文件是否为文本文件
        if file "$file" | grep -q "text"; then
            # 测试写入权限而不修改内容
            if [ -w "$file" ] && touch -a "$file" 2>/dev/null; then
                echo "可写入: $file"
            else
                echo "不可写入: $file"
                realpath "$file" >> "$OUTPUT_FILE"
            fi
        fi
    else
        # 文件没有读权限
        echo "无读权限: $file"
        realpath "$file" >> "$OUTPUT_FILE"
    fi
done

echo "扫描完成:"
echo "- 读取错误文件保存在 $OUTPUT_FILE"
