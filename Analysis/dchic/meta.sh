#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/dchic
# 生成 ./meta/cell_list/cell_list.txt
cut -f1-3 /cluster2/home/futing/Project/panCancer/check/meta/ctrl_merge.txt | sort -u > ./meta/cell_list/cell_list_ctrl.txt
awk 'BEGIN{FS=OFS="\t"} {print $1,$2,$3,1}' ./meta/cell_list/cell_list_ctrl.txt >> tmp && mv tmp ./meta/cell_list/cell_list_ctrl.txt
cut -f1-3 /cluster2/home/futing/Project/panCancer/check/meta/cancer_meta.txt | sort -u > ./meta/cell_list/cell_list_unctrl.txt
cut -f1-3 /cluster2/home/futing/Project/panCancer/check/meta/done_meta.txt | sort -u >> ./meta/cell_list/cell_list_unctrl.txt
awk 'BEGIN{FS=OFS="\t"} {print $1,$2,$3,0}' ./meta/cell_list/cell_list_unctrl.txt >> tmp && mv tmp ./meta/cell_list/cell_list_unctrl.txt
cat ./meta/cell_list/cell_list_ctrl.txt ./meta/cell_list/cell_list_unctrl.txt | sort -u > ./meta/cell_list/cell_list_all.txt
rm ./meta/cell_list/cell_list_ctrl.txt ./meta/cell_list/cell_list_unctrl.txt

# ------- 检查 preprocess --------
input=/cluster2/home/futing/Project/panCancer/check/post/hicdone${d}.txt
# cat ./meta/prepro/predone_1016.txt ./meta/prepro/predone${d}.txt | sort -u > ./meta/prepro/predone.txt # 所有转换完成的样本
cat ./meta/prepro/predone.txt ./meta/prepro/predone1030p1.txt | sort -u > tmp && mv tmp ./meta/prepro/predone.txt
grep -v -w -F -f ./meta/prepro/predone.txt <(grep '_2500000.cool' $input | cut -f1-3) > ./meta/prepro/predone${d}p1.txt # 所有需要转换的样本

# -------- 检查 PCA，生成 input_undone.txt --------
cut -f1 input.txt | awk 'BEGIN{FS="/";OFS="\t"}{print $7,$8,$9}' | sort -u > ./meta/cell_list/cell_listdone.txt
grep -F -v -w -f ./meta/cell_list/cell_listdone.txt <(grep '_2500000.cool' $input | cut -f1-3) > ./meta/cell_list/cell_listundone${d}.txt

# -------- 转换 ./meta/cell_list/cell_list.txt 为 input.txt
grep -F -f ./meta/cell_list/cell_listundone${d}.txt ./meta/cell_list/cell_list_all.txt > tmp && mv tmp ./meta/cell_list/cell_list${d}.txt
# join -t $'\t' -1 3 -2 1 -o 1.1,1.2,1.3,2.2 "${input}" ./meta/cell_list/cell_list.tsv > tmp && mv tmp ./meta/cell_list/cell_list.txt
dir=/cluster2/home/futing/Project/panCancer/

awk -v dir="$dir" 'BEGIN{FS=OFS="\t"} 
{
    if ($4 == "0") {
        print dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000.matrix", \
              dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000_abs.bed", \
              $2"_"$3, $1
    } 
    else if ($4 == "1") {
        print dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000.matrix", \
              dir $1 "/" $2 "/" $3 "/cool/" $3 "_100000_abs.bed", \
              $2"_"$3, $1 "_ctrl"
    }
}' ./meta/cell_list/cell_list${d}.txt > input${d}.txt

# # BCBL1_TREx-KRta_NoDox 和 BCBL1_TREx-KRta_Dox 数据质量较差，先不做 dcHiC 分析
grep -v 'BCBL1_TREx-KRta_NoDox' input${d}.txt | grep -v 'BCBL1_TREx-KRta_Dox' > tmp && mv tmp input${d}.txt

# ------- 先检查所有的 matrix，再跑run_dchic.sh -------
cat input${d}.txt | while read matrix bed prefix cancer; do
	if [ ! -f "$matrix" ] || [ ! -f "$bed" ]; then
		echo "Missing file for $prefix in $cancer"
	fi
done

# --------- 找到所有的已经做完 PCA 的癌种
ls /cluster2/home/futing/Project/panCancer/Analysis/dchic/pca/*_cor.txt \
	| xargs -n1 basename | sed 's/_cor\.txt$//' | sort -u > cancer_listdone.txt



# 娜姐的数据
cd /cluster2/home/futing/Project/panCancer/Analysis/dchic/meta
grep -F -f <(cut -f2 ATAC.txt) data_metainfo.csv | cut -f2-11 -d ',' | sort -t',' -k8,8 -k7,7 > ATAC_meta.txt
awk -F',' '{
    cell=$8
    type=$7
    if(type=="ChIP"){has_chip[cell]=1}
    if(type=="Input"){has_input[cell]=1}
    lines[cell]=lines[cell] $0 ORS
}
END{
    for(c in lines){
        if(has_chip[c] && has_input[c]) printf "%s", lines[c]
    }
}' /cluster2/home/futing/Project/panCancer/Analysis/dchic/ATAC_meta.txt \
> tmp && mv tmp /cluster2/home/futing/Project/panCancer/Analysis/dchic/ATAC_meta.txt

# 手动删除 input 和 ChIP的关系
