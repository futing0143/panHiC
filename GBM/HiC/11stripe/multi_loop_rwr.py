import cooler
import numpy as np
import os
import pandas as pd
import logging
import time
import torch
import torch.nn.functional as F
from joblib import Parallel, delayed,  parallel_backend

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logging.info('Starting the script')

# 路径和文件
path = '/cluster/home/Kangwen/dream/genoformer/data/sample'
cooler_file = '/cluster/home/Kangwen/dream/genoformer/data/code/cool/all.cool'
loop_file = '/cluster/home/Kangwen/dream/genoformer/data/code/loop/merge_loop.csv'
matrix_file = '/cluster/home/Kangwen/dream/genoformer/data/code/matrix'

# 加载参考数据
cool = cooler.Cooler(cooler_file)
refer = cool.bins()[:]

# 加载并过滤 loop 数据
loop = pd.read_csv(loop_file, sep='\t')
loop = loop[loop['BIN1_CHR'] == loop['BIN2_CHROMOSOME']]


def rwr_data_augmentation(matrix, rp=0.5, do_conv=True, do_col=True, 
                          first_order_weight=0.75, second_order_weight=0.25,
                          max_iter=30, conv_kernel_size=3, 
                          tol=1e-6, device="cpu"):
    """
    使用随机游走重启 (RWR) 算法进行数据增强，结合一阶和二阶相似性
    
    参数:
        matrix: 输入矩阵，形状为 [batch_size, num_nodes, num_nodes]
        rp: 重启概率，默认为 0.5
        do_conv: 是否在 RWR 前进行卷积平滑, 默认为 True
        do_col: 是否进行列归一化后处理, 默认为 True
        first_order_weight: 一阶相似性权重, 默认为 0.75
        second_order_weight: 二阶相似性权重, 默认为 0.25
        max_iter: 最大迭代次数, 默认为 30
        conv_kernel_size: 卷积核大小, 默认为 3
        tol: 收敛容忍度, 默认为 1e-6
        device: 计算设备, 默认为 "cpu"
        
    返回:
        增强后的矩阵
    """
    # 移动到指定设备
    if not isinstance(matrix, torch.Tensor):
        matrix = torch.tensor(matrix, dtype=torch.float32)
    
    matrix = matrix.to(device)
    batch_size, num_nodes, _ = matrix.shape
    
    # 1. 卷积平滑处理
    if do_conv and matrix.dim() >= 3:
        pad = conv_kernel_size // 2
        ll = pad * 2 + 1
        A = F.avg_pool2d(matrix.unsqueeze(1), ll, 1, padding=pad, ceil_mode=True).clamp(min=1e-8)
        A = A.squeeze(1)
    else:
        A = matrix.clone()
    
    # 2. 计算一阶和二阶相似性
    # 一阶相似性：原始矩阵
    first_order_sim = A.clone()
    
    # 二阶相似性：矩阵与其转置的乘积 (A*A^T)
    second_order_sim = torch.bmm(A, A.permute(0, 2, 1))
    
    # 移除二阶相似性中的对角线元素
    diag_mask = torch.eye(num_nodes, device=device).bool().unsqueeze(0).expand(batch_size, -1, -1)
    second_order_sim.masked_fill_(diag_mask, 0)
    
    # 3. 归一化处理
    # 归一化一阶相似性
    first_order_sim = first_order_sim.div(first_order_sim.sum(1, keepdim=True).add(1e-15))
    
    # 归一化二阶相似性
    second_order_sim = second_order_sim.div(second_order_sim.sum(1, keepdim=True).add(1e-15))
    
    # 4. 组合一阶和二阶相似性
    combined_sim = (first_order_sim * first_order_weight) + (second_order_sim * second_order_weight)
    
    # 处理零和列
    zero_cols = combined_sim.sum(1) == 0
    combined_sim = combined_sim + torch.diag_embed(zero_cols.float())
    
    # 归一化组合后的相似性矩阵
    P = combined_sim.div(combined_sim.sum(1, keepdim=True).add(1e-15))
    
    # 5. 随机游走迭代
    Q = torch.eye(num_nodes, device=device).unsqueeze(0).expand(batch_size, -1, -1)
    I = Q.clone()
    
    for i in range(max_iter):
        Q_new = rp * torch.bmm(Q, P)
        # 将 (1-rp) 添加到对角线上
        diag_values = torch.diagonal(Q_new, dim1=1, dim2=2)
        diag_values.add_(1 - rp)
        
        delta = torch.norm(Q - Q_new, p=2)
        Q = Q_new
        
        if delta < tol:
            break
    
    # 6. 后处理
    if do_col:
        # 矩阵对称化
        Q = (Q + Q.transpose(1, 2)) * 0.5
        Q = Q.clamp(min=0.0)
        Q = Q.div(Q.sum(dim=2, keepdim=True).add(1e-15))
    
    # 7. 应用增强后的概率矩阵到原始数据
    enhanced_matrix = torch.bmm(Q, matrix)
    
    return enhanced_matrix


def get_loop_indices(loop, refer, batch_size=50):
    """
    获取 loop 索引，支持分批处理
    
    参数:
        loop: loop 数据 DataFrame
        refer: 参考基因组信息 DataFrame
        batch_size: 每批处理的 loop 数量
    
    返回:
        批处理的 loop 索引列表
    """
    loop_batches = []
    for i in range(0, len(loop), batch_size):
        batch_loop = loop.iloc[i:i+batch_size]
        batch_idx = []
        for j in range(batch_loop.shape[0]):
            chrom, bin1, bin2 = batch_loop.iloc[j, [0, 1, 4]]
            
            bin1_idx = refer[(refer['chrom'] == chrom) & (refer['start'] == bin1)].index[0]
            bin2_idx = refer[(refer['chrom'] == chrom) & (refer['start'] == bin2)].index[0]
            
            batch_idx.append([bin1_idx, bin2_idx, chrom, bin1, bin2])
        loop_batches.append(batch_idx)
    return loop_batches


def process_chromosome_rwr(clr, chrom, loop_batch_idx, rwr_mat_size=256):
    """
    对单个染色体进行 RWR 处理
    
    参数:
        clr: Cooler 对象
        chrom: 染色体名称
        loop_batch_idx: 当前批次的 loop 索引
        rwr_mat_size: RWR 矩阵大小
    
    返回:
        处理后的 loop 值列表
    """
    mat = clr.matrix(balance=False).fetch(chrom)
    shape = mat.shape[0]
    tmp = []

    for val in loop_batch_idx:
        bin1_idx, bin2_idx, chrom, bin1, bin2 = val
        mat_idx1 = bin1 // 10000
        mat_idx2 = bin2 // 10000
        width = bin2_idx - bin1_idx + 1
        to_expand_size = rwr_mat_size - width + 1

        start = mat_idx1 - to_expand_size // 2
        loop_start = to_expand_size // 2
        end = start + rwr_mat_size

        # 调整起始和结束位置
        if start < 0:
            start = 0
            end = start + rwr_mat_size
            loop_start = mat_idx1
        if end >= shape:
            end = shape - 1
            start = end - rwr_mat_size
            loop_start = mat_idx1 - start

        # 获取矩阵子区域
        submat = mat[start:end, start:end]
        
        # RWR 数据增强
        mat_tensor = torch.tensor(submat, dtype=torch.float32).unsqueeze(0)
        enhanced_mat = rwr_data_augmentation(mat_tensor, rp=0.5, do_conv=True, do_col=True)
        enhanced_mat = enhanced_mat.squeeze(0).cpu().numpy()

        # 提取 loop 区域
        where_loop = enhanced_mat[loop_start:loop_start + width+1, 
                                   loop_start:loop_start + width+1]
        np.fill_diagonal(where_loop, 0)
        val = where_loop.sum()
        tmp.append(val.item())

    return tmp


def process_cool_file(cool_file, path, loop_batches):
    """
    处理单个 cool 文件
    
    参数:
        cool_file: cool 文件名
        path: 文件路径
        loop_batches: 分批处理的 loop 索引
    
    返回:
        细胞名称和处理后的矩阵
    """
    start_time = time.time()
    cell_name = cool_file.split('.')[0]
    # logging.info('1')
    clr = cooler.Cooler(os.path.join(path, cool_file))
    chroms = list(set(chrom for batch in loop_batches for _, _, chrom, _, _ in batch))
    # logging.info('2')
    matrix_values = []
    
    # 对每个批次的 loop 进行处理
    for i, batch_idx in enumerate(loop_batches):
        # 按染色体分组
        logging.info(f'Processing {cool_file} for batch {i+1}/{len(loop_batches)}')
        chrom_batches = {}
        for loop_info in batch_idx:
            chrom = loop_info[2]
            if chrom not in chrom_batches:
                chrom_batches[chrom] = []
            chrom_batches[chrom].append(loop_info)
        
        # 对每个染色体批次进行 RWR
        batch_results = []
        for chrom, chrom_loops in chrom_batches.items():
            chrom_results = process_chromosome_rwr(clr, chrom, chrom_loops)
            batch_results.extend(chrom_results)
        
        matrix_values.append(batch_results)
    
    # 展平结果
    matrix_values = [item for sublist in matrix_values for item in sublist]
    
    elapsed_time = time.time() - start_time
    logging.info(f'Processed {cool_file} in {elapsed_time:.2f} seconds')
    return cell_name, matrix_values


def main():
    # 获取所有 cool 文件
    cool_files = [f for f in os.listdir(path) if f.endswith('.cool') and not f.startswith('.')]
    total_files = len(cool_files)
    logging.info(f'Found {total_files} cool files to process')

    # 获取分批处理的 loop 索引
    loop_batches = get_loop_indices(loop, refer, batch_size=1000)

    
    matrix = []
    cell = []
    # 并行处理 cool 文件
    results = Parallel(n_jobs=1)(delayed(process_cool_file)(file, path, loop_batches) for file in cool_files)
    for cell_name, matrix_values in results:
        cell.append(cell_name)
        matrix.append(matrix_values)
    
    
    
    
    # 创建 DataFrame
    df = pd.DataFrame(matrix)
    df.index = cell
    

    # 保存结果
    df.to_csv(matrix_file + '/' + 'loop_matrix_rwr1.csv', sep='\t')
    logging.info('Results saved to loop_matrix_rwr1.csv')


if __name__ == '__main__':
    total_start_time = time.time()
    main()
    logging.info(f'Total processing time: {time.time() - total_start_time:.2f} seconds')