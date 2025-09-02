import os

input_dir = "/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000"
preview_mode = False  # 设置为False时才实际执行重命名

with open('/cluster/home/futing/Project/GBM/HiC/02data/03cool_order/1000/name.txt', 'r') as f:
    names = [line.strip() for line in f]

for name in names:
    old_name = os.path.join(input_dir, f"{name}_1000.cool")
    new_name = os.path.join(input_dir, f"{name}.cool")
    
    if os.path.exists(old_name):
        if preview_mode:
            print(f"Will rename: {old_name} -> {new_name}")
        else:
            os.rename(old_name, new_name)
            print(f"Renamed: {old_name} -> {new_name}")
    else:
        print(f"Warning: {old_name} not found")