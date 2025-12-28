#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/check/meta
cldata=/cluster2/home/futing/Project/panCancer/check/meta/panCan_clname.txt	# cancer gse cell clean name
# ctrlmeta=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/cell_list/cell_list_all.txt # cancer gse cell isctrl
ctrlmeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_ctrl.txt
treated=/cluster2/home/futing/Project/panCancer/check/meta/panCan_treated.txt
panCan=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
panCanmeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_annometa.txt # 包含 cancer, gse, cell, ncell 信息


# 01 处理新的clean name
grep -w -v -F -f <(cut -f1-3 $cldata) <(cut -f1-3 $panCan) \
	| awk 'BEGIN{FS=OFS="\t"}{print $0,$3}'|sort -k1 -k2 -k3 >> $cldata
# 02 处理ctrl信息
# 看/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta.sh 懒得改了
search_anno=/cluster2/home/futing/Project/panCancer/Analysis/dchic/meta/cell_list/cell_list_annotated.txt
panmeta=/cluster2/home/futing/Project/panCancer/check/meta/panCan_meta.txt
ctrl=/cluster2/home/futing/Project/panCancer/check/meta/panCan_ctrl.txt
awk 'NR==FNR{
    key=$1"\t"$3
    data[key]=data[key] ? data[key]"\n"$0 : $0   # 用换行符拼接多行
    next
}
{
    key=$1"\t"$2
    if(key in data){
        n=split(data[key], lines, "\n")
        for(i=1;i<=n;i++)
            print lines[i]"\t"$3
    } else {
        print $0"\tNA"
    }
}' $panmeta $search_anno > $ctrl


# 03 istreated 的信息
# cut -f1-3,7 $panCan_annometa > $treated
grep -w -v -F -f <(cut -f1-3 $treated) <(cut -f1-3 $panCan) \
	| awk 'BEGIN{FS=OFS="\t"}{print $0,"0"}' >> $treated


#------------- 合并
# 两两join，按前三列合并
awk 'BEGIN{FS=OFS="\t"}
FILENAME==ARGV[1] {
  key = $1 SUBSEP $2 SUBSEP $3
  cleanname[key] = $4
  next
}
FILENAME==ARGV[2] {
  key = $1 SUBSEP $2 SUBSEP $3
  isctrl[key] = $5
  next
}
FILENAME==ARGV[3] {
  key = $1 SUBSEP $2 SUBSEP $3
  if (key in cleanname && key in isctrl) {
    print $1, $2, $3, cleanname[key], isctrl[key], $4
  }
}' ${cldata} ${ctrlmeta} <(cut -f1-4 ${treated}) > ${panCanmeta}

# 处理 Blacklist 20/493(25/502)
sort -k7,7n /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo/hicInfocl_1120.txt \
	| head -n 20 | cut -f1-3 | sort -u > ./meta/blacklist.txt


# 按照前三列合并，加入 isctrl 信息
# awk 'NR==FNR{key=$1"\t"$2"\t"$3; data[key]=$0; next}
# {
#   key=$1"\t"$2"\t"$3
#   if(key in data)
#      print data[key]"\t"$4
# }' <(tail -n +2 $cldata) $ctrlmeta  >  $panCanmeta

# 添加unique cell_number 信息
awk -F',' 'BEGIN{FS=OFS="\t"}{
    count[$4]++
    if (count[$4]==1) {
        uniq=$4
    } else {
        uniq=$4"_"count[$4]
    }
    print $0,uniq
}' $panCanmeta > tmp && mv tmp $panCanmeta

