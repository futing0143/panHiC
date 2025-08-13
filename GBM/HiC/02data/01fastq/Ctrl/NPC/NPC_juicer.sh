#ips文件夹下跑 conda activate juicer
nohup sh /cluster/home/jialu/4DN_iPSc/pipeline/mdg_pipe.sh NPC \
-s Arima -g hg38 -S final >> NPC_out.txt 2>&1 &