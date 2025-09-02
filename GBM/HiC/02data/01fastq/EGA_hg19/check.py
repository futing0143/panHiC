# def is_convertible_to_int(value):
#     try:
#         int(value)
#         return True
#     except ValueError:
#         return False

# def find_invalid_lines_by_columns(file_path, columns):
#     invalid_lines = []
#     with open(file_path, 'r', encoding='us-ascii') as file:  # 使用确定的编码us-ascii
#         for line_number, line in enumerate(file, 1):
#             parts = line.split()
#             if len(parts) >= max(columns):  # 确保行有足够的列
#                 for col in columns:
#                     if col - 1 >= len(parts):  # 检查索引是否越界
#                         continue  # 如果列索引超出了当前行的列数，跳过当前循环
#                     value = parts[col - 1]
#                     if not is_convertible_to_int(value):
#                         print(f"Line {line_number}: Column {col} has non-integer value '{value}'")
#                         invalid_lines.append(line_number)  # 记录无效的行号
#                         break  # 找到第一个无效的就跳出循环
#     return invalid_lines

# # 替换以下路径为你的文件实际路径
# file_path = '/cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9/mega/aligned/merged_nodups.txt'
# # 指定需要检查的列，1表示第一列，以此类推
# columns_to_check = [3, 7]

# # 调用函数并获取无效行
# invalid_lines = find_invalid_lines_by_columns(file_path, columns_to_check)

def check_file(input_file):
    # 指定的数字列（索引从0开始）
    numeric_columns = [0, 2, 3, 4, 6, 7, 8, 11]

    with open(input_file, 'r', encoding='us-ascii', errors='ignore') as file:
        for line in file:
            parts = line.split('\t')
            is_valid = True

            for col in numeric_columns:
                try:
                    int(parts[col])
                except (ValueError, IndexError):
                    print(f"格式错误的行: {line.strip()}")
                    is_valid = False
                    break

# 使用示例
input_file = "/cluster/home/tmp/gaorx/GBM/GBM/P524.SF12681v9_new/mega/aligned/merged_nodups1.txt"
check_file(input_file)
