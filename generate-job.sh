#! /bin/bash

file="job"

[[ "$#" -eq 0 ]] && [[ ! -f $file ]] && cp "${HOME}/bin/job" . && echo "Copying job file from ~/bin"
[[ "$#" -eq 1 ]] && file="$1"
[[ "$#" -gt 1 ]] && echo "Too many arguments supplied" && exit 1
[[ ! -f $file ]] && echo "$file doesn't exist" && exit 1

dir=$(pwd)
d=$(printf %q $dir) # escape path for sed
sed -i "s|#$ -wd .*|#$ -wd $dir|g" job # change the working space to the current directory
sed -i "s|#$ -N .*|#$ -N $(basename $(dirname $(pwd)))_$(basename $(pwd))|g" job # change the working space to the current directory

#PBS -N Archer
#PBS -N iridis

#$ -N arrayjob
#$ -pe qlc 48
#$ -wd /home/zcqsg27/Scratch/
#$ -o job.output
#$ -e job.error

#$ -N 
#$ -e /home/alex/bin/a.error
#$ -o /home/alex/bin/a.output
