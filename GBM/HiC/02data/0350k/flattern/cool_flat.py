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
    half_matrix = np.triu(mat)
    flattened=half_matrix[np.triu_indices_from(mat)]
    return flattened

flattened_data = []
for cooler_file in cooler_file_list:
    flattened_data.append(get_matrix(cooler_file))

flattened_list = np.column_stack(flattened_data)

#flattened_list.write("flattened_list.txt")
np.savetxt('flattened_list2.csv', flattened_list, delimiter='\t')  # 使用逗号作为分隔符保存为CSV格式
