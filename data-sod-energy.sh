#! /bin/bash

rm -f data
tmp="${RANDOM}tmp" # use a random tmp file as our string buffer before column

echo -e "System\t#\tEnergy\tEnergy/atom\ta\tb\tc" >> $tmp # output the column titles

for i in */*/CONTCAR; do

  folder=${i/CONTCAR/}
  name=${folder//[\/]/ } # remove all forward slashes
  n_atoms=$(sed '7q;d' $i | awk '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}') # sum over row 7 of the CONTCAR
  energy_total=$(grep TOTEN $folder/OUTCAR | awk '{print $5}' | tail -1 | tr -d '\n') # tr is to remove the trailing newline
  energy_per_atom=$(echo "scale = 7; $energy_total / $n_atoms" | bc)
  lattice=$(~/scripts/data-lattice.sh "$i")

  echo -e "$name\t$energy_total\t$energy_per_atom\t$lattice" >> $tmp
  
done

column -t < $tmp > data # make the data look pretty

rm -f $tmp
