#! /bin/bash

cp ~/bin/job .
dir=$(pwd)
d=$(printf %q $dir) # escape path for sed
sed -i "/# 8./!b;n;c#$ -wd $d" job # change the working space to the current directory
