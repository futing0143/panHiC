import  sys

data = sys.argv[1]
output = sys.argv[2]
sep = sys.argv[3]
file_elements = 'file\telement'
with open (data,'r') as f:
    lines = f.readlines()
    for line in lines:
        if 'File:' in line:
            file = line.split(sep)[0].split('/')[-1]
            print(f'file: {file}')
        if 'Non-zero elements:' in line:
            element = line.split(':')[-1].strip()
            print(f'element: {element}')
            file_element = file + '\t' + element
            file_elements = file_elements + '\n' + file_element

with open (output,'w') as f:
    f.write(file_elements)