import cooler
import numpy as np
import sys

cool_file = sys.argv[1]  # 替换为你的文件
clr = cooler.Cooler(cool_file)

balance = True  # 或 False，根据你的 predictSV 参数
max_dis = 2000000 // clr.binsize  # 假设 max_dis 是 2Mb;50
N = 50  # 默认阈值

print(f"Resolution: {clr.binsize}")
print(f"Max distance (bins): {max_dis}")
print(f"Threshold N: {N}\n")

for chrom in clr.chromnames:
    print(f"\n{'='*60}")
    print(f"Chromosome: {chrom}")
    
    # 获取染色体大小和 bin 数
    chrom_bins = clr.bins().fetch(chrom).shape[0]
    print(f"  Bins: {chrom_bins}")
    
    # 检查数据量
    matrix = clr.matrix(balance=balance).fetch(chrom)
    total = np.nansum(matrix) if balance else matrix.sum()
    print(f"  Total contacts: {total:,.0f}")
    
    # 模拟计算对角线统计
    valid_distances = 0
    for i in range(min(max_dis+1, chrom_bins)):
        if balance:
            diag_data = np.diag(matrix, i)
            diag_data = diag_data[~np.isnan(diag_data)]
        else:
            diag_data = np.diag(matrix, i)
        
        n_pixel = len(diag_data)
        n_count = diag_data.sum()
        
        if n_pixel > N:
            valid_distances += 1
    
    print(f"  Valid distances (n_pixel > {N}): {valid_distances}/{min(max_dis+1, chrom_bins)}")
    
    if valid_distances == 0:
        print(f"  ⚠️  WARNING: NO valid distances! This chromosome will cause errors!")