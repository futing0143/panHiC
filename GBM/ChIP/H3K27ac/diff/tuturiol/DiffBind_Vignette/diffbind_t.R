library(DiffBind)
library(tidyverse)
library(rtracklayer)
setwd('/cluster/home/futing/Project/GBM/ChIP/H3K27ac/diff/tuturiol/DiffBind_Vignette')

# Read a csv file
samples <- read.csv("tamoxifen.csv")

# Look at the loaded metadata
names(samples)
tamoxifen <- dba(sampleSheet="tamoxifen.csv")

# Step 2: Occupancy analysis
# Step 3: Counting reads
tamoxifen.counted <- dba.count(tamoxifen, summits=250)

# Step 4: Differential binding affinity analysis
tamoxifen.counted
tamoxifen.counted <- dba.contrast(tamoxifen.counted, categories=DBA_CONDITION)
