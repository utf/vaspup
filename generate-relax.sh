#! /bin/bash

start=62
stop=73
log="$(pwd)/log"

for i in $(seq $start $stop); do
  if [ ! -d "$i" ]; then
    echo "Structure $i does not exist, skipping" >> $log
    echo " "
    continue
  fi
  echo "Structure $i " >> $log
  
  cd "${i}/kpoint_converge"
  ~/scripts/data-converge.sh
  cp data ../
  cd ..

  num_lines=$(wc -l < "data")
  converged_point=0;

  for n in $(seq 2 $num_lines); do

    diff_x=$(sed "${n}q;d" data | awk '{print $4}')
    diff=${diff_x#-} # get the absolute value otherwise the next step will be true for large differences that are negative 

    if [ "$(echo "$diff < 2" | bc)" -eq 1 ]; then
      let converged_point=$(sed "${n}q;d" data | awk '{print $1}')
      echo -e "\tConverged on k point $converged_point" >> $log
      break    
    fi
  done

  if [ "$converged_point" -eq "0" ]; then
    echo -e "\tConvergence was not found, moving folder to 'unconverged' directory" >> $log
    cd ..
    mv $i unconverged
  elif [ "$converged_point" -gt "0" ]; then
    echo -e "\tEditing KPOINTS and INCAR files" >> $log
    cp input relax -rf
    cp "kpoint_converge/$converged_point/KPOINTS" relax
    cp ~/p3_binary/pb/pbs2/INCAR relax
    rm kpoint_converge -rf

    echo -e "\tMoving to 'converged' directory" >> $log
    cd ..
    mv $i converged
  fi
  echo " " >> log
done
