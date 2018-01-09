#! /bin/bash

# Returns the name of the elements in the POSCAR file of the
# current directory. Alternatively, another file can be supplied
# as an argument. Or, if you supply the character '@' it will look for a
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
if [[ ! $(sed '6q;d' $file) = *[0-9]* ]]; then
  printf "%s" "$(sed '7q;d' $file)"
fi

# If the file doesn't contain element information then don't say anything
