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

# echo 'Starting /metno/kvalobs/bin/git_pull:'
if /metno/kvalobs/bin/git_pull > $HOME/var/log/git_pull.log  2> $HOME/var/log/git_pull.error; then
   echo "OK /metno/kvalobs/bin/git_pull"
else
   echo "FAILED /metno/kvalobs/bin/git_pull"
   exit 1
fi
   
# echo 'Starting /usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new:'
if /usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new > $HOME/var/log/run_stinfosys2kvalobs_new.log 2> $HOME/var/log/run_stinfosys2kvalobs_new.error; then
    echo "OK /usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new"
else
    echo "FAILED /usr/lib/kvalobs-metadata/bin/run_stinfosys2kvalobs_new"
    cat $HOME/var/log/run_stinfosys2kvalobs_new.error
    exit 1
fi    

#echo 'Starting /usr/lib/kvalobs-metadata/bin/kvmeta_all:'
# /usr/lib/kvalobs-metadata/bin/kvmeta_all
# echo 'Ending /usr/lib/kvalobs-metadata/bin/kvmeta_all'

if /usr/lib/kvalobs-metadata/bin/kvmeta_all > $HOME/var/log/kvmeta_all.log 2> $HOME/var/log/kvmeta_all.error; then
    echo 'OK /usr/lib/kvalobs-metadata/bin/kvmeta_all'
    # cp -pv /usr/share/kvalobs/metadist/kvmeta_METNO.tar.bz2 /usr/share/kvalobs/metadist/kvmeta.tar.bz2
    # cp -pv /usr/share/kvalobs/metadist/kvmeta_METNO_UTF8.tar.bz2 /usr/share/kvalobs/metadist/kvmeta_UTF8.tar.bz2
    cp -pv /usr/share/kvalobs/metadist_METNOSVV/kvmeta_METNOSVV.tar.bz2 /usr/share/kvalobs/metadist/kvmeta.tar.bz2
    cp -pv /usr/share/kvalobs/metadist_METNOSVV/kvmeta_METNOSVV_UTF8.tar.bz2 /usr/share/kvalobs/metadist/kvmeta_UTF8.tar.bz2
    
    FORTSETTCP=""
    if grep 'Already up-to-date' $HOME/var/log/git_pull.log
    then
        if grep differ $HOME/var/log/run_stinfosys2kvalobs_new.log
        then
	    FORTSETTCP="Fortsett"
        else 
            if grep ulike $HOME/var/log/run_klima2kvalobs_all.log
            then
		FORTSETTCP="Fortsett"
            else
                echo "Avbryt - ingen oppdateringer"
            fi
        fi
    else
	FORTSETTCP="Fortsett"
    fi

    if [ $FORTSETTCP = "Fortsett" ]; then
	cp -p /usr/share/kvalobs/metadist/kvmeta.tar.bz2 /usr/share/kvalobs/metadist/kvmeta_UTF8.tar.bz2 /usr/share/kvalobs/metadist_SVV/kvmeta_SVV.tar.bz2 /usr/share/kvalobs/metadist_PROJ/kvmeta_PROJ.tar.bz2 /var/www/html/kvalobs
	echo "Fortsett"
    fi
else
   cat $HOME/var/log/kvmeta_all.error
   for E in error Error ERROR
   do
      if grep -q $E $HOME/var/log/run_metadata_instance.log; then
         echo "$E run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
         grep $E $HOME/var/log/run_metadata_instance.log
      fi
   done
   echo "FAILED /usr/lib/kvalobs-metadata/bin/kvmeta_all"   
   exit 1
fi

for E in error Error ERROR
do
   if grep -q $E $HOME/var/log/run_metadata_instance.log; then
      echo "$E run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
      grep $E $HOME/var/log/run_metadata_instance.log
      echo "$E is wrong"
      exit 1
   fi
done

for W in warning Warning WARNING
do 
   if grep -q $W $HOME/var/log/run_metadata_instance.log; then
      echo "$W run_metadata_instance.log" | $HOME/bin/monitor/monitor_message.sh
      grep $W $HOME/var/log/run_metadata_instance.log
      echo "$W is wrong"
      exit 1
   fi
done

# echo "auto `date +'%Y-%m-%d'`" > $HOME/var/log/auto.finished_log
duration=$SECONDS

$HOME/bin/monitor/monitor_log.sh auto $duration

# echo "END"
