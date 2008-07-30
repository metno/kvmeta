#! /bin/sh

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

echo "Oppdaterer tabellene station types param obs_pgm model qcx_info"
for TABLE in station types param obs_pgm model qcx_info
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

# Tables  algorithms, checks and station_param need several scripts
# for updating
for COMMAND in "run_QC1-1 all"  "run_QC1-3 all" \
    "run_QC1-4 all"  "checks_auto QC1-1_checks"  "checks_auto QC1-3a_checks" \
    "checks_auto  QC1-3b_checks" "checks_auto  QC1-4_checks"
do
    $LIBEXECDIR/$COMMAND
done 


for COMMAND in run_algorithm_all run_station_param_all  run_checks_all
do
    echo "$LIBEXECDIR/$COMMAND" > $DUMPDIR/$COMMAND.out
    $LIBEXECDIR/$COMMAND > $DUMPDIR/$COMMAND.out
done  


echo "Sjekker antall linjer i tabellene algorithms checks station_param"
for TABLE in algorithms checks station_param
do
    assert_table_not_empty $TABLE
done


## midlertidige saker er her nederst
$PSQL -c "update station set wmonr=89504 where stationid=99990"
