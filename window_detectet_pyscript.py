import os
import tabix
import pandas as pd
import numpy as np
from joblib import Parallel, delayed
import contextlib
import io
import argparse
import time
from datetime import datetime, timedelta, timezone

parser = argparse.ArgumentParser()
parser.add_argument("-E","--entry", type=str,
                    help="*.bed file, the index file used to detect")
parser.add_argument("-N", "--Normal",type=str,
                    help="control sample dir path")
parser.add_argument("-T", "--Tumor",type=str,default=4,
                    help="tumor sample dir path")
parser.add_argument("-O", "--output",type=str,default="",
                    help="dir, where the output files saved in.")
parser.add_argument("-C", "--core",type=int,default=8,
                    help="cores number distribute for this task")
args = parser.parse_args()

###准备工作
sites2detectfile = args.entry
normal_dir_path = args.Normal
lungcancer_dir_path = args.Tumor

obs_distance = os.path.join(args.output, "pyobs_distance.bed")
runlog = os.path.join(args.output, "pytimelog.out")

def time_now():
    # 获取当前时间戳
    timestamp = time.time()
    # 将时间戳转换为UTC时间
    utc_time = datetime.fromtimestamp(timestamp, tz=timezone.utc)
    # 将UTC时间转换为北京时间（UTC+8）
    beijing_time = utc_time.astimezone(timezone(timedelta(hours=8)))

    return(beijing_time.strftime('%Y-%m-%d %H:%M:%S'))

with open(runlog, "wt") as f:
    pass
with open(obs_distance, "wt") as f:
    pass


for i,j,k in os.walk(normal_dir_path):
    normal_dirs=j
    print("normal_dirs: ", normal_dirs)
    break

for i,j,k in os.walk(lungcancer_dir_path):
    lungcancer_dirs=j
    print("lungcancer_dirs: ", lungcancer_dirs)
    break

###数据准备
sites2detect=pd.read_csv(sites2detectfile,header=None,sep="\t")
sites2detect=sites2detect.set_index([0,1,2])
print("ready,go")

def make_obs(chr,start,end,group_dir_path,group_dirs):
    tmp_DF=list()
    for tmp_dir in group_dirs:
        tmp_filepath=os.path.join(group_dir_path,tmp_dir,f"{tmp_dir}_count.mhap.gz")
        tb=tabix.open(tmp_filepath)
        tmp_list=[i for i in tb.query(chr,start,end) if i[1]==str(start)]
        tmp_DF.extend(tmp_list) 
        
    # 使用NumPy数组进行高效的批量数据处理 
    data = np.array(tmp_DF)[:, 3:].astype(int) # 直接转换为浮点数数组 
    tmp = pd.DataFrame(data)
    # 将表头转换为二进制数
    binary_columns = [format(i, '04b') for i in range(tmp.shape[1])]
    tmp.columns = binary_columns
    # 过滤和计算 
    # tmp = tmp.loc[tmp.sum(axis=1) >= 10,:] .loc[tmp.sum(axis=1) <= 128,:] 
    return tmp

def remove_zero_columns(df):
    """
    移除 DataFrame 中所有元素均为零的列。

    :param df: 输入的 pandas DataFrame
    :return: 移除全为零列后的 DataFrame
    """
    return df.loc[:, (df != 0).any(axis=0)]

from scipy.special import gammaln
from scipy.optimize import minimize, Bounds
from scipy.stats import dirichlet_multinomial    
def dirichlet_multinomial_loglik(alpha, X):
    """
    alpha: 待估参数，形如 [α1, α2, ..., αK]
    X: 样本矩阵，形如 N x K 的数组，每行是一个样本
    """
    alpha = np.asarray(alpha)
    X = np.asarray(X)

    # 只计算 alpha > 0 的部分
    valid_mask = alpha > 1e-8
    alpha_valid = alpha[valid_mask]
    X_valid = X[:, valid_mask]  # 只取对应 alpha > 0 的 X 部分

    # 如果没有有效的 alpha > 0，直接返回无穷大
    if len(alpha_valid) == 0:
        return np.inf

    N, K = X.shape
    n = np.sum(X, axis=1)  # 每个样本的总计数
    alpha0 = np.sum(alpha_valid)

    # 计算对数似然的各个部分
    term1 = np.sum(gammaln(n + 1) - np.sum(gammaln(X_valid + 1), axis=1))
    term2 = N * gammaln(alpha0) - np.sum(gammaln(n + alpha0))
    term3 = np.sum(gammaln(X_valid + alpha_valid) - gammaln(alpha_valid), axis=1)

    log_likelihood = term1 + term2 + np.sum(term3)
    return -log_likelihood  # minimize 是最小化函数

def estimate_alpha_mle(X, init_alpha=None, lower_bound=1e-6):
    """
    使用 trust-constr 优化 Dirichlet-multinomial 分布的 alpha 参数（MLE）

    参数:
    - X: N × K 的观测计数矩阵
    - init_alpha: 初始 alpha（可为 None）
    - lower_bound: alpha 的最小边界（默认1e-6）

    返回:
    - 长度为 K 的 alpha 向量，非有效列设为 lower_bound
    """
    X = np.asarray(X)
    K = X.shape[1]
    valid_cols = np.any(X > 0, axis=0)
    X_valid = X[:, valid_cols]
    K_valid = X_valid.shape[1]

    if K_valid == 0:
        return np.full(K, lower_bound)
    if K_valid == 1:
        res = np.full(K, lower_bound)
        res[valid_cols] = 1e8
        return res

    bounds = Bounds([lower_bound] * K_valid, [np.inf] * K_valid)

    if init_alpha is None:
        init_alpha_valid = np.full(K_valid, 1.0)
    else:
        init_alpha = np.asarray(init_alpha)
        init_alpha_valid = np.clip(init_alpha[valid_cols], lower_bound * 10, np.inf)

    result = minimize(
        fun=dirichlet_multinomial_loglik,
        x0=init_alpha_valid,
        args=(X_valid,),
        method='Powell',
        bounds=bounds,
        options={
            'xtol': 1e-6,       # 允许更大的解变化终止
            'ftol': 1e-6,       # 目标函数值变化小于该阈值则停止
            'maxiter': 200,     # 限制最多迭代步数
            'disp': False       # 关闭输出信息（如需调试可设为 True）
        }
    )

    final_alpha = np.full(K, lower_bound)
    if result.success:
        final_alpha[valid_cols] = np.clip(result.x, lower_bound, np.inf)
    else:
        final_alpha[valid_cols] = np.clip(result.x, lower_bound, np.inf)

    return final_alpha

from scipy.stats import chi2
# 将数字转为四位二进制
def to_4bit_binary(num):
    return format(num, '04b')
# 将数字转为四位二进制并转成字符串
def to_4bit_binary_str(num):
    return format(num, '04b')
def detect_one(N, L):
    Mix = pd.concat([N,L], axis=0, ignore_index=True)
    paramMix=estimate_alpha_mle(Mix)
    paramN=estimate_alpha_mle(N)
    paramL=estimate_alpha_mle(L)
    hmix = np.sum(dirichlet_multinomial.logpmf(Mix,paramMix,np.sum(Mix, axis=1)))
    hN = np.sum(dirichlet_multinomial.logpmf(N,paramN,np.sum(N, axis=1)))
    hL = np.sum(dirichlet_multinomial.logpmf(L,paramL,np.sum(L, axis=1)))
    lamb = hmix - hN - hL
    DM_p = 1 - chi2.cdf(max(0,-2*lamb), Mix.shape[1])

    diff = np.abs(paramN/np.sum(paramN) - paramL/np.sum(paramL))
    max_index = np.argmax(diff)
    max_diff = diff[max_index]

    return DM_p, max_diff, 1/(1+np.sum(paramN)), 1/(1+np.sum(paramL)), to_4bit_binary_str(max_index)

    
def format_number(num, threshold=1e-6, decimal_places=2):
    """
    格式化单个数字。
    超过threshold的数字将被格式化为小数点后指定位数，
    而小于threshold的数字将被格式化为科学计数法。
    """
    if num >= threshold:
        return f"{num:.{decimal_places+4}f}"
    elif num == -1:
        return num
    elif num == 0:
        return num
    else:
        return f"{num:.{decimal_places}e}"

def allsample_start2end(chr,start,end,normal_dir_path,normal_dirs,lungcancer_dir_path,lungcancer_dirs):
    a = make_obs(chr,start,end,normal_dir_path,normal_dirs)
    b = make_obs(chr,start,end,lungcancer_dir_path,lungcancer_dirs)       
    tmp1, tmp2, tmp3, tmp4, tmp5 = detect_one(a,b)
    return chr, start, end, format_number(tmp1), format_number(tmp2), format_number(tmp3), format_number(tmp4), tmp5


def write_results_to_file(results, file_path): 
    with open(file_path, "at") as f: 
        for result in results: 
            f.write('\t'.join(map(str, result)) + '\n')


batchsize = 2000
end_ind = sites2detect.shape[0]
for node in range(0,end_ind,batchsize): #
    print(f"{node} / {end_ind}         ", end="\r")
    with open(runlog, "at") as f:
        print(time_now(),f" batch{node}", file=f)
    results=Parallel(n_jobs=args.core, backend='multiprocessing')(delayed(allsample_start2end)(chr,start,end,normal_dir_path,normal_dirs,lungcancer_dir_path,lungcancer_dirs) for chr,start,end in sites2detect.index[node:(node+batchsize)])        # 执行函数
    write_results_to_file(results, obs_distance)
    del results
