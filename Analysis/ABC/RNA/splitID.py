import pandas as pd
import sys
if len(sys.argv) < 2:
	print("用法: python script.py <input>")
	sys.exit(1)

filepath = sys.argv[1]
df = pd.read_csv(filepath,sep='\t',header=0,dtype=str)
df.iloc[:, 1:] = df.iloc[:, 1:].astype(float)
if filepath.endswith('.txt'):
    new_filepath = filepath[:-4] + '_ID.txt'
else:
    new_filepath = filepath + '_ID.txt'

df.iloc[:, 0] = df.iloc[:, 0].str.replace(r'\..*', '', regex=True)
df=df.copy()
df_merged = df.groupby(df.columns[0], as_index=False).sum()
df_merged.to_csv(new_filepath, index=False,sep='\t')