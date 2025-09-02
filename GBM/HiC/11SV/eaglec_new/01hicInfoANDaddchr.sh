while IFS= read -r i; do
#	mkdir ${i}
#	cp 02for.sh slurm-predictSV.sh ${i}
    cp /cluster/home/tmp/GBM/HiC/11SV/eaglec_new/A172/neoloop_slurm.sh ${i}
    # for j in 50000 10000 5000; do
    #     hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/${i}.mcool::/resolutions/${j}"
    # done
done < filename

for reso in 50000 10000 5000; do
    hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/04mcool/04iPSC/iPSC_new.mcool::/resolutions/${reso}"
    hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/04mcool/02NPC/NPC_new.mcool::/resolutions/${reso}"
    hicInfo -m "/cluster/home/tmp/GBM/HiC/02data/04mcool/03pHGG/pHGG.mcool::/resolutions/${reso}"
done

python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/A172.mcool::/resolutions/50000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/A172.mcool::/resolutions/5000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/SW1088.mcool::/resolutions/50000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/SW1088.mcool::/resolutions/5000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U118.mcool::/resolutions/50000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U118.mcool::/resolutions/5000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U343.mcool::/resolutions/50000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U343.mcool::/resolutions/5000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U87.mcool::/resolutions/50000
python add_prefix_to_cool.py /cluster/home/tmp/GBM/HiC/02data/04mcool/01GBM/U87.mcool::/resolutions/5000
