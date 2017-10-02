#! /bin/bash

tmp="${RANDOM}tmp" # use a random tmp file as our string buffer before column

echo "1" >> $tmp

for i in */CONTCAR; do

  volume=$(~/scripts/data-lattice.sh $i | awk '{print $1 * $2 * $3}');
  echo "$volume" >> $tmp

done

cat $tmp
rm $tmp  
