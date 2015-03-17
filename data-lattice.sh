#! /bin/bash

# Returns the lattice information for VASP POSCAR files
# It can take a path to a file if you want to calculate the
# lattice parameters for another file e.g. CONTCAR
# Or if you supply the letter @ an argument it will look for a
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

# Lattice constant or scaling factor
n=$(sed '2q;d' "$file")

# Calculate the magnitude of each lattice vector
a=$(sed '3q;d' "$file" | awk '{printf "%.10f", sqrt($1**2 + $2**2 + $3**2)}')
b=$(sed '4q;d' "$file" | awk '{printf "%.10f", sqrt($1**2 + $2**2 + $3**2)}')
c=$(sed '5q;d' "$file" | awk '{printf "%.10f", sqrt($1**2 + $2**2 + $3**2)}')

# Calculate the absolute length and print the lattice parameters
# The echo before awk is necessary for awk to give output
echo | awk -v n="$n" -v a="$a" -v b="$b" -v c="$c" '{printf "%.10f \t %.10f \t %.10f", (a * n), (b * n), (c * n)}'
