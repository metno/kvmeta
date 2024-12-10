#!/bin/bash

if [ -f  $HOME/etc/mailtolist.conf ]; then
   . $HOME/etc/mailtolist.conf
else
   echo "Missing file:  $HOME/etc/mailtolist.conf"
   exit 1
fi

DIR=$HOME/var/log/

if [ -d $DIR ]; then
    # echo "OK $DIR"
    cd $DIR
else
   echo "Missing directory: $DIR"
   exit 1
fi

ARG=$1

echo $ARG
echo $MAILTOLIST

for tt in $ARG
do
   if [ ! -f ${tt}.finished_log ]; then echo ${tt}.finished_log | mail -s "monitoring metakvalobs, file not exist" $MAILTOLIST; fi
done
 

TT=`for tt in $ARG; do find $DIR -type f -name ${tt}.finished_log -mmin +721; done`

if [ -n "$TT" ]; then echo $TT | mail -s "monitoring metakvalobs" $MAILTOLIST; fi

#for tt in $ARG
#do
#   curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary @${HOME}/var/log/${tt}.influxdb
#done 

# echo $TT
