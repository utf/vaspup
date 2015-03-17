#!/bin/bash

#
# Check all needed files exist
#
[ ! -f input/CONFIG ] && echo "CONFIG file not found in ./input/ directory" && exit
[ ! -f input/INCAR ] && echo "INCAR file not found in ./input/ directory" && exit
[ ! -f input/POTCAR ] && echo "POTCAR file not found in ./input/ directory" && exit
[ ! -f input/KPOINTS ] && echo "KPOINTS file not found in ./input/ directory" && exit
[ ! -f input/POSCAR ] && echo "POSCAR file not found in ./input/ directory" && exit


# Read CONFIG file to get parameters
source input/CONFIG


# Converge ENMAX
if [ "$conv_enmax" -eq "1" ]; then
  [ -d enmax_converge ] && rm enmax_converge -rf
  mkdir enmax_converge
  cd enmax_converge
  for i in $(eval echo "{$enmax_start..$enmax_end..$enmax_step}"); do
    mkdir "cutoff_$i"
    cd "cutoff_$i"
    cp ../../input/KPOINTS .
    cp ../../input/INCAR .
    cp ../../input/POTCAR .
    cp ../../input/POSCAR .
    if ! sed -i "s/ENMAX .*$/ENMAX  = $i eV/g" INCAR ; then
      echo "INCAR not formatted correctly. Exiting..."
      exit
    fi
    
    task_name=$prefix"_e"$i
    [ "$run_vasp" -eq "1" ] && vasp 5.2.12 $vasp_cores "$task_name"
    cd ..
  done
  cd ..
fi

# Converge KPOINT
if [ "$conv_kpoint" -eq "1" ]; then
  [ -d kpoint_converge ] && rm kpoint_converge -rf
  mkdir "kpoint_converge"
  cd "kpoint_converge"
  n=1;

  IFS=',' read -ra ADDR <<< "$kpoints" # Split the kpoints by comma
  for i in "${ADDR[@]}"; do
    sub=${i//[ ]/_}
    mkdir "kpoint_$sub"
    cd "kpoint_$sub"
    cp ../../input/KPOINTS .
    cp ../../input/INCAR .
    cp ../../input/POTCAR .
    cp ../../input/POSCAR .

    if ! sed -i "s/$kpoint_start/$i/g" KPOINTS ; then
      echo "KPOINT not formatted correctly. Exiting... "
      exit
    fi

    task_name=$prefix"_k"$n
    [ "$run_vasp" -eq "1" ] && vasp 5.2.12 $vasp_cores "$task_name"
    let n=n+1
    cd ..
  done
  cd ..
fi 
