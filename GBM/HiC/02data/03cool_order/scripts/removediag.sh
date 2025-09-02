#!/bin/bash
cd /cluster/home/futing/Project/GBM/HiC/02data/03cool_order/scripts

nohup python removediag.py GBM > removediag_GBM.log 2>&1 &
nohup python removediag.py NPC_merge > removediag_NPC_merge.log 2>&1 &