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

# Doesn't matter if using VASP 4.x or 5.x POSCAR format
# The word count still gives us the number of elements
echo $(sed '6q;d' $file | wc -w)
