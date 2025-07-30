import pysam
import matplotlib.pyplot as plt

# 打开 BAM 文件
bamfile = pysam.AlignmentFile("/cluster2/home/futing/Project/panCancer/CRC/GSE178593/DLD-12/aligned/DLD-12.bam", "rb")

# 存储长度
dup_lengths = []

for read in bamfile:
    if read.is_duplicate and not read.is_unmapped:
        length = read.query_length
        dup_lengths.append(length)

bamfile.close()
dup_lengths.sort()

# 作图
plt.hist(dup_lengths, bins=50, color='steelblue', edgecolor='black')
plt.xlabel("Read length")
plt.ylabel("Count")
plt.title("Duplicate Read Length Distribution")
plt.tight_layout()
plt.savefig("dup_read_length_distribution.png")
