import pandas as pd
import os
from pysradb.sraweb import SRAweb
from joblib import Parallel, delayed
import numpy as np

srr = pd.read_csv("/cluster/home/Kangwen/Hic/data_new/sn_m3c3/20241104/opc_srr.list",header=None)
srr = list(srr[0])
pd.DataFrame(srr).to_csv('srr.csv',index=False,header=False)
seq3 = pd.read_csv('/cluster/home/Kangwen/Hic/data_new/sn_m3c3/seq3.info',sep='\t',header=None)
seq3 = list(seq3[0])
m3c = pd.read_csv('/cluster/home/Kangwen/Hic/data_new/sn_m3c3/m3c.info',sep='\t',header=None)
m3c = list(m3c[0])


def gse2gsm(gse):
    print(gse)
    sra = SRAweb()
    srr = sra.gse_to_gsm(gse)['experiment_alias'].tolist()
    return (gse,srr)

def gsm2srr(gsm):
    print(gsm)
    sra = SRAweb()
    srr = sra.gsm_to_srr(gsm)['run_accession'].tolist()[0]
    return (gsm,srr)

# deal seq3 gse2gsm
results =  Parallel(n_jobs=10)(delayed(gse2gsm)(gse) for gse in seq3)
results = dict(results)

#save the results
np.save('seq3_gse2gsm.npy',results)

# deal seq3 gsm2srr
all_gsm_to_srr = []
for key in results.keys():
    all_gsm_to_srr += results[key]

results =  Parallel(n_jobs=10)(delayed(gsm2srr)(gsm) for gsm in all_gsm_to_srr)
results = dict(results)

#save the results
np.save('seq3_gsm2srr.npy',results)



# deal m3c gse2gsm
results =  Parallel(n_jobs=10)(delayed(gse2gsm)(gse) for gse in m3c)
results = dict(results)

#save the results
np.save('m3c_gse2gsm.npy',results)

# deal m3c gsm2srr
all_gsm_to_srr = []
for key in results.keys():
    all_gsm_to_srr += results[key]

results =  Parallel(n_jobs=10)(delayed(gsm2srr)(gsm) for gsm in all_gsm_to_srr)
results = dict(results)

#save the results
np.save('m3c_gsm2srr.npy',results)
