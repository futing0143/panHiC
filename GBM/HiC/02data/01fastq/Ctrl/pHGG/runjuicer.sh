#ips文件夹下跑 conda activate juicer
#/cp /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/restriction_sites/hg38_MboI.txt /cluster/home/jialu/4DN_iPSc/pipeline/ref/hg38
for i in phgg23 phgg24 phgg 25
do
sh /cluster/home/jialu/4DN_iPSc/pipeline/mdg_pipe.sh ${in} -s Arima -g hg38 
done
