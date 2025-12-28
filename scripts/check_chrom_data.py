import cooler
import sys

# 替换为你的 .cool 文件路径
cool_file = sys.argv[1] if len(sys.argv) > 1 else "/cluster2/home/futing/Project/panCancer/GBM/GSE162976/NHA/cool/NHA_10000.cool"

clr = cooler.Cooler(cool_file)

print("Checking chromosome data...")

for chrom in [f"chr{i}" for i in range(1, 23)] + ["chrX", "chrY"]:
    # 获取该染色体的数据
    matrix = clr.matrix(balance=False).fetch(chrom)
    total_contacts = matrix.sum()
    
    print(f"{chrom}: {total_contacts:,.0f} total contacts")
    
    if total_contacts == 0:
        print(f"  ⚠️  WARNING: {chrom} has NO data!")

print("\nChromosome sizes:")
for chrom, size in zip(clr.chromnames, clr.chromsizes):
    print(f"{chrom}: {size:,} bp")
