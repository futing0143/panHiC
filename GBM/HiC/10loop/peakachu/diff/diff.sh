# wget -c -O down100.ctcf.pkl https://dl.dropboxusercontent.com/s/enyg2m7ebj8mxsv/down100.ctcf.pkl?dl=0
# wget -c -O down100.h3k27ac.pkl https://dl.dropboxusercontent.com/s/yasl5hu0v510k2v/down100.h3k27ac.pkl?dl=0
# wget -c -O down30.ctcf.pkl https://dl.dropboxusercontent.com/s/f1383jpzj3addi4/down30.ctcf.pkl?dl=0
# wget -c -O down30.h3k27ac.pkl https://dl.dropboxusercontent.com/s/dyvtyqvu3wpq3a5/down30.h3k27ac.pkl?dl=0
# wget -c -O GM12878-MboI-allReps-filtered.mcool https://data.4dnucleome.org/files-processed/4DNFIXP4QG5B/@@download/4DNFIXP4QG5B.mcool
# wget -c -O K562-MboI-allReps-filtered.mcool https://data.4dnucleome.org/files-processed/4DNFI18UHVRO/@@download/4DNFI18UHVRO.mcool

# # # peakachu scoring for GM
# # peakachu score_genome -r 10000 --balance -m down100.ctcf.pkl -p GM12878-MboI-allReps-filtered.mcool::resolutions/10000 -O GM12878-CTCF --minimum-prob 0
# # peakachu score_genome -r 10000 --balance -m down100.h3k27ac.pkl -p GM12878-MboI-allReps-filtered.mcool::resolutions/10000 -O GM12878-H3K27ac --minimum-prob 0
# # # peakachu scoring for K562
# # peakachu score_genome -r 10000 --balance -m down30.ctcf.pkl -p K562-MboI-allReps-filtered.mcool::resolutions/10000 -O K562-CTCF --minimum-prob 0
# # peakachu score_genome -r 10000 --balance -m down30.h3k27ac.pkl -p K562-MboI-allReps-filtered.mcool::resolutions/10000 -O K562-H3K27ac --minimum-prob 0
# # # call loops for GM
# # for i in GM12878-CTCF/*bed; do peakachu pool -i $i -t .98 > ${i}.loops; done
# # cat GM12878-CTCF/*bed.loops > GM12878-CTCF.0.98.loops
# # for i in GM12878-H3K27ac/*bed; do peakachu pool -i $i -t .91 > ${i}.loops; done
# # cat GM12878-H3K27ac/*bed.loops > GM12878-H3K27ac.0.91.loops
# # bedtools pairtopair -is -slop 25000 -type notboth -a GM12878-H3K27ac.0.91.loops -b GM12878-CTCF.0.98.loops > tmp
# # cat GM12878-CTCF.0.98.loops tmp > GM12878.merged.loops
# # # call loops for K562
# # for i in K562-CTCF/*bed; do peakachu pool -i $i -t .96 > ${i}.loops; done
# # cat K562-CTCF/*bed.loops > K562-CTCF.0.96.loops
# # for i in K562-H3K27ac/*bed; do peakachu pool -i $i -t .88 > ${i}.loops; done
# # cat K562-H3K27ac/*bed.loops > K562-H3K27ac.0.88.loops
# # bedtools pairtopair -is -slop 25000 -type notboth -a K562-H3K27ac.0.88.loops -b K562-CTCF.0.96.loops > tmp
# # cat K562-CTCF.0.96.loops tmp > K562.merged.loops

python /cluster/home/jialu/biosoft/peakachu/diffPeakachu/diffPeakachu.py NPC-peakachu-5kb-loops.0.95.bedpe GBMmerge-peakachu-5kb-loops.0.95.bedpe NPC_GBMmerge_merged.bedpe