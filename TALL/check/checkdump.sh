#!/bin/bash

> ../dumpdone.txt  # 清空旧文件
cd /cluster2/home/futing/Project/panCancer/TALL/debug/
for f in *_dump-*.log; do
    if ! grep -qi 'err' "$f"; then
        echo "${f%%_dump*}" >> ../dumperrdone.txt
    fi
done
