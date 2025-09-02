import glob
import numpy as np
import cooler
import pandas as pd

data_dir = "/cluster/home/futing/Project/GBM/HiC/02data/0350k"
cooler_file_list = glob.glob(f"{data_dir}/**/*.ct.cool", recursive=True)


def get_matrix(cooler_file):
    c = cooler.Cooler(cooler_file)
    print(f'Processing {cooler_file}')

    mat = c.matrix(balance=True)[:]
    ###获取距离对角线0-10的数据并降成一维
    diagonal_data = [np.diag(mat, k) for k in range(0, 10)]
    return diagonal_data

#flattened_data = []
#for cooler_file in cooler_file_list:
#    flattened_data.append(get_matrix(cooler_file))
#flattened_list = np.column_stack(flattened_data)
#np.savetxt('flattened_list2.csv', flattened_list, delimiter='\t')  # 使用逗号作为分隔符保存为CSV格式

output_file = 'flattened_list2.csv'
with open(output_file, 'w') as f:
    for cooler_file in cooler_file_list:
        diagonal_data = get_matrix(cooler_file)
        flattened_data = np.concatenate(diagonal_data)
        np.savetxt(f, [flattened_data], delimiter='\t')