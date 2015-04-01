#!/bin/bash

total_num_elements=$(~/scripts/util/num-elements.sh)
indiv_num_elements=$(~/scripts/util/num-elements-list.sh)
num_atoms=$(~/scripts/util/num-atoms.sh)
line_numbers=$(grep -nr -P "^\s*PAW_PBE" POTCAR | awk '{print $1}' | tr -d ':' | tr '\n' ' ')

total_electrons=0
for i in $(seq 1 $total_num_elements); do
  line_num=$(echo $line_numbers | awk -v i="$i" '{ printf "%d", ($i + 1) }')
  electrons=$(sed "${line_num}q;d" POTCAR | awk '{printf "%d", $1 }')
  let total_electrons=total_electrons+$(echo $indiv_num_elements | awk -v x="${electrons}" -v i="$i" '{ printf "%d", (x * $i) }')
done

nbands=$(echo "($total_electrons / 1.6) + ($num_atoms / 2)" | bc)
nbands_r1=$(echo $nbands | awk '{printf "%d", (($1 / 24) + 1) }')
nbands_rounded=$(echo $nbands_r1 | awk '{printf "%d", ($1 * 24) }')
#echo "NELECT = $total_electrons"
#echo "NIONS = $num_atoms"
echo "$(echo "2 * $nbands_rounded" | bc)"
