#!/bin/bash
data_dir=/cluster/home/futing/Project/GBM/HiC/02data/0350k
find $name -name '*kr.ct.cool' |while read i;do
    name=$(basename $i _50k.kr.ct.cool)
    echo -e "Processing ${i} and ${name}"
    cooltools insulation $i -o ${data_dir}/${name}_insul.tsv  --ignore-diags 2 --verbose 800000
done 

stem=G523,GB567,GB583,ts543,ts667,
nonstem=A172,GB176,GB180,GB182,GB183,GB238,SW1088,U118,U343,U87,

# ------------------- 孙处理后的cool文件的insulation score
#------------- 处理insulation score
paste -d'\t' ${stem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42}' > stem_insulation.txt 
stem_tab=$(echo -e "$(echo "$stem" | tr ',' '\t')\n") # 将 stem 中的逗号替换为制表符
# 使用 awk 进行替换，并将结果重定向到文件中
awk -v stem="$stem_tab" 'BEGIN{FS=OFS="\t"} NR==1{$4=stem; for(i=5;i<=NF;i++) $i=""} 1' stem_insulation.txt > stem_insulation.tmp
#awk 'NR==1{$4="G523";$5="G567";$6="GB583";$7="ts543";$8="ts667"}1' stem_insulation.txt  > stem_insulation.tmp
# 这样末尾会有多余的制表符，需要去掉
awk 'BEGIN{FS=OFS="\t"} {for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' stem_insulation.tmp > stem_insulation.txt


paste -d'\t' ${nonstem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42,$51,$60,$69,$78,$87}' > nonstem_insulation.txt 
nonstem_tab=$(echo -e "$(echo "$nonstem" | tr ',' '\t')\n")
awk -v nonstem="$nonstem_tab" 'BEGIN{FS=OFS="\t"}NR==1{$4=nonstem; for(i=5;i<=NF;i++) $i=""} 1' nonstem_insulation.txt > nonstem_insulation.tmp
awk 'BEGIN{FS=OFS="\t"}{for(i=4;i<=14;i++){if($i=="nan") $i=0}} 1' nonstem_insulation.tmp > nonstem_insulation.txt

##------------ 处理 boundary_strength
paste -d'\t' ${stem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$8,$17,$26,$35,$44}' > stem_boundary.txt 
stem_tab=$(echo -e "$(echo "$stem" | tr ',' '\t')\n") # 将 stem 中的逗号替换为制表符
# 使用 awk 进行替换，并将结果重定向到文件中 这样末尾会有多余的制表符，需要去掉
awk -v stem="$stem_tab" 'BEGIN{FS=OFS="\t"} NR==1{$4=stem; for(i=5;i<=NF;i++) $i=""} {gsub(/\t+$/, ""); print}' stem_boundary.txt > stem_boundary.tmp
awk 'BEGIN{FS=OFS="\t"} {for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' stem_boundary.tmp > stem_boundary.txt


paste -d'\t' ${nonstem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$8,$17,$26,$35,$44,$53,$62,$71,$80,$89}' > nonstem_boundary.txt 
nonstem_tab=$(echo -e "$(echo "$nonstem" | tr ',' '\t')\n")
awk -v nonstem="$nonstem_tab" 'BEGIN{FS=OFS="\t"}NR==1{$4=nonstem; for(i=5;i<=NF;i++) $i=""}  {gsub(/\t+$/, ""); print}' nonstem_boundary.txt > nonstem_boundary.tmp
awk 'BEGIN{FS=OFS="\t"}{for(i=4;i<=14;i++){if($i=="nan") $i=0}} 1' nonstem_boundary.tmp > nonstem_boundary.txt

##------------ 处理 old insulation
paste -d'\t' ${stem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42}' > stem_insulation.txt 
stem_tab=$(echo -e "$(echo "$stem" | tr ',' '\t')\n") # 将 stem 中的逗号替换为制表符
# 使用 awk 进行替换，并将结果重定向到文件中 这样末尾会有多余的制表符，需要去掉
awk -v stem="$stem_tab" 'BEGIN{FS=OFS="\t"} NR==1{$4=stem; for(i=5;i<=NF;i++) $i=""} {gsub(/\t+$/, ""); print}' stem_insulation.txt > stem_insulation.tmp
awk 'BEGIN{FS=OFS="\t"} {for(i=4;i<=10;i++){if($i=="nan") $i=0}} 1' stem_insulation.tmp > stem_insulation.txt


paste -d'\t' ${nonstem//,/\_insul.tsv } |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$6,$15,$24,$33,$42,$51,$60,$69,$78,$87}' > nonstem_insulation.txt 
nonstem_tab=$(echo -e "$(echo "$nonstem" | tr ',' '\t')\n")
awk -v nonstem="$nonstem_tab" 'BEGIN{FS=OFS="\t"}NR==1{$4=nonstem; for(i=5;i<=NF;i++) $i=""}  {gsub(/\t+$/, ""); print}' nonstem_insulation.txt > nonstem_insulation.tmp
awk 'BEGIN{FS=OFS="\t"}{for(i=4;i<=14;i++){if($i=="nan") $i=0}} 1' nonstem_insulation.tmp > nonstem_insulation.txt