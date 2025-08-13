import cooler

mcool_path = '/cluster/home/futing/Project/GBM/Corigami/corigami_data/data/hg38/gbm/hic_matrix/GBM_9reso.mcool/'  # 替换为你的mcool文件路径
c = cooler.Cooler(mcool_path)

resolutions = c.resolutions()
print("Available resolutions:")
for res in resolutions:
    print(res)
