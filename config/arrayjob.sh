#!/bin/bash
# setting up the environment for SGE:
#$ -cwd -V
#$ -q all.q
#$ -pe openmpi 8 
#$ -M mres19@master.sassy.local
#$ -N array
#$ -t 1-5
#$ -e /home/mres19/p3_binary/pb/pbs2/output/sp4061_crystal154442/kpoint_converge/kpoint_7_7_5/_k3.error
#$ -o /home/mres19/p3_binary/pb/pbs2/output/sp4061_crystal154442/kpoint_converge/kpoint_7_7_5/_k3.output

cd "$SGE_TASK_ID"
/opt/openmpi/gfortran/1.6.5/bin/mpirun --mca btl ^tcp -n 8 /usr/local/vasp/vasp-5.2.12 
cd ..
