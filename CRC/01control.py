import os
from joblib import Parallel, delayed
import pandas as pd
import numpy as np

script = '/cluster2/home/futing/Project/panCancer/CRC/sbatch.sh'
meta = pd.read_csv(
    # '/cluster/home/futing/Project/panCancer/CRC/CRC_meta_runpost.txt',
	# '/cluster/home/futing/Project/panCancer/CRC/CRC_metap2.txt',
	'/cluster2/home/futing/Project/panCancer/CRC/meta/ctrl_meta.txt',
    header=None,          # 无列名
    names=['gse', 'cell', 'enzyme'],  # 手动指定列名
    sep=',',             # 如果是制表符分隔，改为 sep='\t'
)
tasks = [(row['gse'], row['cell'], row['enzyme']) for _, row in meta.iterrows()]

# 并行执行任务
results = Parallel(n_jobs=2)(
    delayed(os.system)('bash {} {} {} {}'.format(script, gse, cell, enzyme))
    for gse, cell, enzyme in tasks
)
