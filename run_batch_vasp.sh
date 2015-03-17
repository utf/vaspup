#!/bin/bash --login
#PBS -N mitzi-1
#PBS -l select=90
#PBS -l walltime=24:0:0
#PBS -A e05-gener-dos
#PBS -o q.error
#PBS -e q.output

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)

cd $PBS_O_WORKDIR

  j=1
  for i in $(ls | grep N06);do
    mkdir simulation_$j
    cd $i
    cp POSCAR ../simulation_$j/
    cp KPOINT ../simulation_$j/
    cd ..
    cp INCAR POTCAR simulation_$j
    ((j++))
  done

 NTASK=216
 date
 numSimsStart=10
 ToRun=$((numSimsStart))
 # Initialise the array that knows which simulations to process
 for i in $(eval echo {1..$ToRun});do
   work_array[$i]=$i
   run_array[$i]="TRUE"
 done
# Counter for how many ionic steps
 numSteps=200
# Counter for how many cycles to try 
 maxCount=5
 #Loop until all done
 for count in $( eval echo {1..$maxCount});do
 #Loop over all structures to process
   numSims=$((ToRun))
 #Work out what the work is to be done
   NoverS=$(($numSimsStart / $numSims))
   W=$(($numSimsStart - ($numSims * $NoverS)))
   for i in $(eval echo {1..$ToRun});do
 #work out how many procs to use
     if [ $i -le $W ];then
       NPROC=$(( $NTASK * ($NoverS + 1) ))
     else
       NPROC=$(( $NTASK * $NoverS))
     fi
     cd simulation_${work_array[$i]}/
     if [ $count -gt 1 ];then
        cp POSCAR POSCAR.lastStep
        cp CONTCAR POSCAR
        cp OUTCAR OUTCAR.lastStep
     else
        cp POSCAR POSCAR.orig
     fi
     echo $count >> run_position
     echo Simulation_${work_array[$i]} has $NPROC processors >> ../info.out
     aprun -n $NPROC $HOME/bin/vasp.5.3.3.archer >> simulation_${work_array[$i]}.out &
     cd ..
   done
 #Wait for all simulations to complete
   wait
   for i in $(eval echo {1..$ToRun});do
      cd simulation_${work_array[$i]}/
      flag=`grep -c "reached required accuracy" OUTCAR`
      if [ ${flag} -eq 1 ];then
        echo Simulation_${work_array[$i]} completed successfully >> ../info.out
        run_array[${work_array[$i]}]="FALSE"
      else
        flag=`grep -c "EDIFF is reached" OUTCAR`
        if [ ${flag} -eq  $numSteps ];then
          #All fine, just not finished!
          echo Simulation_${work_array[$i]} SCF was successful >> ../info.out
        else
          echo Simulation_${work_array[$i]} failed SCF!  >> ../info.out
          run_array[${work_array[$i]}]="FALSE" 
        fi
      fi
      cd ..
    done
 #Re-run jobs that need it
    val=1
    for i in $(eval echo {1..$ToRun});do
    if [ "${run_array[${work_array[$i]}]}" == "TRUE" ];then
      #There is work still to do!
       work_array[$val]=${work_array[$i]}
       val=$(($val+1))
    else
 #Work has been completed
      ToRun=$(($ToRun-1))
    fi
  done
  if [ ${ToRun} -ge 1 ];then
    numSims=$(($ToRun))
    On iteration $count >> info.out
    echo There are $numSims simulations still to process >> info.out
  else
    echo All simulations complete! >> info.out
    break
  fi
 if [ $count -eq $maxCount ];then
     echo WARNING:Max count reached! >> info.out
 fi
 done
