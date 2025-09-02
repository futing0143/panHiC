import cooler
import pandas as pd
import sys

print("Script name:", sys.argv[0])
name=sys.argv[1]
c = cooler.Cooler(f'/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/{name}_10000.cool')

# 2. 获取像素表
pixels = c.pixels()[:]

# 3. 过滤掉对角线像素
# 主对角线过滤
pixels = pixels[pixels['bin1_id'] != pixels['bin2_id']]

# 第一条副对角线过滤
pixels = pixels[abs(pixels['bin1_id'] - pixels['bin2_id']) > 1]

# 4. 创建新的cool文件
cooler.create_cooler(
    f'/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/10000/{name}_nodiag_10000.cool',
    bins=c.bins()[:],
    pixels=pixels,
    ordered=True
)
