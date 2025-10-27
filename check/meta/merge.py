def merge_files_detailed_unmatched(file1_path, file2_path, output_path, unmatched_file1_path, unmatched_file2_path):
    # 读取文件2的数据建立字典
    file2_dict = {}
    file2_keys = set()
    
    with open(file2_path, 'r') as f2:
        for line in f2:
            parts = line.strip().split('\t')
            if len(parts) >= 4:
                cancer, gse, cell, enzyme = parts[0], parts[1], parts[2], parts[3]
                key = (cancer, gse, cell)
                file2_dict[key] = enzyme
                file2_keys.add(key)
    
    # 读取文件1的数据并合并
    result = []
    unmatched_file1 = []
    matched_keys = set()
    
    with open(file1_path, 'r') as f1:
        for line in f1:
            parts = line.strip().split('\t')
            if len(parts) >= 4:
                cancer, gse, cell, srr = parts[0], parts[1], parts[2], parts[3]
                key = (cancer, gse, cell)
                
                # 查找匹配的enzyme
                enzyme = file2_dict.get(key, "")
                result.append((cancer, gse, cell, srr, enzyme))
                
                # 记录匹配情况
                if enzyme:
                    matched_keys.add(key)
                else:
                    unmatched_file1.append((cancer, gse, cell, srr))
    
    # 找出文件2中未匹配的行
    unmatched_file2 = []
    for key in file2_keys:
        if key not in matched_keys:
            # 从文件2中找出对应的完整行
            with open(file2_path, 'r') as f2:
                for line in f2:
                    parts = line.strip().split('\t')
                    if len(parts) >= 4:
                        cancer, gse, cell, enzyme = parts[0], parts[1], parts[2], parts[3]
                        if (cancer, gse, cell) == key:
                            unmatched_file2.append((cancer, gse, cell, enzyme))
                            break
    
    # 写入文件
    with open(output_path, 'w') as out:
        for row in result:
            out.write('\t'.join(row) + '\n')
    
    with open(unmatched_file1_path, 'w') as f:
        for row in unmatched_file1:
            f.write('\t'.join(row) + '\n')
    
    with open(unmatched_file2_path, 'w') as f:
        for row in unmatched_file2:
            f.write('\t'.join(row) + '\n')
    
    print(f"合并完成！")
    print(f"文件1未匹配: {len(unmatched_file1)} 行")
    print(f"文件2未匹配: {len(unmatched_file2)} 行")

# 使用示例
if __name__ == "__main__":
    merge_files_detailed_unmatched("panCan_down_sim.txt", "panCan_meta.txt", "panCan_merge.txt", 
                                 "unmatched_file1.txt", "unmatched_file2.txt")