##01 处理SV结果 conda activate eaglec
# find . -type f -name "*.CNN_SVs.5K_combined.txt" | while read i; do
#     # 获取基本文件名
#     base_name=$(basename "$i")
#     # 使用sed删除.CNN_SVs.5K_combined.txt及之后的部分
#     new_name=$(echo "$base_name" | sed 's/\.CNN_SVs\.5K_combined\.txt\(.*\)\?//')
# #    echo "Original: ${i}"
# #    echo "Modified: ${new_name}.CNN_SVs.5K_combined_uniq.txt"
#    # cat ${i} | awk '{print $1"\t"$4"\t"$2"\t"$5}' > result_SV/${new_name}.GFusion.txt
#    # annotate-gene-fusion --sv-file result_SV/${new_name}.GFusion.txt --output-file result_SV/${new_name}.gene-fusions.txt  --buff-size 10000 --skip-rows 0 --ensembl-release 93 --species human
#    awk -F'\t' '{
#         if (NF < 6) next;  # 跳过字段数小于6的行
#         key = $1 FS $2 FS $4 FS $5 FS $6;
#         if (!(key in seen)) {
#             print;
#             seen[key]++;
#         }
#     }' "$i" > "result_SV/SV/${new_name}.CNN_SVs.5K_combined_uniq.txt"
# done

###02 处理neo结果 conda activate neoloop
find . -type f -name "*.neo-loops.txt" | while read file; do
    # 定义输出文件的路径和文件名
    output_file="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/neoloop/$(basename ${file%.txt})_1.bedpe"
    awk '{if ($NF ~ /1$/) print}' "$file" > "$output_file"
done
cd /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/neoloop
awk 'BEGIN{OFS="\t"} {print $0,FILENAME}' *.bedpe | sed 's/\(.*\)\.neo-loops_1\.bedpe/\1/' > /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/result/EP_neoloop/merged.bedpe






#for i in `cat Gfusion_file` 
#do 
#cat ${i}| awk '{print $5}' > ${i%%.*}.GFusiononly.txt
#done

# for i in `cat neofile` 
# do 
# cat ${i}| awk -v T=${i%%.*} '{print $1":"$4"\t"T}' |sort |uniq -c >> neo_collect.txt
# done
#cat GF_collect.txt | awk '{print $3}' |sort|uniq -c >> GF_collect_count.txt
#cat GF_collect.txt | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$5":"$1}' >> GF_collect.txt
#delete first of them
#cat GF_collect.txt | awk '{print $6}' |sort|uniq -c > GF_collect_clvschr.txt

# for i in `cat file_combined.list` 
# do 
# #cat ${i}| awk '{print $1"\t"$4"\t"$2"\t"$5}' > ${i%%.*}.GFusion.txt
# #annotate-gene-fusion --sv-file ${i%%.*}.GFusion.txt --output-file ${i%%.*}.gene-fusions.txt  --buff-size 10000 --skip-rows 0 --ensembl-release 93 --species human

# cat ${i}| awk -v T=${i%%.*} '{if($1 == $2) {print $1"\t"$6"\t"T":""cis""\t""cis""\t"T}else{print $1"-"$2"\t"$6"\t"T":""trans""\t""trans""\t"T}}'  >> SV.txt
# done
# cat SV.txt | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$5":"$1"\t"$5":"$2}' >> SV_collect.txt
# cat SV_collect.txt | awk '{print $3}' |sort|uniq -c >> SV_Cis2Trans.txt
# cat SV_collect.txt | awk '{print $6}' |sort|uniq -c >> SV_chr.txt
# cat SV_collect.txt | awk '{print $7}' |sort|uniq -c >> SV_type.txt

