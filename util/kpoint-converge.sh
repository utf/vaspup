#! /bin/bash

# Edits the K-point part of the converge CONFIG file to make it
# generate the neccessary range of K-points for convergence.
# It takes the 3 middle K-points as arguments or if they are not
# supplied, tries to generate them itself from a KPOINT file in
# the current directory.
# It is clever and knows not to set a KPOINT of less than 1.

scriptDir="$HOME/scripts" # Should be where the util directory is
binDir="$HOME/bin" # Should contain a stock KPOINTS file

# Check if user has supplied 3 variables correctly and
# if not load the k-points ourself.
if [ "$#" = "3" ]; then
  ka=$1
  kb=$2
  kc=$3
elif [ "$#" -eq 1 ] && [ "$(echo $1 | awk '{ print NF }')" -eq 3 ]; then
  # The arguments are therefore surrounded by quotes
  ka=$(echo $1 | awk '{ print $1 }')
  kb=$(echo $2 | awk '{ print $2 }')
  kc=$(echo $3 | awk '{ print $3 }')
elif [ "$#" -eq 0 ]; then
  kpoints=$($scriptDir/generate-kpoints.sh)
  ka=$(echo $kpoints | awk '{ print $1 }')
  kb=$(echo $kpoints | awk '{ print $2 }')
  kc=$(echo $kpoints | awk '{ print $3 }')
fi

# Check if ka has been set based on a parameter expansion
if [ -z ${ka+x} ]; then
  echo 'Usage is "./kpoint-converge.sh <a> <b> <c>"'
  exit 1
fi

# Really messy but it works so I'm leaving it for now.
# Basically, most of it is checking that we don't go less than 1
if [ "$ka" -lt "1" ]; then
  let ka=1
fi

if [ "$kb" -lt "1" ]; then
  let kb=1
fi

if [ "$kc" -lt "1" ]; then
  let kc=1
fi

if [ "$ka" -lt "3" ]; then
  ka1=1
  ka2=1
else
  let ka1=$ka-2
  let ka2=$ka-1
fi

let ka4=$ka+1
let ka5=$ka+2

if [ "$kb" -lt "3" ]; then
  kb1=1
  kb2=1
else
  let kb1=$kb-2
  let kb2=$kb-1
fi

let kb4=$kb+1
let kb5=$kb+2

if [ "$kc" -lt "3" ]; then
  kc1=1
  kc2=1
else
  let kc1=$kc-2
  let kc2=$kc-1
fi

let kc4=$kc+1
let kc5=$kc+2

k_centre="$ka $kb $kc"
k_all="$ka1 $kb1 $kc1,$ka2 $kb2 $kc2,$ka $kb $kc,$ka4 $kb4 $kc4,$ka5 $kb5 $kc5"

sed -i '10s/.*/kpoint_start="'"$k_centre"'"/' CONFIG
sed -i '11s/.*/kpoints="'"$k_all"'"/' CONFIG
#cp $HOME/bin/KPOINTS .
#sed -i '4s/.*/'"$k_centre"'/' KPOINTS
#cat KPOINTS
