if [ "$#" -ne 1 ]
then
  echo "Usage: sqsub job_file"
  exit 1
fi

if ! [ -f $1 ]; then
  echo "Job file doesn't exist"
  exit 1
fi


name=$(sed -n -e 's/^#PBS -N //p' $1)

echo $(pwd) $1 >> $HOME/bin/superqueue
echo "Submitted job: $name"
