import os
from joblib import Parallel, delayed
import pandas as pd
import numpy as np

script = '/cluster/home/futing/Project/panCancer/CRC/sbatch_post.sh'
meta = pd.read_csv(
    '/cluster/home/futing/Project/panCancer/CRC/check/CRC_meta_runpost_check2.txt',
    header=None,          # 无列名
    names=['cell','tools'],  # 手动指定列名
    sep='\t',             # 如果是制表符分隔，改为 sep='\t'
)
tasks = [(row['cell'], row['tools']) for _, row in meta.iterrows()]

# 并行执行任务
results = Parallel(n_jobs=2)(
    delayed(os.system)('bash {} {} {}'.format(script, tools, cell))
    for cell,tools in tasks
)
