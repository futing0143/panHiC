import subprocess

# 读取 file.list 文件中的所有行到列表
with open('file.list', 'r') as file:
    filenames = file.readlines()

# 遍历列表中的每个文件名
for filename in filenames:
    # 去除文件名末尾的换行符
    filename = filename.strip()
    # 构建输出文件的基础名
    output_filename = f"{filename}vsNPC"
#    print({output_filename})
    # 构建并执行命令
    command = (
        f"python3 /cluster/home/jialu/biosoft/mustache-master/mustache/diff_mustache.py "
        f"-f1 /cluster/home/tmp/GBM/HiC/02data/03cool_KR/5000/{filename}.5000.KR.cool "
        f"-f2 /cluster/home/tmp/GBM/HiC/02data/03cool_KR/5000/NPC_new.5000.KR.cool "
        f"-pt 0.05 -pt2 0.1 -o {output_filename} -st 0.8 -r 5kb -norm weight"
    )
#    执行命令
    subprocess.run(command, shell=True)
