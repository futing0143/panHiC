#Correct_peaks.py

import numpy as np
import pandas as pd

import sys

from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA
import scipy.stats as stats

import pdb


def compute_CPM(peak_reads, peak_width, bam_stats, samples):
    '''
    Compute CPM (Transcripts Per Kilobase Million)
    '''
    read_depth = np.array(bam_stats.set_index('Sample').loc[samples]['Reads']) / 1e6
    CPM_reads = np.divide(np.array(peak_reads) * 1e3, float(peak_width)) / read_depth
    return CPM_reads



def read_in_peaks():
    bam_stats = pd.read_csv('%s/bam_stats.txt' % DATA_DIR, sep=' ', header=None)
    bam_stats.columns=['Sample', 'Reads']
    bam_stats = bam_stats.drop_duplicates()

    if 1:
        print('Read in Peak and convert to CPM')
        # Peaks

        peaks_file = open('%s/allSamples_peak_by_sample_matrix_10.19.22.genrich.final.forTPM.txt' % DATA_DIR, 'r')
        #peaks_file = open('%s/test.txt' % DATA_DIR, 'r')
        header = peaks_file.readline().rstrip().split('\t')

        cpm_file = open('%s/all_samples_peak_by_sample_matrix_CPM_genrich_10.19.22.txt' % DATA_DIR,'w')
        cpm_file.write('\t'.join(header) + '\n')
        
        samples = header[4:]
        number_K = 0
        peak_CPM = [header]
        for line in peaks_file.readlines():
            line = line.rstrip().split('\t')
            peak_width = int(line[3]) - int(line[2])
            if peak_width < 10:
                continue
            peak_reads = map(int, line[4:])
            if np.mean(peak_reads) < 1:
                continue
            if np.max(peak_reads) > 100000:
                continue
            row_reads = compute_CPM(peak_reads, peak_width, bam_stats, samples)
            row_reads = map(str, list(row_reads))
            cpm_file.write('\t'.join(line[:4] + row_reads) + '\n')
            number_K += 1

        print('Read is done')
        print(number_K)

        peaks_file.close()
        cpm_file.close()

   


if __name__ == '__main__':

    DATA_DIR = '/path/to/dir/'
    read_in_peaks()