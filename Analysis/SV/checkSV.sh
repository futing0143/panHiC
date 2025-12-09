#!/bin/bash
cd /cluster2/home/futing/Project/panCancer/Analysis/SV

# 正在跑的 cancer gse cell
> "./meta/runningSV/SV_running_cell${d}.txt"
squeue -n predictSV -h -o "%i" > ./meta/runningSV/SV_running${d}.txt
cat ./meta/runningSV/SV_running${d}.txt | while read -r id;do
	log=/cluster2/home/futing/Project/panCancer/Analysis/SV/debug/SV-${id}.log
	grep '# Path to mcool = ' ${log} | sed 's/# Path to mcool = //g' \
		| cut -f7-9 -d '/' | sed 's/\//\t/g' >> ./meta/runningSV/SV_running_cell${d}.txt
done

# 把没跑的输入给
sed -n '18,133p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1027p1.txt >> ./meta/runningSV/SV_running_cell${d}.txt
sed -n '111,133p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1029p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt
sed -n '50,112p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1029p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt
sed -n '81,133p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1029p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1105
sed -n '104,133p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1029p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1107
sed -n '41,76p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1105p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1107
sed -n '16,20p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1107p1.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1108
sed -n '14,39p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1120p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1122
sed -n '18,39p' /cluster2/home/futing/Project/panCancer/Analysis/SV/SV_unrun1120p2.txt >> ./meta/runningSV/SV_running_cell${d}.txt #1122

# 剩下的就是unrun
blacklist=/cluster2/home/futing/Project/panCancer/check/meta/blacklist.txt
# sort -k4,4n /cluster2/home/futing/Project/panCancer/Analysis/QC/nContacts/hicInfo/hicInfo_1106.txt | head -n 15 | cut -f1-3 | sort -u > ./meta/blacklist.txt
grep -F -v -w -f ./meta/runningSV/SV_running_cell${d}.txt ./meta/unSV/SV_${d}.txt > tmp 
grep -F -v -w -f $blacklist tmp | cut -f1-3 | sort -u > SV_unrun${d}.txt

grep -F -v -w -f $blacklist ./meta/unSV/SV_${d}.txt | cut -f1-3 | sort -u > SV_unrun${d}.txt


# grep -F -v -w -f SV_post1027.txt tmp | cut -f 1-3 > SV_unrun${d}.txt
sed -n '1,40p' SV_unrun${d}.txt > SV_unrun${d}p1.txt
sed -n '41,79p' SV_unrun${d}.txt > SV_unrun${d}p2.txt



# -------- post post 处理
ls SV-+([0-9])_[0-9].log | cut -f1 -d '_' | cut -f2 -d '-' | sort -u > ids1123.txt
cat ids1123.txt | while read -r id;do
	mkdir -p ${id}
	mv SV-${id}_+([0-9]).log ./${id}/
done

# 处理所有的log 文件
find /cluster2/home/futing/Project/panCancer/Analysis/SV/debug -maxdepth 1 -name "SV*.log" -type f | while read -r log;do
echo "processing $log"
jid=$(basename "$log" .log | cut -f2 -d '-')
grep '# Path to mcool = ' "${log}" | sed 's/# Path to mcool = //g' | cut -f7-9 -d '/' | sed 's/\//\t/g' | sed "s/$/\t$jid/" >> log_id1112.txt
done