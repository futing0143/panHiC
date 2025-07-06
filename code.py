import requests
import os
import re
from joblib import Parallel, delayed
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def download_geo_metadata(gse_id):
    """下载GEO数据集元数据并提取样本ID"""
    
    # 构建URL
    url = f"https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc={gse_id}&targ=self&view=brief&form=text"
    
    try:
        # 下载数据
        response = requests.get(url)
        response.raise_for_status()  # 检查HTTP错误
    
        # 补充文件
        sp = []
        for line in response.text.split('\n'):
            if 'supplementary_file' in line:
                # 使用正则表达式提取GSM ID
                
                tmp = line.split(' = ')[-1]
                tmp = 'https' + tmp[3:]
                tmp = tmp.replace('\r', '')
                f_name = tmp.split('/')[-1]
                sp.append([tmp,f_name])
     
        print(f"成功下载 {gse_id} 的元数据")
        print(f"找到 {len(sp)} 个样本ID")
        return sp
        
    except requests.RequestException as e:
        print(f"下载失败: {e}")
        return []

def download(url,name):
    cmd = 'wget -c ' + url + ' -O ' + name
    logging.info(f"执行命令: {cmd}")
    os.system(cmd)
    
gse = "GSE253754"
# gse = 'GSE246785'
os.makedirs(gse, exist_ok=True)
os.chdir(gse)
files = download_geo_metadata(gse)

Parallel(n_jobs=4)(delayed(download)(url, name) for url, name in files)
    
#
  