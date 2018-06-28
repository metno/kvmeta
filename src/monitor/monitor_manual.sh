#!/bin/bash

DIR=$HOME/var/log/

if [ -d $DIR ]; then
    # echo "OK $DIR"
    cd $DIR
else
   echo "Missing directory: $DIR"
   exit 1
fi

ARG=$1

# echo $ARG

for tt in $ARG
do
    if [ ! -f ${tt}.finished_log ]; then echo "monitoring metakvalobs, file not exist"; echo ${tt}.finished_log; fi
done
 

TT=`for tt in $ARG; do find $DIR -type f -name ${tt}.finished_log -mmin +720; done`

if [ -n "$TT" ]; then echo "monitoring metakvalobs, filetime longer than 12 hours"; echo $TT; fi


