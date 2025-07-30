#!/bin/bash

cd /cluster2/home/futing/Project/panCancer/GC/debug
# dumperr
grep -rl 'err' *.log | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ../dumperr.txt
ls *.log | cut -f1 -d '-' | cut -f1 -d '_' | sort -u > ../jid.txt
grep -w -v -F -f ../dumperr.txt ../jid.txt > ../done0712.txt


grep -w -v -F -f ../done0712.txt ../GSE135941.txt > ../undone.txt