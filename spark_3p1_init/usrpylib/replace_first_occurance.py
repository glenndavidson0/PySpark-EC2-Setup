#%%
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca
import sys
import os

MODE = 'CLI'
# MODE = 'IDE
if(MODE == 'CLI'):
    if(len(sys.argv) != 4):
        print('incorrect args')
        print('ARG 1 - give input filepath')
        print('ARG 2 - line to replace / search for')
        print('ARG 3 - line to insert in place')
        sys.exit()
    
    input_file = str(sys.argv[1])
    search_line = str(sys.argv[2])
    insert_line = str(sys.argv[3])
    print(str(sys.argv[0]))
    print('num args: ', str(len(sys.argv)))
    print('input file: ', input_file)
    print('search line: ', search_line)
    print('insert line: ', insert_line)
else:
    cwd = os.getcwd() + '/'
    input_file = cwd + 'hadoop-env.sh' 
    search_line = 'export JAVA_HOME=${JAVA_HOME}'
    insert_line = 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"'

# if the input line is not \n terminated, add a \n
if insert_line[-1] != '\n':
    insert_line += '\n'

# copy file line by line into temp file until replace line is found
# read the search line, but enter the replace line instead
# continue copying the file line by line
#%%
foundSearchLine = False
with open(input_file, 'r') as f:
    with open('tempfile.txt', 'w') as tfile:
        while True:
            line = f.readline()
            if line == '':
                break
            elif ((line.find(search_line) != -1) and (not foundSearchLine)):
                tfile.write(insert_line)
                foundSearchLine = True
            else:
                tfile.write(line)
#%%
# overwrite the input file with the revised version, delete the tempfile
if not foundSearchLine:
    print('Seach line never found')
    os.system('rm tempfile.txt')
else:
    print('Sucessful line replace')
    c1 = 'mv -f tempfile.txt '
    c2 = input_file
    os.system(c1 + c2)     

