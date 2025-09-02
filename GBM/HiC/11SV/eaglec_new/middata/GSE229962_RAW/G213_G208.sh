#02检查是否都有chr的前缀和是否都是balance后，并将代码复制到每个文件夹
# for i in G213 G208; do
#   mkdir ${i}
# 	cp slurm-predictSV.sh ${i}
#   cp neoloop_slurm.sh ${i}
#   for j in 50000 10000 5000; do
#     hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/03cool/${j}/${i}_${j}.cool"
#   done
# done 


#04 批量SV
# folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/G213_G208"
# # 检查文件夹名列表文件是否存在
# if [ -f "$folder_list" ]; then
#   # 逐行读取文件夹名
#   while IFS= read -r folder; do
#     # 定义文件夹路径
#     folder_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/${folder}"

#     #检查文件夹是否存在
#     if [ -d "$folder_path" ]; then
#       echo "开始在 ${folder} 中运行 sbatch slurm-predictSV.sh 脚本。"
#       # 进入文件夹
#       cd "$folder_path" || { echo "无法进入目录 ${folder_path}"; continue; }

#       # 提交 16 个作业并记录作业ID
#       job_ids=()
#       for i in {1..16}; do
#         # 提交 slurm-predictSV.sh 脚本并获取作业ID
#         job_id=$(sbatch slurm-predictSV.sh | awk '{print $4}')
#         job_ids+=($job_id)
#         echo "已提交作业 $job_id，在 ${folder} 中。"
#         # 暂停 40 秒
#         sleep 40s
#       done

#       # 等待所有提交的作业完成
#       for job_id in "${job_ids[@]}"; do
#         echo "等待作业 $job_id 完成..."
#         squeue -j $job_id > /dev/null 2>&1
#         while [ $? -eq 0 ]; do
#           sleep 10s
#           squeue -j $job_id > /dev/null 2>&1
#         done
#         echo "作业 $job_id 已完成。"
#       done
      
#       echo "${folder} 中的所有作业已完成。"
      
#       # 回到上级目录
#       cd - || { echo "无法返回上级目录"; exit 1; }
#     else
#       echo "${folder_path} 文件夹不存在。"
#     fi
#   done < "$folder_list"
# else
#   echo "文件夹名列表文件不存在：$folder_list"
# fi

# ##07 批量neoloop
folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/G213_G208"
# 检查文件夹名列表文件是否存在
if [ -f "$folder_list" ]; then
  # 逐行读取文件夹名
  while IFS= read -r folder; do
    folder_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/${folder}"

    # 检查文件夹是否存在
    if [ -d "$folder_path" ]; then
      echo "开始在 ${folder} 中运行 sbatch neoloop_slurm.sh 脚本。"
      # 进入文件夹
      cd "$folder_path" || { echo "无法进入目录 ${folder_path}"; continue; }

      # 提交 slurm-predictSV.sh 脚本并获取作业ID
      job_id=$(sbatch neoloop_slurm.sh | awk '{print $4}')
      echo "已提交作业 $job_id，在 ${folder} 中。"

      # 等待提交的作业完成
      echo "等待作业 $job_id 完成..."
      squeue -j $job_id > /dev/null 2>&1
      while [ $? -eq 0 ]; do
        sleep 10s
        squeue -j $job_id > /dev/null 2>&1
      done
      echo "作业 $job_id 已完成。"

      echo "${folder} 中的作业已完成。"

      # 回到上级目录
      cd - || { echo "无法返回上级目录"; exit 1; }
    else
      echo "${folder_path} 文件夹不存在。"
    fi
  done < "$folder_list"
else
  echo "文件夹名列表文件不存在：$folder_list"
fi
