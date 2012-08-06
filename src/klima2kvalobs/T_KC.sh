#! /bin/sh

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

sqlplus -S ${KLUSER}/${KLPASSWD}@${KLDATABASE} < T_KC.sql
./T_KC2kvalobs.pl T_KC.lst > T_KC.out
