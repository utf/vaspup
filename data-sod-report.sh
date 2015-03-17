#! /bin/bash


[ ! -f input/CONFIG ] && echo "CONFIG file not found in this directory" && exit
exists() { [[ ! -f $1 ]] && echo "OUTSOD file not found in $1" && exit; } # helper function to test for wildcard pattern matches
exists */OUTSOD

echo "Loading CONFIG file"
source CONFIG

rm -f report */calcd */delta_h */delta_g */tdelta_h */tdelta_g htable gtable

tmp="${RANDOM}tmp" # use a random tmp file as our string buffer before column

echo "Generating energy report"
~/scripts/data-sod-energy.sh
mv data "$tmp"
echo -e "\n" >> "$tmp"

for i in */OUTSOD; do

  folder=${i/OUTSOD/}
  n_subs=$(echo "$folder" | head -c -5 | tail -c 1) # gets the number of substitutions in the supercell
  n_atoms=$(sed '7q;d' "$folder/1/CONTCAR" | awk '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}') # sum over row 7 of the CONTCAR
  recip=$(echo "scale = 6; 1 / $n_atoms" | bc)
  x=$(echo "scale = 6; $n_subs / $n_pos_subs" | bc) # the fraction of material that has been substituted
  c1=$(echo "scale = 6; $pure_end * $x" | bc)
  c2=$(echo "scale = 6; $pure_start * (1 - $x) " | bc)
 
  cd $folder
  ~/scripts/sod/sod_vasp_ener
  ~/scripts/data-sod-volume.sh > DATA
  seq $temp_start $temp_step $temp_stop > TEMPERATURES
  
  echo "Running sod statistics in $folder"
  ~/scripts/sod/sod_stat

  rm -f calcd delta_h delta_g tdelta_h tdelta_g 
  echo "x = $x" >> calcd
  echo -e "T\tH\tG\tVolume\tdelta_H\tdelta_G" >> calcd
  tail --lines=+2 statistics.dat | awk '{print $1 "\t" $2 "\t" $3  "\t" $5}' >> calcd # use tail to skip the header
  
  #  This calculates the delta H_mix and delta G_mix for each row
  echo -e "\n" > delta_h
  echo -e "\n" > delta_g
  echo -e -n "$x\t" > tdelta_h # this is for the transposed values for the final graph
  echo -e -n  "$x\t" > tdelta_g

  tail --lines=+3 calcd | awk -v "c1=$c1" -v "c2=$c2" -v "a=$recip" '{print a * ($2 - c1 - c2)}' >> delta_h
  tail --lines=+3 calcd | awk -v "c1=$c1" -v "c2=$c2" -v "a=$recip" '{print a * ($3 - c1 - c2)}' >> delta_g
  
  tdeltah=$(cat delta_h | sed '/^$/d' | tr "\n" "\t") # Strip proceeding whitespace then swap newlines for tabs e.g. transpose
  tdeltag=$(cat delta_g | sed '/^$/d' | tr "\n" "\t") 
  echo $tdeltah >> tdelta_h 
  echo $tdeltag >> tdelta_g 

  paste calcd delta_h delta_g > $tmp

  column -t < $tmp >> "../$tmp" # make the data look pretty
  echo -e "\n" >> "../$tmp" # add some space at the bottom

  cd ..  

done

# make the hmix and gmix tables
echo "Hmix" > htable
echo "Gmix" > gtable

echo -e -n "Ratio\t" >> htable
echo -e -n "Ratio\t" >> gtable

temps=$(seq $temp_start $temp_step $temp_stop | tr "\n" "\t")
echo $temps >> htable # add temperature headers
echo $temps >> gtable  

dummy=$(seq $temp_start $temp_step $temp_stop | tr "\n" "\t" | sed -E "s/[0-9]+/0/g")
echo -e "0\t$dummy" >> htable
echo -e "0\t$dummy" >> gtable

cat htable */tdelta_h  > htable2
echo -e "1\t$dummy" >> htable2
echo "" >> htable2 
column -t < htable2 >> "$tmp" # make the data look pretty
echo "" >> $tmp

cat gtable */tdelta_g  > gtable2
echo -e "1\t$dummy" >> gtable2
echo "" >> gtable2 
column -t < gtable2 >> "$tmp" # make the data look pretty

rm -r */"$tmp" */calcd */delta_h */delta_g */tdelta_h */tdelta_g htable* gtable*

mv "$tmp" report

echo "Report generation compelted"
