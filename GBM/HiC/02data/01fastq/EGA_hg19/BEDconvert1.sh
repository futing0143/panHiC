# #!/bin/bash

# 指定的路径
# base_dir="/cluster/home/tmp/gaorx/GBM/GBM"

# # 遍历指定路径下的所有子目录
# find "$base_dir" -type d | while read dir; do
#     if [ -f "$dir/merged_nodups_hg19.txt" ]; then   
#         awk '{print $0, NR}' "$dir/merged_nodups_hg19.txt" > "$dir/merged_nodups_hg19NR.bed"     
#         awk '{print $2"\t"($3-1)"\t"$3"\t"NR}' "$dir/merged_nodups_hg19.txt" > "$dir/HG19_read1.bed"
#         awk '{print $6"\t"($7-1)"\t"$7}' "$dir/merged_nodups.txt" > "$dir/HG19_read2.bed"
#         /cluster/home/jialu/biosoft/liftOver "$dir/HG19_read1.bed" /cluster/home/jialu/biosoft/hg19ToHg38.over.chain.gz "$dir/HG38_read1.bed" "$dir/HG38_read1_unmap.bed" 

#     fi
# done

# while read -r i
# do
#     echo "start ${i}"
#     awk 'BEGIN {OFS="\t"}
#                  (FNR==NR) {
#                      a[$NF] = $2;
#                      next;
#                  }
#                  ($NF in a) {
#                      $7 = a[$NF];
#                      print;
#                  }' "${i}/HG38_read2.bed" "${i}/merged_nodups_hg19NR.bed" > "${i}/tmp.txt"
#     echo "part2 of ${i} has been done"
#     awk 'BEGIN {OFS="\t"}
#                  (FNR==NR) {
#                      a[$NF] = $2;
#                      next;
#                  }
#                  ($NF in a) {
#                      $3 = a[$NF];
#                      print;
#                  }' "${i}/HG38_read1.bed" "${i}/tmp.txt" > "${i}/merged_nodups.txt"
#     echo "part1 of ${i} has been done"
# done < file1

#find . -type d -name "P*" >filename ###删掉P455.因为已经单独测试


# 读取filename文件中的每一行
# while IFS= read -r folder; do
#     # 检查文件夹是否存在
#     if [ -d "$folder" ]; then
#         # 在文件夹下创建mega文件夹，如果已存在则忽略
#         mkdir -p "$folder/mega"

#         # 检查aligned文件夹是否存在
#         if [ -d "$folder/aligned" ]; then
#             # 检查文件是否存在
#             file1="$folder/aligned/merged_nodups.txt"
#             file2="$folder/aligned/inter_30.txt"
#             file3="$folder/aligned/inter.txt"

#             # 检查所有文件都存在
#             if [ -f "$file1" ] && [ -f "$file2" ] && [ -f "$file3" ]; then
#                 # 在mega目录下创建aligned文件夹
# #                echo "file exist"
#                 mkdir -p "$folder/mega/aligned"
#                 # 移动文件
#                 mv "$file1" "$folder/mega/aligned/"
#                 mv "$file2" "$folder/mega/aligned/"
#                 mv "$file3" "$folder/mega/aligned/"
#                 echo "Moved files to mega/aligned in $folder"
#             else
#                 echo "Not all files exist in $folder/aligned"
#             fi
#         else
#             echo "aligned folder does not exist in $folder"
#         fi
#     else
#         echo "Folder $folder does not exist."
#     fi
# done < "filename"



#!/bin/bash

# 读取 filename 文件中的每个路径
# while read -r file; do
# #     # echo "Processing $file"
#     cd "$file"
# #     # mv mega/aligned/merged_nodups.txt mega/aligned/merged_nodups1.txt
# #     # awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}' mega/aligned/merged_nodups1.txt > mega/aligned/merged_nodups.txt
    
# #    mv mega/aligned/merged_nodups.txt mega/aligned/merged_nodups_t.txt
# #    awk '{ gsub(/\t/, " "); print }' mega/aligned/merged_nodups_t.txt > mega/aligned/merged_nodups.txt
# #     # # 调用 mega1.sh 脚本
#     /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/mega1.sh -d "$file"  -g /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome -s /cluster/home/tmp/EGA/hg38_Arima.txt -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer 
 
#         #    hicConvertFormat -m /cluster/home/tmp/gaorx/GBM/GBM/${file}/mega/aligned/inter_30.hic --inputFormat hic --outputFormat cool -o /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/EGA/${file}.mcool
#     # /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/juicer.sh \
#     # -S final \
#     # -g hg38 \
#     # -d "$file/mega" \
#     # -p /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.genome \
#     # -y /cluster/home/tmp/EGA/hg38_Arima.txt \
#     # -z /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38/hg38.fa \
#     # -D /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer 
# done < test

#cat /cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9/mega/aligned/merged_nodups1.txt  | awk '{print NF}' >P524.SF12681v9_NF
#awk '{ if ($3 ~ /[^0-9]/ || $7 ~ /[^0-9]/) print $0 }' /cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9/mega/aligned/merged_nodups.txt >P524.SF12681v9_illi

# ls /cluster/home/tmp/EGA/EGAD00001010312/*/P524.SF12681v9.hic.bam | while read line 
# do 
#     file_name=$(basename $line)
#     dir=${file_name%.hic.bam}
#     mkdir -p ${dir}/fastq ${dir}/splits
#     touch ${dir}/fastq/${file_name}_R1.fastq ${dir}/fastq/${file_name}_R2.fastq
#     cd ${dir}/splits
#     ln -s ../fastq/* .
#     cd ../.. 
# done


ls /cluster/home/tmp/EGA/EGAD00001010312/*/P524.SF12681v9.hic.bam | while read line
do
    file_name=$(basename $line)
    dir=${file_name%.hic.bam}
    sam=$dir/splits/${dir}.hic.sam
#    samtools view -h -o $sam -O SAM $line
    /cluster/home/Gaoruixiang/software/juicer/scripts/juicer.sh \
    -S chimeric \
    -g hg19 \
    -d /cluster/home/tmp/gaorx/GBM/GBM/$dir \
    -s Arima \
    -p /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19.chrom.sizes\
    -y /cluster/home/Gaoruixiang/software/juicer/restriction_sites/hg19_Arima.txt\
    -z /cluster/home/Gaoruixiang/software/juicer/references/hg19.fa\
    -D /cluster/home/Gaoruixiang/software/juicer > $dir/juicer.log
done



