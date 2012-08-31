#!/bin/bash
# This is a very simple bash script which shows a progressbar and waits for the amount of time

echo "waiting $1 seconds"
for i in $(seq 0 $1); do
    cols=$(($(tput cols)-2))
    echo -n "["
    act=$(echo "scale=25;$i/$1*$cols" | bc | cut -d . -f 1)
    for x in $(seq 1 $act); do
	 echo -n "="
    done
    for x in $(seq $(($act+1)) $cols); do
	 echo -n "."
    done
    echo -n -e "]\r"
    sleep 1
done
echo "done"
