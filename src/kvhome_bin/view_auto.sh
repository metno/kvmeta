#!/bin/bash

cat $HOME/var/log/auto.log

MYDATE=`cat $HOME/var/log/auto.finished_log`
MYDATENOW=`date +'%Y-%m-%d'`

if [ "$MYDATE" = "$MYDATENOW" ]; then echo -n "" ; else echo "ULIKE $MYDATE $MYDATENOW"; fi

cat $HOME/var/log/auto.error
							 
