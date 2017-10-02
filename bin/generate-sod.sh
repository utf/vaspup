#!/bin/bash

#
# Check all needed files exist
#
if [ ! -f input/CONFIG ]; then
    echo "CONFIG file not found in ./input/ directory"
    exit
fi

if [ ! -f input/SGO ]; then
    echo "SGO file not found in ./input/ directory"
    exit
fi

if [ ! -f input/INCAR ]; then
    echo "INCAR file not found in ./input/ directory"
    exit
fi

if [ ! -f input/POTCAR ]; then
    echo "POTCAR file not found in ./input/ directory"
    exit
fi

if [ ! -f input/KPOINTS ]; then
    echo "KPOINTS file not found in ./input/ directory"
    exit
fi

if [ ! -f input/INSOD ]; then
    echo "INSOD file not found in ./input/ directory"
    exit
fi


source input/CONFIG

if [ ! -x sod_comb ]; then
    echo "Cannot find sod_comb, please ensure your PATH is correct."
    exit
fi

#
# Prepare each SOD directory
#

for i in $(seq $num_sub_start $num_sub_end) 
do
  # Prepare the tmp directory and copy in the needed SOD files
  if [ -d "tmpsod" ]; then
    rm tmpsod -r
  fi
  mkdir tmpsod
  cd tmpsod
  cp ../input/INSOD .
  cp ../input/SGO .

  # Change the number of substitutions (change line after "# nsub" is matched)
  sed -i '/# nsub/{n;s/.*/'$i'/;}' INSOD 

  sod_comb

  # Prepare the generated files for running with VASP
  cd CALCS
  n=1
  for vasp_file in *.vaspin
  do
    mkdir $n
    mv $vasp_file $n/POSCAR
    cp ../../input/INCAR $n/
    cp ../../input/POTCAR $n/
    cp ../../input/KPOINTS $n/
    let n=n+1
  done

  # Clean up and rename folder
  rm job_sender
  cd ../../
  new_folder=$prefix"_"$i"sub"
  if [ -d "$new_folder" ]; then # remove old versions of the folder
    rm "$new_folder" -r
  fi
  mv tmpsod/CALCS "$new_folder"

  # Run vasp in all subfolders
  cd "$new_folder"
  for folder in */
  do
    cd "$folder"
    nfol=${folder%/} # Removes the trailing /
    task_name=$prefix"_"$i"sub_"$nfol
 #   vasp 5.2.12 $n_cores "$task_name" 
    cd ..
  done
  cd ..

  # Clean up
  rm tmpsod -r
done
