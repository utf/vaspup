#! /bin/bash

files=(CHG CHGCAR CONTCAR DOSCAR EIGENVAL IBZKPT LOCPOT OSZICAR OUTCAR PCDAT REPORT vasprun.xml WAVECAR XDATCAR)

for file in ${files[@]}; do
    [ -f "${file}" ] &&  rm "${file}"
done
