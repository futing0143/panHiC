# 输入：${i}_cis_100k.cis.vecs.tsv 
# 输入：/cluster/home/jialu/genome/gencode.v38.pcg.dedup.tss.bed：这是一个包含基因转录起始位点（TSS）的基因组注释文件。
# 输出：格式化后的 BED 文件：${i}.bed：通过 awk 命令从原始的 .tsv 文件生成的 BED 格式文件。
# TSS 交集文件：${i}_PCGtss_100k.txt：这些文件包含了通过 intersectBed 命令找到的 TSS 和 Hi-C 数据之间的交集信息。
# 合并后的数据文件：E1.txt：通过 paste 和 awk 命令合并了多个数据集的结果，展示了不同数据集中选定列的信息。
#for i in NPC GBMmerge pHGG ipsc 
#for i in NPC GBMmerge

# cat ../filename |while read i 
# do
# # ## sed -i '/chrY/d' ${i}_cis_100k.cis.vecs.tsv
# awk -F'\t'  '{print $1"\t"$2"\t"$3"\t"$(NF-2)}' ${i}_cis_100k.cis.vecs.tsv  >${i}.bed  ###只保留chr\stt\end\E1列
# # #cat ${i}.bed |awk '{if($4!="")print $0}' > ${i}_nona.bed  ###去掉没有E1值的行
# # #intersectBed -a /cluster/home/jialu/genome/gencode.v38.pcg.dedup.tss.bed -b ${i}_nona.bed -wb -loj |awk '{print $4"\t"$9}' > ${i}_PCGtss_100k.txt  ##以基因为单位的E1值
# done

# paste -d'\t' GBMmerge.bed NPC.bed pHGG.bed ipsc.bed GBM_common.bed GBMstem.bed |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$4,$8,$12,$16,$20,$24}' > E1_GBMmergeNpiDs.txt  
# awk 'NR==1{$4="GBMmerge";$5="NPC";$6="pHGG";$7="iPSC";$8="DGC";$9="GSC"}1' E1_GBMmergeNpiDs.txt > E1_GBMmergeNpiDs1.txt
# awk '{for(i=4;i<=10;i++){if($i=="") $i=0}} 1' E1_GBMmergeNpiDs1.txt >E1_GBMmergeNpiDs2.txt

paste -d'\t' A172.bed G523.bed GB176.bed GB180.bed GB182.bed GB183.bed GB238.bed GB567.bed GB583.bed SW1088.bed U118.bed U343.bed U87.bed ts543.bed ts667.bed |awk -F '\t' -v OFS='\t' '{print $1,$2,$3,$4,$8,$12,$16,$20,$24,$28,$32,$36,$40,$44,$48,$52,$56,$60}' > E1_GBMsample.txt  
awk 'NR==1{$4="A172";$5="G523*";$6="GB176";$7="GB180";$8="GB182";$9="GB183";$10="GB238";$11="GB567*";$12="GB583*";$13="SW1088";$14="U118";$15="U343";$16="U87";$17="ts543*";$18="ts667*"}1' E1_GBMsample.txt > E1_GBMsample1.txt
awk '{for(i=4;i<=10;i++){if($i=="") $i=0}} 1' E1_GBMsample1.txt >E1_GBMsample2.txt
