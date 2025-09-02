import cooler
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import glob

diagonal_data = pd.read_csv("/cluster/home/futing/Project/GBM/HiC/02data/0350k/flattened_list2.csv",sep="\t")
diagonal_data=diagonal_data.T
diagonal_data.columns=['ts543','ts667','A172','U118','U343','U87','SW1088','G523','G583','G567','G176','G180','G182','G183','G238']
diagonal_data = diagonal_data.loc[(diagonal_data != 0).any(axis=1),:]
sample_similarity = diagonal_data.corr()

plt.figure(figsize=(8, 6))
g = sns.clustermap(sample_similarity, cmap='coolwarm', annot=False, fmt=".2f", linewidths=0.5
                    ,dendrogram_ratio=(0.05, 0.05)   
                    ,cbar_pos=(-0.05, 0.2, 0.03, 0.45))
#plt.title('Insulation scores Heatmap', fontsize=16, pad=30,loc='center') 
plt.suptitle('Diagonal values Heatmap', fontsize=20, y=1.02) 
g.ax_heatmap.set_xticklabels(g.ax_heatmap.get_xticklabels(), fontsize=20)
g.ax_heatmap.set_yticklabels(g.ax_heatmap.get_yticklabels(), fontsize=20)
plt.savefig('diagonal_heatmap.pdf')
# 显示图形
plt.show()