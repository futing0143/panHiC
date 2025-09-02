import pandas as pd
filgene=pd.read_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/filter_HARs_gene.txt',sep='\t')
RNA_bed=pd.read_csv('/cluster/home/futing/ref_genome/hg38_gencode/genebed/gencode.v43.gene.bed',sep='\t',header=None)
# RNA_bed=RNA_bed.loc[RNA_bed[6]=='protein_coding',:]
RNA_bed=RNA_bed.iloc[:,[0,1,2,6]]

filgene_anno=pd.merge(filgene,RNA_bed,left_on='Gene',right_on=6,how='left')
filgene_anno[['chr','start','end']]=filgene_anno[1].str.split('_',expand=True)
filgene_anno.to_csv('/cluster/home/futing/Project/GBM/HiC/HAR/HARs_gene/genes/filter_HARs_gene_anno.txt',sep='\t',index=False)
