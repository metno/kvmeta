#! /bin/sh

set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later

#-----------------------------------
# DAYS means to delete files older than this number of days
DAYS=+10
#-----------------------------------

DIR=/metno/kvalobs
find $DIR -name '*-20*' -type f -mtime $DAYS -exec rm -f {} \;

# echo "cleanup_metno_kvalobs `date +'%Y-%m-%d'`" > $HOME/var/log/cleanup_metno_kvalobs.finished_log
$HOME/bin/monitor/monitor_log.sh cleanup_metno_kvalobs
