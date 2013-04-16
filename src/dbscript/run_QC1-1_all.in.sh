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
echo "Oppdaterer tabellen station_param"

$PSQL -a -c "truncate table station_param"

$LIBEXECDIR/dbQC1-1 QC1-1_stasjonsGrenser QC1-1_fasteGrenser QC1-1param
## $PSQL -a -c "delete from station_param where qcx like 'QC1-1%'"
#$PSQL -a -c "\copy station_param from QC1-1.out DELIMITER '|'"

# Because this is supposed to run in a cronjob we need methods that do not stop everything because of duplicates in the QC1-1.out file
echo "$LIBEXECDIR/station_param2kvalobsdb QC1-1.out > $DUMPDIR/sp_QC1-1.log"
$LIBEXECDIR/station_param2kvalobsdb QC1-1.out > $DUMPDIR/sp_QC1-1.log

echo "$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out nonhour > $DUMPDIR/station_param_QC1-1.log"
$LIBEXECDIR/station_param2kvalobsdb station_param_QC1-1.out nonhour > $DUMPDIR/station_param_QC1-1.log

$PSQL -a -c "\copy station_param to QC1-1_all.out DELIMITER '|'"
