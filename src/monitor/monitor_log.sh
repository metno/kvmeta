#!/bin/bash

DIR=$HOME/var/log/

if [ -d $DIR ]; then
    # echo "OK $DIR"
    cd $DIR
else
   echo "Missing directory: $DIR"
   exit 1
fi

if [ -z "$1" ]
then
    echo "No argument supplied"
else 
    PROGRAM=$1
    echo "$PROGRAM `date +'%Y-%m-%d'`" > $DIR/${PROGRAM}.finished_log
fi

if [ -n "$2" ]
then
    duration=$2
    echo "$PROGRAM value=$duration" > $DIR/${PROGRAM}.influxdb
fi
