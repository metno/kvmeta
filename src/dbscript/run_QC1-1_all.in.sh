#! /bin/bash

## Script to update metadata tables in Kvalobs.

set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later


#if ! [ $PGHOST ]; then
#    echo "Environment variable PGHOST er ikke satt! Avslutter..."
#    exit 1
#fi

LIBEXECDIR=__PKGLIBBINDIR__
PERL5LIB=__PERL5LIB__

if [ -f  $HOME/etc/metakvalobs.conf ]; then
   . $HOME/etc/metakvalobs.conf
else
   echo "Missing file:  $HOME/etc/metakvalobs.conf"
   exit 1
fi

#if [ -z "$PGPASSWORD" ]; then
#    PGPASSWORD=`grep dbpass ~/.kvpasswd | sed -e 's/ *dbpass *//'`
#fi

mkdir -p $DUMPDIR
cd $DUMPDIR

PGDATABASE=kvalobs
PGUSER=kvalobs


if [ "z$PGHOST" != "z" ]; then
	PGHOST=localhost
fi




## ** Subroutines **
assert_table_not_empty() {
	NUM_ROWS=`psql -t -c "select count(*) from $1"`
	if [ $NUM_ROWS -eq 0 ]; then
		echo "ERROR: tabellen $1 er tom."
		exit 1
	fi
}

PSQL=psql 

## ** MAIN **
echo "Oppdaterer tabellen station_param"

$PSQL -a -c "truncate table station_param"

# This code only generates the file  QC1-1.out in the directory this code is running
$LIBEXECDIR/dbQC1-1 QC1-1_stasjonsGrenser QC1-1_fasteGrenser QC1-1param

# This runs in a cronjob --> use methods that do not stop everything because of duplicates in the QC1-1.out file
# --> use  station_param2kvalobsdb instead of just: $PSQL -a -c "\copy station_param from QC1-1.out DELIMITER '|'"
# If one gives  only one argument to the script station_param2kvalobsdb it takes the fromfile from the current directory, 
# that is the file  QC1-1.out generated in the $DUMPDIR directory  is used
echo "$LIBEXECDIR/station_param2kvalobsdb QC1-1.out > $DUMPDIR/sp_QC1-1.log"
$LIBEXECDIR/station_param2kvalobsdb QC1-1.out > $DUMPDIR/sp_QC1-1.log
$PSQL -a -c "select count(*) from station_param where stationid in (select distinct stationid from station where maxspeed > 0)" > $DUMPDIR/sp_speed_QC1-1_1.out

$LIBEXECDIR/dbQC1-1_only_QC1-1param.pl QC1-1param > $DUMPDIR/only_QC1-1param.log

echo "$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out nonhour > $DUMPDIR/station_param_QC1-1.log"
$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out nonhour > $DUMPDIR/station_param_QC1-1.log

$PSQL -a -c "select count(*) from station_param where stationid in (select distinct stationid from station where maxspeed > 0)" > $DUMPDIR/sp_speed_QC1-1_2.out

$PSQL -a -c "delete from station_param where stationid in (select distinct stationid from station where maxspeed > 0)" > $DUMPDIR/sp_speed_QC1-1_2_delete.out

$PSQL -a -c "\copy station_param to QC1-1_all.out DELIMITER '|'"


## COPY TO station_param   
for FILE in QC1-1_all.out
do       
    if ! diff -q  $DUMPDIR/$FILE  $METADIR/station_param/station_param_auto/$FILE
    then
        if [ -s $DUMPDIR/$FILE ]; then
            cp -upv $DUMPDIR/$FILE $METADIR/station_param/station_param_auto/$FILE
            cp -upv $DUMPDIR/$FILE $METADIR_AUTO/station_param_auto/$FILE
        else
            echo "Empty file:  $DUMPDIR/$FILE"
        fi
    fi
done
