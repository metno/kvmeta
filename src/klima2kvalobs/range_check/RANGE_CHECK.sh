#!/bin/bash

set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later

DVH=$HOME

if [ -f  $DVH/etc/klima.conf ]; then
   . $HOME/etc/klima.conf
else
   echo "Missing file:  $DVH/etc/klima.conf"
   exit 1
fi

sqlplus -S ${KLUSER}/${KLPASSWD}@${KLDATABASE} < RANGE_CHECK.sql
sqlplus -S ${KLUSER}/${KLPASSWD}@${KLDATABASE} < RANGE_PARAM_GROUPS.sql
./RANGE_CHECK2station_param.pl  RANGE_CHECK.lst QC1-1param RANGE_PARAM_GROUPS.lst
