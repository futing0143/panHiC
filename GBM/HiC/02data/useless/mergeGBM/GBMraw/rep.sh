#!/bin/bash

for i in GB176 GB180 GB182 GB183 GB238 #A172 SW1088 U118 U343 U87
do
ln -s /cluster/home/futing/Project/GBM/HiC/00data/GBM/GBM_onedir/${i} ${i}
done