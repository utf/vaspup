#! /bin/bash

# Generates KPOINTS based on a sampling of 0.04 and updates the
# KPOINTS file in the current directory with the new values.
# If it cannot find a KPOINTS file, one is copied from the
# binDir.

scriptDir="$HOME/scripts" # Should be where the util directory is
binDir="$HOME/bin" # Should contain a stock KPOINTS file

# Check if user has supplied another file (e.g. CONTCAR)
# Or if '@' has been specified then check CONTCAR exists
file="POSCAR"
if [ "$#" -eq 1 ]; then
  if [ "$1" = "@" ] && [ -f "CONTCAR" ]; then
    file="CONTCAR"
  else
    file="$1"
  fi
elif [ "$#" -gt 1 ]; then
  echo "Too many arguments supplied"
  exit 1
fi

# Check file exists
if ! [ -f $file ]; then
  echo "$file doesn't exist"
  exit 1
fi

# Calculate the K-points based on a sampling of 0.04
# Rounding line so it matches the k point Excel spreadsheet from David
# It's a bit of a hack rounding but it works as '%d' will only print
# numbers before the decimal place, whereas '%.0f' uses sprintf and will
# depend on the system.
kpoints=$($scriptDir/util/lattice.sh |\
        awk '{
          printf "%.10f \t %.10f \t %.10f",
             (1/($1*0.04)), (1/($2*0.04)), (1/($3*0.04))
        }')

round_kpoints=$(echo $kpoints |\
        awk '{
          for(i=1; i <= NF; i++) {
            printf "%d ", $i+=$i<0?0:0.5
          };
          printf "\n"
        }')

# Print the K-points (this is useful for util/kpoint-converge.sh)
echo $round_kpoints

# If a KPOINTS file is already in the current directory use it
# otherwise copy one from the bin directory.
if ! [ -f KPOINTS ]; then
  cp $binDir/KPOINTS .
fi

# Replace the 4th line down in the KPOINTS file with the new KPOINTS
sed -i '4s/.*/'"$round_kpoints"'/' KPOINTS
