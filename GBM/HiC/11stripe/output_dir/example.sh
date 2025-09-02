#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/11stripe
# wget https://www.dropbox.com/s/1bb2npvrzp3by5y/BL6.DPT.chr16.mcool?dl=0 -O test.mcool --no-check-certificate

stripenn compute --cool BL6.DPT.chr16.mcool::resolutions/5000 --out output_dir/ -k 16 -m 0.95,0.96,0.97,0.98,0.99
stripenn compute --cool /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/GBM_10000.cool --out test