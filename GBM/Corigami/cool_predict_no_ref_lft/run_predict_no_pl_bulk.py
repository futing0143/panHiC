import torch
from torch.utils.data import DataLoader
from chromosome_dataset_predict_multi_bw import ChromosomeDataset
from corigami_models_pl import LightningModel
from corigami_models import ConvTransModel
import os
import pandas as pd
# os.environ['CUDA_VISIBLE_DEVICES'] = "0"
import numpy as np
from skimage.transform import resize
from functools import reduce
import time
import cooler
import argparse

device = torch.device("cuda:1" if torch.cuda.is_available() else "cpu") # 推理就只用单卡就行
print(device)
# model = LightningModel()
model = ConvTransModel(2)
model.to(device)
# 权重要改，我改过模型了
model_weight_path = '/cluster/home/futing/Project/GBM/Corigami/corigami_data/model_gbm/epoch=91-step=54740.ckpt'
lightning_model = LightningModel.load_from_checkpoint(model_weight_path)
model.load_state_dict(lightning_model.model.state_dict())
model.eval()

chrome_size_dict = {'chr1': 248956422, 'chr2': 242193529, 'chr3': 198295559, 'chr4': 190214555,
 'chr5': 181538259, 'chr6': 170805979, 'chr7': 159345973, 'chr8': 145138636, 
 'chr9': 138394717, 'chr10': 133797422, 'chr11': 135086622, 'chr12': 133275309, 
 'chr13': 114364328, 'chr14': 107043718, 'chr15': 101991189, 'chr16': 90338345, 
 'chr17': 83257441, 'chr18': 80373285, 'chr19': 58617616, 'chr20': 64444167, 'chr21': 46709983, 
 'chr22': 50818468}


def make_cooler_bins_chr(chr_name, length, resolution):
    total_bin = []
    for i in range(0, length, resolution):
        total_bin.append([chr_name, i, min(length, i+resolution)])
    df = pd.DataFrame(total_bin, columns=['chrom', 'start', 'end'])
    return df

def get_chr_stack(chr_list, chr_name, chrome_size_dict=chrome_size_dict, resolution=10000):
    chrome_size_dict = {key: chrome_size_dict[key] for key in chr_list if key in chrome_size_dict}
    chr_before_list = chr_list[:chr_list.index(chr_name)]
    if len(chr_before_list) == 0:
        return 0
    else:
        stack = 0
        for before_chr in chr_before_list:
            stack+= int(chrome_size_dict[before_chr]/resolution)
        return stack

def merge_hic_segment(hic_list, save_path, window_size=2097152, resolution=10000):
    chr_list = [i for i in hic_list]
    bins = int(window_size/resolution)
    chr_hic_dict = {}
    for chr_num in chr_list:
        chr_hic_dict[chr_num] = [make_cooler_bins_chr(chr_name=chr_num, length=chrome_size_dict[chr_num], resolution=resolution)]
        sub_list = hic_list[chr_num]
        # print(sub_list)
        large_pic = np.zeros((int(chrome_size_dict[chr_num]/resolution), 
                              int(chrome_size_dict[chr_num]/resolution)))
        for segement in sub_list:
            # print(segement[0])
            sub_start_bin = int(segement[0]/resolution)
            large_pic[sub_start_bin: sub_start_bin+bins, sub_start_bin: sub_start_bin+bins] = segement[2]
        # 将单chr的矩阵稀疏化
        rows, cols = np.nonzero(large_pic)
        stack = get_chr_stack(chr_list=chr_list, chr_name=chr_num, chrome_size_dict=chrome_size_dict, resolution=resolution)
        rows += stack
        cols += stack
        counts = large_pic[np.nonzero(large_pic)]
        large_pic_sp = np.column_stack((rows, cols, counts))
        large_pic_sp = pd.DataFrame(large_pic_sp)
        chr_hic_dict[chr_num].append(large_pic_sp)
    # 每个key对应的是一个list, [bin表, 单chr的hic三列矩阵]
    total_bin_list = []
    total_sp_list = []
    for chr_num in chr_hic_dict:
        total_bin_list.append(chr_hic_dict[chr_num][0])
        total_sp_list.append(chr_hic_dict[chr_num][1])
        # total_bin_len += chr_hic_dict[chr_num][1].shape[0]
    bin_df = reduce(lambda x, y: pd.concat([x,y], axis = 0), total_bin_list)
    bin_df.reset_index()
    bin_df.columns = ['chrom', 'start', 'end']
    # print(bin_df)
    sp_df = reduce(lambda x, y: pd.concat([x,y], axis = 0), total_sp_list)
    sp_df.reset_index()
    sp_df.columns = ['bin1_id', 'bin2_id', 'count']
    # print(sp_df)
    cooler.create_cooler(cool_uri=save_path, 
                         bins=bin_df, pixels=sp_df)



chr_list = ['chr'+ str(i) for i in range(1, 23)]
stride = 156 # 156 to keep 50 diag
def predict_cooler(atac_path, ctcf_path, save_path, stride=stride, chr_list = chr_list):
    startTime = time.time()
    total_startTime = time.time()
    dataset = ChromosomeDataset(chr_name_list=chr_list, 
                                    atac_path_list=[atac_path],
                                    ctcf_path = ctcf_path,
                                    stride=stride, use_aug=False)
    # 创建dataloader
    print("load dataset in %f s" % (time.time() - startTime))
    dataloader = DataLoader(dataset, batch_size=2, shuffle=False, num_workers=16)
    output_dict = {}
    for chr_name in chr_list:
        output_dict[chr_name] = []
    startTime = time.time()
    for step, data in enumerate(dataloader):
        seq, features, start, end, chr_num = data
        features = torch.cat([feat.unsqueeze(2) for feat in features], dim=2)
        inputs = torch.cat([seq, features], dim=2)
        sub_time = time.time()
        mat_pred = model(inputs.to(device)) 
        for i in range(seq.shape[0]):
            mat_pred_sub = resize(mat_pred[i].cpu().detach().numpy(), (209, 209), anti_aliasing=True)
            result = mat_pred_sub
            result = np.exp(result)-1
            result = np.triu(result)
            output_dict[str(chr_num[i])].append([start[i], end[i], result])
    print("Run model in %f s" % (time.time() - startTime))
    startTime = time.time()
    merge_hic_segment(output_dict, save_path, window_size=2097152, resolution=10000)
    print("Run merge in %f s" % (time.time() - startTime))

def main():
  
  parser = argparse.ArgumentParser(description='C.Origami Prediction Module.')
  parser.add_argument('--out', dest='output_path', default='outputs',
          help='output path for storing results (default: %(default)s)')
  parser.add_argument('--celltype', dest='celltype', 
                        help='Sample cell type for prediction, used for output separation')
  parser.add_argument('--chr', dest='chr_name', 
                        help='Chromosome for prediction', required=True)
  parser.add_argument('--start', dest='start', type=int,
                        help='Starting point for prediction (width is 2097152 bp which is the input window size)', required=True)
  parser.add_argument('--model', dest='model_path', 
                        help='Path to the model checkpoint', required=True)
  parser.add_argument('--seq', dest='seq_path', 
                        help='Path to the folder where the sequence .fa.gz files are stored', required=True)
  parser.add_argument('--ctcf', dest='ctcf_path', 
                        help='Path to the folder where the CTCF ChIP-seq .bw files are stored', required=True)
  parser.add_argument('--atac', dest='atac_path', 
                        help='Path to the folder where the ATAC-seq .bw files are stored', required=True)

  args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])
  predict_cooler(save_path=args.output_path, args.celltype, 
                      args.chr_name, args.start,
                      args.model_path, 
                      args.seq_path, ctcf_path=args.ctcf_path, atac_path=args.atac_path)
    
atac_path = '/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/atac.bw'
ctcf_path = '/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/ctcf_log2fc.bw'
saved_path = '/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/genomic_features/predicted_cooler_no_ref_lft.cool'
predict_cooler(atac_path=atac_path,ctcf_path=ctcf_path,save_path=saved_path)

if __name__ == '__main__':
    main()
