#! /bin/bash

# Generates a POTCAR based on the POSCAR in the current directory.
# A specific file can also be supplied as an argument and failing that
# the POTCAR is generated interactively.

potDir="$HOME/bin/potentials" # Path to potentials
scriptDir="$HOME/scripts" # Path to scripts folder
workingDir=$(pwd) # Where the sciprt was called from

# Check if user has supplied a POSCAR
file="POSCAR"
poscar=1
if [ "$#" -eq 1 ]; then
  if ! [ -f $1 ]; then
    echo "$1 doesn't exist"
    exit 1
  fi
  file="$1"
elif [ "$#" -eq 0 ] && ! [ -f POSCAR ]; then
  echo "How many elements?"
  read nEl

  if ! [ $nEl -eq $nEl 2>/dev/null ]; then
    echo "Not a valid number of elements"
    exit
  fi
  poscar=0
elif [ "$#" -gt 1 ]; then
  echo "Too many arguments supplied"
  exit 1
fi

# We have a file we can use therefore extract the information from it
if [ $poscar -eq 1 ]; then
  # The sed is important for using POSCAR generated on Windows
  # Otherwise the last symbol isn't recognised properly. Such a pain
  # to debug.
  elementList=$($scriptDir/util/name-elements.sh $1 | sed $'s/\r//')
  nEl=$($scriptDir/util/num-elements.sh $1)
fi

# For each of the options, keep doing this loop until a choice has been
# made. When it has, copy the POTCAR working directory and continue
# with the next element.
for i in $(seq 1 $nEl); do

  while [ -z ${choice+x} ]; do # While a selection still hasn't been made

    if [ $poscar -eq 0 ]; then
      echo "Enter the symbol of element $i"
      read element
    else
      element=$(echo $elementList | awk -v i=$i '{print $i}')
    fi

    cd $potDir

    # This regex is a bit hacky but it works
    pos=$(ls | grep "\(${element}_.*\)\|${element}\b\|\(${element}\..*\)")
    npos=$(echo $pos | wc -w)

    if [ "$npos" -eq 0 ]; then
      echo "Could not find a POTCAR for symbol: $element"
      poscar=0
    elif [ "$npos" -gt 1 ]; then

      echo "There are multiple POTCARs matching: $element"
      echo "Your options are:"

      for n in $(seq 1 $npos); do
        echo "[$n] $(echo $pos | awk '{print $'$n'}')"
      done

      while [ -z ${choice+x} ]; do # run this loop to a valid choice is chosen

        echo -e "\nEnter the number of the POTCAR you would like"
        read nchoice

        # Check the choice is an integer and one of the options
        if ! [ $nchoice -eq $nchoice 2>/dev/null ] || [ $nchoice -gt $npos ]; then
          echo "Not a valid choice"
        else
          choice=$(echo $pos | awk '{print $'$nchoice'}')
          echo "$choice added to POTCAR"
        fi
      done

    # If there is only one option, choose it and don't ask in the prompt
    elif [ "$npos" -eq 1 ]; then
      choice=$pos
    fi

  done

  # Move the POTCAR of choice to the working directory
  cp "$choice/POTCAR.Z" $workingDir/${i}_POTCAR.Z -f

  # Need unset so the while loop can work properly. It enables us to be understanding
  # if the user makes any mistakes.
  unset choice
done

cd $workingDir

# Prepare the files for catenating
gunzip -f *POTCAR.Z
for i in $(seq 1 $nEl); do
  catCommand+="${i}_POTCAR "
done

# Generate our POTCAR
cat $catCommand > POTCAR

# Remove the temporary files
for i in $(seq 1 $nEl); do
  rm "${i}_POTCAR"
done
