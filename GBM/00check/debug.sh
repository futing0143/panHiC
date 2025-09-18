#!/bin/bash

cat /cluster/home/futing/Project/GBM/GBM_0221.log | xargs -I {} sh -c 'rm {} && touch {}'