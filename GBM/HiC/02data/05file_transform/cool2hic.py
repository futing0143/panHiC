from optparse import OptionParser
import cooler
import pandas as pd

desc="Transfer cool to hic."

parser = OptionParser(description=desc)

parser.add_option("-i", "--input", action="store", type="string",
                  dest="input", help="Input cool or mcool file.", metavar="<file>")

parser.add_option("-r", "--resolution", action="store", type="int",
                  dest="res", help="Resolution for the output hic file.", metavar="<int>")
parser.add_option("-o", "--output", action="store", type="string",
                  dest="output", help="Output cool or mcool file.", metavar="<file>")

(opt, args) = parser.parse_args()
file =  opt.input
resolution = opt.res
fout =  opt.output


print("Input file: %s" % file)
print("Resolution: %s" % resolution)
print("Output file: %s" % fout)
#==========================

file_type = file.split('.')[len(file.split('.'))-1]
if file_type == 'cool':
    c = cooler.Cooler(file)
if file_type == 'mcool':
    c = cooler.Cooler(file+'::resolutions/'+str(resolution))

chrom = c.chroms()[0:len(c.chroms())]
chrom = chrom[~chrom.name.str.contains('_|M')]
chrom = chrom.sort_values('name')

for i in chrom.name:
    print(i)
    hic_chr = c.matrix(balance=False, as_pixels=True, join=True).fetch(i)
    hic_chr = hic_chr.iloc[:,[0,1,3,4,6]]
    hic_chr['str1'] = 0
    hic_chr['str2'] = 0
    hic_chr['frag1'] = 0
    hic_chr['frag2'] = 1
    names = ['str1','chrom1','start1','frag1','str2','chrom2','start2','frag2','count']
    hic_chr = hic_chr.reindex(columns=names)
    hic_chr.to_csv(fout,sep='\t', mode='a', index=None, header=None)
    
#===========================
#####https://github.com/zsq-berry/3D-genome-tools
#pip install cooler
#pip install pandas
#conda activate neoloop
#nohup python3 cool2hic.py -i /cluster/home/jialu/GBM/HiC/otherGBM/mcoolfile/100k/GBMmerge_100k.cool -r 100000 -o GBM_100k.txt > gbm_100k.cl2hic.out 2>&1
#gzip matrix.txt matrix.txt.gz
#java -Xms512m -Xmx2048m -jar /cluster/home/jialu/4DN_iPSc/pipeline/extra/juicer/scripts/common/juicer_tools_1.22.01.jar pre -r 5000 -d matrix.txt.gz GBM.hic /cluster/home/jialu/BioSoft/ABC-Enhancer-Gene-Prediction/example_chr22/TCGAout/hg38.chrom.size