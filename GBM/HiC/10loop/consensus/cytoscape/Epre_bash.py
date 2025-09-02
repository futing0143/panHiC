import os
import argparse
import time
import pandas as pd
import numpy as np

# 用于 loop 和 enhancer 取交集，并将Enhancer peak储存为loop anchor的形式
# 输入 loop bedpe enhancer bed 
# 输出 ${name}_Eweights_bash.bed: 'chr','start','end','weights','occurrences','ebin'
# by futing at Feb 10


parser = argparse.ArgumentParser(description="传入name")
parser.add_argument('name', type=str, help="sample same")
args = parser.parse_args()
name=args.name

# 时间
start_time= time.time()

# 01 衡量开始时间
script='/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/Einter.sh'
os.system('mkdir -p /cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{}'.format(name))
cmd = 'bash {} {}'.format(script, name)
print(cmd)
os.system(cmd)

Einter=pd.read_csv(f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_intersect.bedpe',sep='\t',header=None)
Einter.columns=['chr1','start1','end1','chr2','start2','end2','cloop','chr_e','start_e','end_e','sample','occurrences']

# 02 确认enhancer节点
fil1=(Einter['chr1']==Einter['chr_e']) & (Einter['start1']<=Einter['end_e']) & (Einter['start_e']<Einter['end1'])
fil2=(Einter['chr2']==Einter['chr_e']) & (Einter['start2']<=Einter['end_e']) & (Einter['start_e']<Einter['end2'])
Einter.loc[:,'ebin']=np.nan
Einter['ebin']=Einter['ebin'].astype('object')
Einter.loc[fil1,'ebin']=Einter.loc[fil1,['chr1','start1','end1']].astype(str).agg('_'.join, axis=1)
Einter.loc[fil2,'ebin']=Einter.loc[fil2,['chr2','start2','end2']].astype(str).agg('_'.join, axis=1)
Einter['eid']=Einter.loc[:,['chr_e','start_e','end_e']].astype(str).agg('_'.join, axis=1)

# 03 确定每个 ebin 的权重
Eweights=Einter.loc[:,['chr_e','start_e','end_e','eid','ebin','occurrences']].drop_duplicates().groupby('ebin')['occurrences'].sum().reset_index()
# log2transform + sort by chr start end(str)
Eweights['weights']= np.log2(Eweights['occurrences'] + 1).transform(lambda x: (x - x.mean()) / x.std())
Eweights[['chr','start','end']]=Eweights['ebin'].str.split('_',expand=True)
Eweights=Eweights[['chr','start','end','weights','occurrences','ebin']]
Eweights=Eweights.sort_values(by=['chr', 'start', 'end'], key=lambda col: col if col.name == 'chr' else pd.to_numeric(col))


Eweights.to_csv(f'/cluster/home/futing/Project/GBM/HiC/10loop/consensus/cytoscape/{name}/{name}_Eweights_bash.bed',sep='\t',index=False)

# 结束时间
end_time=time.time()
elapsed_time = end_time - start_time  # 计算运行时间
print(f"Epre_bash.py running time: {elapsed_time:.6f} s")
