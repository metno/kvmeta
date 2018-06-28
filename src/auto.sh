#!/bin/sh

set -e  # Exit if a simple shell command fails

SECONDS=0

export ORACLE_HOME=/usr/lib/oracle/11.2/client64
export PATH=$PATH:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

export PGPORT=5432
export PGHOST=localhost
export HOME=/metno/kvalobs
export METADIR=$HOME/kvoss_intern/kvmeta

echo 'Starting /metno/kvalobs/bin/git_pull:'
/metno/kvalobs/bin/git_pull
echo 'Starting /usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new:'
/usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new
echo 'Starting /usr/lib/kvalobs-metadata/bin/kvmeta_all:'
# /usr/lib/kvalobs-metadata/bin/kvmeta_all
# echo 'Ending /usr/lib/kvalobs-metadata/bin/kvmeta_all'

if /usr/lib/kvalobs-metadata/bin/kvmeta_all; then
    echo 'Ending /usr/lib/kvalobs-metadata/bin/kvmeta_all'
    # cp -pv /usr/share/kvalobs/metadist/kvmeta_METNO.tar.bz2 /usr/share/kvalobs/metadist/kvmeta.tar.bz2
    # cp -pv /usr/share/kvalobs/metadist/kvmeta_METNO_UTF8.tar.bz2 /usr/share/kvalobs/metadist/kvmeta_UTF8.tar.bz2
    cp -pv /usr/share/kvalobs/metadist_METNOSVV/kvmeta_METNOSVV.tar.bz2 /usr/share/kvalobs/metadist/kvmeta.tar.bz2
    cp -pv /usr/share/kvalobs/metadist_METNOSVV/kvmeta_METNOSVV_UTF8.tar.bz2 /usr/share/kvalobs/metadist/kvmeta_UTF8.tar.bz2
    grep ulike $HOME/var/log/run_klima2kvalobs_all.log
else
   for E in error Error ERROR
   do
      if grep -q $E $HOME/var/log/run_metadata_instance.log; then
         echo "$E run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
         grep $E $HOME/var/log/run_metadata_instance.log
      fi
   done
   echo 'Someting is wrong'
   exit 1
fi

if grep -q error $HOME/var/log/run_metadata_instance.log; then
    echo "error run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
    grep error $HOME/var/log/run_metadata_instance.log
fi

if grep -q Error $HOME/var/log/run_metadata_instance.log; then
    echo "Error run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
    grep Error $HOME/var/log/run_metadata_instance.log
fi

if grep -q ERROR $HOME/var/log/run_metadata_instance.log; then
    echo "ERROR run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
    grep ERROR $HOME/var/log/run_metadata_instance.log
fi

for W in warning Warning WARNING
do 
   if grep -q $W $HOME/var/log/run_metadata_instance.log; then
      echo "$W run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
      grep $W $HOME/var/log/run_metadata_instance.log
   fi
done

# echo "auto `date +'%Y-%m-%d'`" > $HOME/var/log/auto.finished_log
duration=$SECONDS

$HOME/bin/monitor/monitor_log.sh auto $duration
