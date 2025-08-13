#!/bin/bash

# 设置输出文件
OUTPUT_FILE=$2
SCAN_DIR="$1"

# 检查参数
if [ $# -lt 2 ]; then
    echo "使用方法: $0 <目录路径> <错误文件列表> <修改失败文件列表>"
    exit 1
fi



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
    if [[ "$file" == */proc/* ]] || [[ "$file" == */sys/* ]] || [[ "$file" == */dev/* ]] || [[ "$file" == */run/* ]] || [[ "$file" == */.git/* ]]; then
        continue
    fi
    
    # 检查文件读取错误
    if head -n 3 "$file" 2>&1 | grep -q "Communication error on send\|Input/output error"; then
        realpath "$file" >> "$OUTPUT_FILE"
        continue
    fi
    
    # 尝试在文件末尾添加 #test
    if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
        # 检查文件是否为二进制文件
        if file "$file" | grep -q "text"; then
            # 尝试添加 #test 到文件末尾
            if (echo "" >> "$file" && echo "#test" >> "$file") 2>/dev/null; then
                echo "成功修改: $file"
            else
                echo "修改失败: $file"
                realpath "$file" >> "$OUTPUT_FILE"
            fi
        fi
    else
        # 文件没有读写权限
        echo "无权限修改: $file"
        realpath "$file" >> "$OUTPUT_FILE"
    fi
done


echo "扫描完成，读取错误文件保存在 $OUTPUT_FILE"
