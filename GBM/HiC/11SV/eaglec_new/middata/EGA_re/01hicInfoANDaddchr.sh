##01 产生filename
# # 进入目标目录
# cd /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW

# # 清空或创建一个名为filename的文件
# > /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/filename

# # 使用for循环和basename命令来处理每个文件，并将结果追加到filename文件中
# for file in *-Arima-allReps-filtered.mcool; do
#   filename=$(basename "$file" | awk -F'-Arima-allReps-filtered.mcool' '{print $1}')
#   echo "$filename"  >> /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/filename
# done

#02检查是否都有chr的前缀和是否都是balance后，并将代码复制到每个文件夹
# while IFS= read -r i; do
# #  mkdir ${i}
# #	cp ../02for.sh ../slurm-predictSV.sh ${i}
#   cp slurm-predictSV.sh ${i}
# #  cp /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/A172/neoloop_slurm.sh ${i}
#     # for j in 50000 10000 5000; do
#     #     hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/GSE229962_RAW/${i}-Arima-allReps-filtered.mcool::/resolutions/${j}"
#     # done
# done < filename


##03定义包含文件夹名的文件路径
# folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/filename"

# # 检查文件夹名列表文件是否存在
# if [ -f "$folder_list" ]; then
#   # 逐行读取文件夹名
#   while IFS= read -r folder; do
#     # 定义slurm脚本的路径
#     script_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/${folder}/slurm-predictSV.sh"

#     # 检查slurm脚本是否存在
#     if [ -f "$script_path" ]; then
#       # 使用sed命令替换文件内容中的A172为文件夹名
#       sed -i "s/A172/${folder}/g" "$script_path"
#       sed -i "s/name1/${folder}/g" "$script_path"
#       echo "已更新 ${folder} 中的 slurm-predictSV.sh 文件。"
#     else
#       echo "在 ${folder} 中未找到 slurm-predictSV.sh 文件。"
#     fi
#   done < "$folder_list"
# else
#   echo "文件夹名列表文件不存在：$folder_list"
# fi


###04批量SV
# folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/filename"

# # 检查文件夹名列表文件是否存在
# if [ -f "$folder_list" ]; then
#   # 逐行读取文件夹名
#   while IFS= read -r folder; do
#     # 定义文件夹路径
#     folder_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/${folder}"

#     # 检查文件夹是否存在
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

##05修改neoloop.sh
# folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/filename"

# # 检查文件夹名列表文件是否存在
# if [ -f "$folder_list" ]; then
#   # 逐行读取文件夹名
#   while IFS= read -r folder; do
#     # 定义slurm脚本的路径
#     cp neoloop_slurm.sh ${folder}/neoloop_slurm.sh
#     script_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/${folder}/neoloop_slurm.sh"

#     # 检查slurm脚本是否存在
#     if [ -f "$script_path" ]; then
#       # 使用sed命令替换文件内容中的A172为文件夹名
#       sed -i "s/A172/${folder}/g" "$script_path"
#       echo "已更新 ${folder} 中的 neoloop_slurm.sh 文件。"
#     else
#       echo "在 ${folder} 中未找到 neoloop_slurm.sh 文件。"
#     fi
#   done < "$folder_list"
# else
#   echo "文件夹名列表文件不存在：$folder_list"
# fi


##06批量neoloop
folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/filename"

# 检查文件夹名列表文件是否存在
if [ -f "$folder_list" ]; then
  # 逐行读取文件夹名
  while IFS= read -r folder; do
    # 定义文件夹路径
    folder_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/EGA_re/${folder}"

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



