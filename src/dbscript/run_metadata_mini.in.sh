#! /bin/bash

## Script to update metadata tables in Kvalobs.


set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later



#if ! [ $PGHOST ]; then
#    echo "Environment variable PGHOST er ikke satt! Avslutter..."
#    exit 1
#fi

KVCONFIG=__KVCONFIG__
LIBEXECDIR=__PKGLIBBINDIR__
PERL5LIB=__PERL5LIB__
METADIR=`$KVCONFIG --datadir`/kvalobs/metadata

#if [ -z "$PGPASSWORD" ]; then
#    PGPASSWORD=`grep dbpass ~/.kvpasswd | sed -e 's/ *dbpass *//'`
#fi

PGDATABASE=kvalobs
PGUSER=kvalobs


if [ "z$PGHOST" != "z" ]; then
	PGHOST=localhost
fi

DUMPDIR="/tmp/$USER/kvalobs/var/log/tabledump"
rm -rf $DUMPDIR
mkdir -p -m700 /tmp/$USER/kvalobs/var/log/
mkdir -m700 $DUMPDIR
LOGFILE="$DUMPDIR/table_update.log"


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

#echo "Sletter tabellene metadatatype og station_metadata"
#$PSQL -a -c "TRUNCATE metadatatype CASCADE"
#$PSQL -a -c "\copy metadatatype from '$METADIR/metadatatype/metadatatype.out' DELIMITER '|'"

echo "Oppdaterer tabellene station types param obs_pgm station_metadata model qcx_info operator"
for TABLE in station types param obs_pgm station_metadata model qcx_info operator
do
    $PSQL -c "\copy $TABLE to $DUMPDIR/$TABLE.out DELIMITER '|'"
       
    if ! diff -q  $DUMPDIR/$TABLE.out $METADIR/$TABLE/$TABLE.out; then
		$LIBEXECDIR/run_$TABLE
		echo -e `date` "\t$TABLE updated" >> $LOGFILE
		assert_table_not_empty $TABLE
    fi
done


echo "Oppdaterer tabellene  algorithms checks station_param"
for TABLE in algorithms checks station_param
do
    $PSQL -a -c "truncate table $TABLE"
done


## Table station_param need several scripts for updating
#for COMMAND in "run_QC1-1 all"  "run_QC1-3 all" \
#    "run_QC1-4 all"
#do
#    $LIBEXECDIR/$COMMAND
#done 
#
#
#echo "$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out > $DUMPDIR/station_param_QC1-1.log"
#$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out > $DUMPDIR/station_param_QC1-1.log

$PSQL -a -c "\copy station_param from '$METADIR/station_param/station_param_auto/QC1-1_all.out' DELIMITER '|'" 

# Table station_param need several scripts for updating
for COMMAND in  "run_QC1-3 all" "run_QC1-4 all"
do
    $LIBEXECDIR/$COMMAND
done

echo "$LIBEXECDIR/station_param2kvalobsdb station_param_QCX.out nonhour > $DUMPDIR/station_param_QCX.log"
$LIBEXECDIR/station_param2kvalobsdb station_param_QCX.out nonhour > $DUMPDIR/station_param_QCX.log


# Table checks need several scripts for updating
for COMMAND in "checks_auto QC1-1_checks"  "checks_auto QC1-3a_checks" \
    "checks_auto  QC1-3b_checks" "checks_auto  QC1-4_checks"
do
    $LIBEXECDIR/$COMMAND
done


echo "$LIBEXECDIR/checks2kvalobsdb checks_qcx.out > $DUMPDIR/checks_qcx.log"
$LIBEXECDIR/checks2kvalobsdb checks_qcx.out > $DUMPDIR/checks_qcx.log


for COMMAND in run_algorithm_all run_station_param_all  run_checks_all
do
    echo "$LIBEXECDIR/$COMMAND > $DUMPDIR/$COMMAND.out"
    $LIBEXECDIR/$COMMAND > $DUMPDIR/$COMMAND.out
done  
