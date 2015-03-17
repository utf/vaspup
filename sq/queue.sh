#! /bin/bash
echo running
for i in {1..6}; do
  njobs=$(qstat -u "$USER" | awk '{print $10}' | grep "R\|Q" | wc -l) # Number of running jobs

  if [[ "$njobs" -lt 16 ]] && [[ -f "$HOME/bin/superqueue" ]] && [[ $(cat "$HOME/bin/superqueue" | wc -l) -gt 0 ]]; then
    line=$(head -n 1 "$HOME/bin/superqueue")
    dir=$(echo $line | awk '{ print $1 }')
    jobfile=$(echo $line | awk '{ print $2 }')

    cd $dir
    qsub_out=$(qsub $jobfile)
    echo submitted job


    # This is the error message if there are two many jobs in the queue.
    # Should really check for alternative error messages here.
    if ! $(echo $qsub_out | grep "would exceed"); then
      sed -i -e "1d" $HOME/bin/superqueue
    fi
  fi

  sleep 10m # wait 10 minutes before checking again
done

./start_superqueue.sh
echo restarting
