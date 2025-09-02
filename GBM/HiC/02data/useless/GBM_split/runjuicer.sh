#ips文件夹下跑 conda activate juicer
for i in U87 U343 SW1088 A172 U118
do
sh /cluster/home/jialu/4DN_iPSc/pipeline/mdg_pipe.sh ${i} -s MboI -g hg38 
done
