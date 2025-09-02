###测试用，不用看
# pairToPair -a /cluster/home/tmp/GBM/HiC/10loop/mustache/DGCvsGSC.diffloop1.bedpe -b /cluster/home/tmp/GBM/HiC/10loop/mustache/DGCvsGSC.loop2.bedpe >DGC1vsGSC.all
# pairToPair -a /cluster/home/tmp/GBM/HiC/10loop/mustache/DGCvsGSC.diffloop2.bedpe -b /cluster/home/tmp/GBM/HiC/10loop/mustache/DGCvsGSC.loop1.bedpe >DGCvsGSC1.all
# awk '{print $7"\t"$15}' /cluster/home/tmp/GBM/HiC/10loop/mustache/test/DGC1vsGSC.all >heatmap.txt ##第1列DGC，第2列GSC
# awk '{print $15"\t"$7}' /cluster/home/tmp/GBM/HiC/10loop/mustache/test/DGCvsGSC1.all>>heatmap.txt
# awk 'BEGIN{print "DGC\tGSC"}{print}' heatmap.txt > temp.txt && mv temp.txt heatmap.txt
# pairToBed -a /cluster/home/tmp/GBM/HiC/10loop/mustache/test/DGC1vsGSC.all -b /cluster/home/jialu/genome/gencode.v38.pcg.bed.dedup > DGC1vsGSC.all.gene
# pairToBed -a /cluster/home/tmp/GBM/HiC/10loop/mustache/test/DGCvsGSC1.all -b /cluster/home/jialu/genome/gencode.v38.pcg.bed.dedup > DGCvsGSC1.all.gene
###测试用，不用看


#1.0将所有文件最后一列添加匹配行并去除首行
for file in *vsNPC.*1; do
    if [ -s "$file" ]; then
        # 使用sed命令去掉首行
        sed -i '1d' "$file" && \
        # 使用awk命令添加新的列
        awk -F'\t' '{
            new_column = $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6;
            print $0 "\t" new_column;
        }' "$file" > temp && \
        # 替换原文件
        mv temp "$file"
    else
        echo "Skipping $file: file is empty or does not exist."
    fi
done


#2.0
output_file="mtrixmid.txt"

# 确保输出文件为空
> "$output_file"

# 循环遍历当前目录下所有匹配模式的文件
for difffile in *vsNPC.diffloop1; do
    # 检查文件是否存在
    if [ -f "$difffile" ]; then

        awk '{print $NF}' "$difffile">> "$output_file"
    else
        echo "No files matched the pattern."
    fi
done

echo "Data appended to $output_file"

##3.0 添加首行和去除重复
sed -i '1i Differential loops ( = 673)' mtrixmid.txt
awk 'NR==1 {print}' mtrixmid.txt > mtrix.txt && awk 'NR>1 {print}' mtrixmid.txt | sort | uniq >> mtrix.txt



###4.0 loop anchor与CGC交集
# processed_matrix_halflog_pos.txt 是从python获得的
sed '1d' /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos.txt \
    > /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos.bedpe
pairToBed -a /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos.bedpe \
    -b /cluster/home/tmp/GBM/HiC/08TAD/filtered_Census_G.bed \
    -type either > /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_gene.bedpe 

##5.0只提取oncogene
grep -E "oncogene.*" /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_gene.bedpe \
    > /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_oncogene.txt
head -n 1 /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_oncogene.txt \
    | awk '{$0=$0"\tCGCchr\tCGCstt\tCGCend\tCGC\tCGCtype"}1' > temp.txt
tail -n +2 /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_oncogene.txt >> temp.txt
mv temp.txt /cluster/home/tmp/GBM/HiC/10loop/mustache/diffloop_NPC/diff/processed_matrix_halflog_pos_oncogene.txt
