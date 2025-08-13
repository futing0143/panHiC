#!/bin/bash

# 设置输出文件
FAILED_FILES=$2

# 检查参数
if [ $# -lt 2 ]; then
    echo "使用方法: $0 <目录路径> <修改失败文件列表>"
    exit 1
fi

SCAN_DIR="$1"

# 检查目录是否存在
if [ ! -d "$SCAN_DIR" ]; then
    echo "错误: 目录 '$SCAN_DIR' 不存在"
    exit 1
fi

# 创建/清空输出文件
> "$FAILED_FILES"

# 添加计数器
SUCCESS_COUNT=0
FAIL_COUNT=0

# 查找并移除文件末尾的 #test
find "$SCAN_DIR" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
    # 跳过特殊目录
    if [[ "$file" == */proc/* ]] || [[ "$file" == */sys/* ]] || [[ "$file" == */dev/* ]] || [[ "$file" == */run/* ]] || [[ "$file" == */.git/* ]]; then
        continue
    fi
    
    # 检查文件是否有读写权限
    if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
        # 检查文件是否为文本文件
        if file "$file" | grep -q "text"; then
            # 检查文件末尾是否有 #test
            if tail -n 1 "$file" 2>/dev/null | grep -q "^#test$"; then
                # 创建临时文件
                temp_file=$(mktemp)
                
                # 复制文件内容到临时文件，除了最后一行
                head -n -1 "$file" > "$temp_file"
                
                # 替换原文件
                if mv "$temp_file" "$file" 2>/dev/null; then
                    echo "成功移除 #test: $file"
                    ((SUCCESS_COUNT++))
                else
                    echo "移除失败: $file"
                    realpath "$file" >> "$FAILED_FILES"
                    ((FAIL_COUNT++))
                fi
            fi
        fi
    else
        # 文件没有读写权限
        echo "无权限修改: $file"
        realpath "$file" >> "$FAILED_FILES"
        ((FAIL_COUNT++))
    fi
done

echo "处理完成："
echo "成功移除 #test 的文件数: $SUCCESS_COUNT"
echo "失败的文件数: $FAIL_COUNT"
echo "修改失败文件列表保存在 $FAILED_FILES"