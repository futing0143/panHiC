#!/bin/sh
for ((i=1; i<1000; i++))
do
  d=`date '+%Y-%m-%d %H:%M:%S'`
  echo "$d 第 $i 次输出;"
  tt
  sleep 2s
done
name='joanna'
echo "Hello world, $name"
Bash