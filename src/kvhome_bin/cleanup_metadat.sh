#! /bin/sh

set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later

#-----------------------------------
# DAYS means to delete files older than this number of days
DAYS=+10
#-----------------------------------

DIR=/metno/kvalobs/
find $DIR -name 'metadat-*' -type f -mtime $DAYS -exec rm -f {} \;

# echo "cleanup_metadat `date +'%Y-%m-%d'`" > $HOME/var/log/cleanup_metadat.finished_log
$HOME/bin/monitor/monitor_log.sh cleanup_metadat
