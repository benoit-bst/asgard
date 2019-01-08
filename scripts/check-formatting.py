#!/bin/python
#https://dx13.co.uk/articles/2015/4/3/Setting-up-git-clang-format.html

import subprocess
output = subprocess.check_output(["git-clang-format-7", "--binary", "clang-format-7", "--extensions", "cpp,h",  "--diff"])

print output
if output not in ['no modified files to format\n', 'clang-format did not modify any files\n']:
    print "Run git clang-format, then commit.\n"
    exit(1)
else:
    exit(0)
    
    