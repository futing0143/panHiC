import os
from joblib import Parallel, delayed


script = '/cluster/home/futing/Project/GBM/RNA/merge/rsem.sh'
filedir = '/cluster/home/futing/Project/GBM/RNA/sample/20240830/analysis'

task = []
# for file in os.listdir(fastq):
#     if file.endswith('fastq'):
#         target = os.path.join(fastq, file)
#         task.append(target)
for root, dirs, files in os.walk(filedir):
    for dir_name in dirs:
        # 获取子目录的完整路径
        full_path = os.path.join(root, dir_name)
        # 将子目录的名称（最后一级目录名）添加到 task 中
        print(f'Apending {dir_name}...')
        task.append(dir_name)
    break  # 只遍历 fastq 目录下的直接子目录，不递归进入子目录的子目录
        
Parallel(n_jobs=3)(delayed(os.system)('bash {} {}'.format(script, target)) for target in task)
# cmd = 'bash {} {}'.format(script, target)
# print(cmd)
# os.system(cmd)