#! /bin/bash

# Returns the number of atoms in the POSCAR file.
# Alternatively, another file can be supplied as an argument
# Or, if you supply the character '@' it will look for a
# CONTCAR first then a POSCAR (useful for scripting).

file="POSCAR"

# Check if user has supplied another file (e.g. CONTCAR)
# Or if '@' has been specified then check CONTCAR exists
if [ "$#" -eq 1 ]; then
  if [ "$1" = "@" ]; then
    if [ -f "CONTCAR" ]; then
      file="CONTCAR"
    fi
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

# Check if using VASP 4.x or 5.x POSCAR format
# E.g. The 6th line contains text or numbers
nline=6
if [[ $(sed '7q;d' $file) = *[0-9]* ]]; then
  nline=7 # First character of line 6 is not numeric
fi

echo $(sed $nline'q;d' $file | awk '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}')
