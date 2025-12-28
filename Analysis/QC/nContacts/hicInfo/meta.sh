#!/bin/bash


d=$1
donemeta="/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo/hicInfo_${d}.txt" # check输出insul名单
mergemeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt # clean name & ctrl 的Meta
outputmeta="/cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo/hicInfocl_${d}.txt" # 添加了clean name的输出

cd /cluster2/home/futing/Project/panCancer/Analysis/conserve

# 按照前三列合并，加入 isctrl 信息
awk 'NR==FNR{key=$1"\t"$2"\t"$3; data[key]=$0; next}
{
  key=$1"\t"$2"\t"$3
  if(key in data)
     print data[key]"\t"$4
}' $mergemeta <(tail -n +2 $donemeta) >  $outputmeta



