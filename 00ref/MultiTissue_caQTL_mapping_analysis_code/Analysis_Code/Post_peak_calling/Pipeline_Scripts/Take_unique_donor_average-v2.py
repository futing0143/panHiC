#Take_unique_donor_average-v2.py

import pandas as pd
import numpy as np


def obtain_sample_assignment_first_round():
    # ENA samples
    ENA_studies = pd.read_csv('/path/to/sample_metadata_noSC.tsv', sep='\t')
    sample_assignment = pd.DataFrame()
    for study in set(ENA_studies['study_accession']):
        try:
            token = pd.read_csv('/path/to/correlation/samples_assigned_%s.txt' % study, sep='\t')
            sample_assignment = sample_assignment.append(token)
        except:
            continue
        
    # GEO samples
    token = pd.read_csv('/path/to/correlation_Spearman_sample_structure.csv', sep='\t')
    token['samples'] = token.index
    token = token.reset_index(drop = True)
    token.columns = ['assigned_donor', 'samples']
    token = token[['samples', 'assigned_donor']]
    sample_assignment = sample_assignment.append(token)
    sample_assignment = sample_assignment.set_index('samples')
    
    return sample_assignment



def obtain_sample_assignment_second_round():
    # all samples
    sample_assignment = pd.read_csv('/path/to/samples_assigned_final.txt', sep='\t')
    sample_assignment = sample_assignment.set_index('samples')
    
    return sample_assignment


def obtain_sample_assignment(sample_assignments, vcf_samples):
    # Annotate samples with VCF 
    sample_assignments['VCF_sample'] = False
    samples_with_vcf = np.intersect1d(sample_assignments.index, vcf_samples)
    sample_assignments.loc[samples_with_vcf, 'VCF_sample']= True
    
    # Obtain the sample groupings
    sample_sets = {}
    for si in samples_with_vcf:
        di = sample_assignments.loc[si]['assigned_donor']
        si_set = np.array(sample_assignments[sample_assignments['assigned_donor'] == di].index)
        for sii in si_set:
            sample_sets[sii] = si
    
    return sample_assignments, sample_sets



def get_sample_reads():
    ENA_studies = pd.read_csv('/path/to/sample_metadata_noSC.tsv', sep='\t')
    ENA_reads = ENA_studies[['run_accession','read_count']]

    GEO_studies = pd.read_csv('/path/to/SraRunTable_ATAC_paired.tsv', sep='\t')
    GEO_reads = GEO_studies[['Run','Bases']]
    GEO_reads.columns = ENA_reads.columns
    
    study_reads = ENA_reads.append(GEO_reads).set_index('run_accession')
    return study_reads


vcf_samples = pd.read_csv('/path/to/samples_final_addHG.txt', header = None)
vcf_samples = np.array(vcf_samples[0])

# get the first round of grouping
assignment_1 = obtain_sample_assignment_first_round()
[assignment_1, sample_set1] = obtain_sample_assignment(assignment_1, vcf_samples)


# get the second grouping
assignment_2 = obtain_sample_assignment_second_round()
study_reads = get_sample_reads()
assignment_2 = assignment_2.merge(study_reads, left_index = True, right_index = True)
assignment_2['Run'] = assignment_2.index
assignment_2 = assignment_2.groupby('assigned_donor')[['read_count', 'Run']].max().reset_index()
assignment_2.index = assignment_2['Run']

[assignment_2, sample_set2] = obtain_sample_assignment(assignment_2, assignment_2['Run'])


# take average on the CPM values
cpm_all = pd.read_csv('all_samples_peak_by_sample_matrix_CPM_genrich_10.19.22.txt', sep = '\t')

samples_in_peak = np.intersect1d(cpm_all.columns, np.array(list(sample_set1.keys())))
cpm_reads = cpm_all[samples_in_peak]
cpm_average = cpm_reads.groupby(by = sample_set1, axis=1).mean()
cpm_average = cpm_average.groupby(by = sample_set2, axis=1).mean()

# format and save
peak_info = cpm_all.columns[:4]
cpm_average[peak_info] = cpm_all[peak_info]
cpm_average = cpm_average[list(peak_info) + list(cpm_average.columns[:-4])]


cpm_average.to_csv('all_samples_peak_by_sample_matrix_CPM_average_genrich_10.19.22.txt', sep='\t')