# awk -v FS=' ' '{print $1}' gselist >gse.list
# rm gselist

import subprocess

# 第一步：从 GSE 编号转换为 SRP 编号，并写入 srp.list 文件
with open('gse.list', 'r') as file, open('srp.list', 'w') as srp_file:
    gse_numbers = file.read().splitlines()

    for gse in gse_numbers:
        gse = gse.strip()
        if not gse:  # 跳过空行
            continue
        # 调用 pysradb gse-to-srp 命令
        result = subprocess.run(['pysradb', 'gse-to-srp', gse], capture_output=True, text=True)
        if result.returncode == 0:  # 检查命令是否成功执行
            # 过滤掉标题行并写入有效 SRP 数据
            for line in result.stdout.splitlines():
                if not line.startswith('s'):
                    srp_file.write(line + '\n')
        else:
            print(f"Error processing {gse}: {result.stderr}")

# 第二步：获取 SRP Meta 数据并写入 SRRmeta.txt 文件
with open('srp.list', 'r') as srp_file, open('SRRmeta.txt', 'w') as output_file:
    srp_numbers = srp_file.read().splitlines()

    for srp in srp_numbers:
        # 调用 pysradb metadata 命令
        result = subprocess.run(['pysradb', 'metadata', srp], capture_output=True, text=True)
        if result.returncode == 0:  # 检查命令是否成功执行
            output_file.write(result.stdout + '\n')
        else:
            print(f"Error processing {srp}: {result.stderr}")


awk '{print $0";"}' OPC.list >OPC1.list
grep -Ff OPC1.list SRRmeta.txt | awk -F '\t' '{print $22}' > opc_srr.list
grep -Ff OPC1.list SRRmeta.txt | awk -F '\t' '{print $4, $22, $1}' > opc_srr_match.list

awk -F '\t' 'NR==FNR {srp_map[$2] = $1; next} {print $0, srp_map[$3]}' OFS='\t' srp.list opc_srr_match.list > opc_srr_match_with_gse.list
awk 'NR==FNR {tech_map[$1] = $2; next} {print $0, tech_map[$4]}' gse_tech.list FS='\t' OFS='\t' opc_srr_match_with_gse.list > opc_srr_match_with_gse_tech.list
awk -F '\t' '{print $2"\t"$4"\t"$5}' /cluster/home/tmp/GBM/HiC/02data/01fastq/snm3C/2024/opc_srr_match_with_gse_tech.list > srr_gse_tech.txt
