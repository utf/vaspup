#! /bin/bash

cp ~/bin/job .

if [ $# -eq 0 ]; then
  exit
fi

sed -i "s/#PBS -N.*/#PBS -N $1/" job
