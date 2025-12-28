#!/bin/bash


set -euo pipefail

file=
header=$(cooler dump -t bins --header "$file" 2>/dev/null | head -1 || true)
if echo "$header" | grep -qw "weight"; then
    echo "找到 weight"
else
    echo "未找到 weight"
fi
