import sys 
import os
import random
import pickle
import pandas as pd
import numpy as np
from skimage.transform import resize
from torch.utils.data import Dataset
import data_feature as data_feature

class ChromosomeDataset(Dataset):
    def __init__(self, chr_name_list, atac_path_list, ctcf_path, stride=158, omit_regions_file_path='/cluster/home/Yuanchen/project/scHiC/dataset/centrotelo.bed',use_aug = True):
        self.use_aug = use_aug
        self.res = 10000 # 10kb resolution
        self.bins = 209.7152 # 209.7152 bins 2097152 bp
        self.image_scale = 256 # IMPORTANT, scale 210 to 256
        self.sample_bins = 210
        self.stride = stride # bins
        self.atac_path_list = atac_path_list
        self.ctcf_path = ctcf_path
        self.chr_name_list = chr_name_list
        self.omit_regions_dict = proc_centrotelo(omit_regions_file_path)
        print(f'Loading chromosome {self.chr_name_list}...')
        self.seq_dict = {}
        # self.mat_ref_dict = {}
        for chr_name in self.chr_name_list:
            self.seq_dict[chr_name] = data_feature.SequenceFeature(path=f'/cluster/home/Yuanchen/project/scHiC/dataset/DNA/hg38/{chr_name}.fa.gz')
            # self.mat_ref_dict[chr_name] = data_feature.HiCFeature(path=f'/cluster/home/Yuanchen/project/scHiC/dataset/HiC/10k/reference/{chr_name}.npz')
            
        self.atac_list = [data_feature.GenomicFeature(path=path, norm=None) for path in self.atac_path_list]
                
        self.ctcf_feature = data_feature.GenomicFeature(path=self.ctcf_path, norm= 'log')
        self.all_intervals_list = []
        for chr_name in self.chr_name_list:
            self.all_intervals_list.append(self.get_intervals_chr(seq=self.seq_dict[chr_name],
                                                                            chr_name=chr_name,
                                                                            omit_regions=self.omit_regions_dict[chr_name]))

        self.intervals = np.concatenate(self.all_intervals_list, axis=0)

    def __getitem__(self, idx):
        start, end, chr_name = self.intervals[idx]
        start = int(start)
        end = int(end)
        target_size = int(self.bins * self.res)
        total_seq = self.seq_dict[chr_name]
        # total_mat_ref = self.mat_ref_dict[chr_name]
        total_atac_list = self.atac_list
        total_ctcf = self.ctcf_feature
        # Shift Augmentations
        if self.use_aug: 
            start, end = self.shift_aug(target_size, start, end)
            start = int(start)
            end = int(end)
        else:
            start, end = self.shift_fix(target_size, start)
            start = int(start)
            end = int(end)
        # print(start)
        seq, features = self.get_data_at_chr_interval(start=start, end=end, chr_name=chr_name, 
                                                                total_seq=total_seq, 
                                                                #total_mat_ref=total_mat_ref, 
                                                                atac_list=total_atac_list,
                                                                ctcf=total_ctcf)
        # print('get_item', start, end)
        return seq, features, start, end, chr_name

    def __len__(self):
        return len(self.intervals)

    def gaussian_noise(self, inputs, std = 1):
        noise = np.random.randn(*inputs.shape) * std
        outputs = inputs + noise
        return outputs

    def reverse(self, seq, features, mat, chance = 0.5):
        '''
        Reverse sequence and matrix
        '''
        r_bool = np.random.rand(1)
        if r_bool < chance:
            seq_r = np.flip(seq, 0).copy() # n x 5 shape
            features_r = [np.flip(item, 0).copy() for item in features] # n
            mat_r = np.flip(mat, [0, 1]).copy() # n x n

            # Complementary sequence
            seq_r = self.complement(seq_r)
        else:
            seq_r = seq
            features_r = features
            mat_r = mat
        return seq_r, features_r, mat_r

    def complement(self, seq, chance = 0.5):
        '''
        Complimentary sequence
        '''
        r_bool = np.random.rand(1)
        if r_bool < chance:
            seq_comp = np.concatenate([seq[:, 1:2],
                                       seq[:, 0:1],
                                       seq[:, 3:4],
                                       seq[:, 2:3],
                                       seq[:, 4:5]], axis = 1)
        else:
            seq_comp = seq
        return seq_comp

    def get_data_at_chr_interval(self, start, end, chr_name, total_seq, atac_list, ctcf):
        '''
        Slice data from arrays with transformations
        '''
        # Sequence processing
        start = int(start)
        end = int(end)
        # print('get_data_at_chr_interval',start, end)
        seq = total_seq.get(start, end)
        # Features processing
        features_atac_list = [item.get(chr_name, start, end) for item in atac_list]
        features_atac = np.log(np.sum(np.array(features_atac_list), axis=0) + 1)
        # features_atac = atac_list[0].get(chr_name, start, end)
        features_ctcf = ctcf.get(chr_name, start, end)
        features = [features_atac, features_ctcf]
        # mat_ref = total_mat_ref.get(start)
        # mat_ref = resize(mat_ref, (self.image_scale, self.image_scale), anti_aliasing=True)
        # mat_ref = np.log(mat_ref + 1)
        # mat_ref = self.norm_hic(mat_ref)
        return seq, features #, mat_ref

    
    def get_intervals_chr(self, seq, omit_regions, chr_name):
        chr_bins = len(seq) / self.res
        data_size = (chr_bins - self.sample_bins) / self.stride
        # print(data_size)
        starts = np.arange(0, data_size).reshape(-1, 1) * self.stride
        intervals_bin = np.append(starts, starts + self.sample_bins, axis=1)
        intervals = intervals_bin * self.res
        intervals_add = np.array([[len(seq)-self.bins * self.res, len(seq)]])
        intervals = np.append(intervals, intervals_add, axis=0)
        intervals = intervals.astype(int)
        intervals = self.filter(intervals, omit_regions)
        chr_name_array = np.full(len(intervals), chr_name).reshape(-1, 1)
        intervals = np.append(intervals, chr_name_array, axis = 1)
        # print(intervals)
        return intervals # 
        





    def get_active_intervals(self):
        '''
        Get intervals for sample data: [[start, end]]
        '''
        chr_bins = len(self.seq) / self.res
        data_size = (chr_bins - self.sample_bins) / self.stride
        starts = np.arange(0, data_size).reshape(-1, 1) * self.stride
        intervals_bin = np.append(starts, starts + self.sample_bins, axis=1)
        intervals = intervals_bin * self.res
        return intervals.astype(int)

    def filter(self, intervals, omit_regions):
        valid_intervals = []
        for start, end in intervals: 
            # Way smaller than omit or way larger than omit
            start_cond = start <= omit_regions[:, 1]
            end_cond = omit_regions[:, 0] <= end
            if sum(start_cond * end_cond) == 0:
                valid_intervals.append([start, end])
        return valid_intervals

    def encode_seq(self, seq):
        ''' 
        encode dna to onehot (n x 5)
        '''
        seq_emb = np.zeros((len(seq), 5))
        seq_emb[np.arange(len(seq)), seq] = 1
        return seq_emb

    def shift_aug(self, target_size, start, end):
        '''
        All unit are in basepairs
        '''
        offset = random.choice(range(end - start - target_size))
        return start + offset , start + offset + target_size

    def shift_fix(self, target_size, start):
        offset = 0
        return start + offset , start + offset + target_size
    
    def get_unique_elements(dictionary):
        unique_elements = set()
        for key in dictionary:
            unique_elements.update(set(dictionary[key]))
        return list(unique_elements)

    def check_length(self):
        assert len(self.seq.seq) == self.genomic_features[0].length(self.chr_name), f'Sequence {len(self.seq)} and First feature {self.genomic_features[0].length(self.chr_name)} have different length.' 
        assert abs(len(self.seq) / self.res - len(self.mat)) < 2, f'Sequence {len(self.seq) / self.res} and Hi-C {len(self.mat)} have different length.'
    
    def norm_hic(self, input_matrix, max_num=6):
        # now_max = sum(np.diagonal(input_matrix))/input_matrix.shape[0]
        now_max = max(np.diagonal(input_matrix))
        if now_max <=3:
            return input_matrix
        else:
            return input_matrix/((now_max+0.0001)/(max_num+0.0001))

def get_feature_list(root_dir, feat_dicts):
    '''
    Args:
        features: a list of dicts with 
            1. file name
            2. norm status
    Returns:
        feature_list: a list of genomic features (bigwig files)
    '''
    feat_list = []
    for feat_item in feat_dicts:
        file_name = feat_item['file_name']
        file_path = f'{root_dir}/{file_name}'
        norm = feat_item['norm']
        feat_list.append(data_feature.GenomicFeature(file_path, norm))
    return feat_list

def proc_centrotelo(bed_dir):
    ''' Take a bed file indicating location, output a dictionary of items 
    by chromosome which contains a list of 2 value lists (range of loc)
    '''
    df = pd.read_csv(bed_dir , sep = '\t', names = ['chr', 'start', 'end'])
    chrs = df['chr'].unique()
    centrotelo_dict = {}
    for chr_name in chrs:
        sub_df = df[df['chr'] == chr_name]
        regions = sub_df.drop('chr', axis = 1).to_numpy()
        centrotelo_dict[chr_name] = regions
    return centrotelo_dict