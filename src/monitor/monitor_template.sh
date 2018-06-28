#!/bin/bash

DIR="MYDIR"

if [ -d $DIR ]; then
    # echo "OK $DIR"
    cd $DIR
else
   echo "Missing directory: $DIR"
   exit 1
fi

ARG=$1

# echo $ARG

# example "MYMIN" is set to 720, that is the 720 minutes, 12 hours
TT=`for tt in $ARG; do find $DIR -type f -name $tt -mmin +"MYMIN" done`
 
if [ -n "$TT" ]; then echo $TT | mail -s "monitoring mysystem" user@met.no; fi

# echo $TT
