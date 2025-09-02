##01 最后6个文件改名
# folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/left"

# # 检查文件夹名列表文件是否存在
# if [ -f "$folder_list" ]; then
#   # 逐行读取文件夹名
#   while IFS= read -r folder; do
# #    cp slurm-predictSV.sh ${folder}
#     cp neoloop_slurm.sh ${folder}
#     script_path="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/${folder}/neoloop_slurm.sh"

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

##02批量neoloop
folder_list="/cluster/home/tmp/GBM/HiC/11SV/eaglec_new/GSE229962_RAW/left"

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

