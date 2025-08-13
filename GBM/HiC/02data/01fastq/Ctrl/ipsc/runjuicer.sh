#ips文件夹下跑 conda activate juicer
#/cp /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/restriction_sites/hg38_MboI.txt /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38
# 原本是每个fastq跑一次，这个脚本已无用
for i in ips1 ips2
do
sh /cluster/home/jialu/4DN_iPSc/pipeline/mdg_pipe.sh ${i} -s DpnII -g hg38 
done
