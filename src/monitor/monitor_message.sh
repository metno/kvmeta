#!/bin/bash

if [ -f  $HOME/etc/mailtolist.conf ]; then
   . $HOME/etc/mailtolist.conf
else
   echo "Missing file:  $HOME/etc/mailtolist.conf"
   exit 1
fi

 { read test; echo $test | mail -s "monitoring metakvalobs message" $MAILTOLIST; }
