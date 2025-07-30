import pandas as pd
import matplotlib.pyplot as plt

# 读取长度
df = pd.read_csv('frag_lengths.txt', header=None, names=['length'])
df['length'] = df['length'].abs()  # 取绝对值

# 可选：过滤极端值
df = df[df['length'] < 1000]

# 画图
plt.figure(figsize=(8,6))
plt.hist(df['length'], bins=50, color='skyblue', edgecolor='black')
plt.xlabel('Fragment Length (bp)')
plt.ylabel('Count')
plt.title('Length Distribution of Duplicate Fragments')
plt.tight_layout()
plt.show()
