#! /bin/bash

export PERL5LIB=$HOME/lib/perl5
# mkdir -pv $PERL5LIB

DUMPDIR=$HOME/dumpdir/utesperring_update
mkdir -p $DUMPDIR
FILE=utesperring_update.`date +'%Y-%m-%dT%H'`.sql
LOGDIR=$HOME/log/utesperring
mkdir -p $LOGDIR
UTESPERRING=$HOME/share/utesperring/
mkdir -p $UTESPERRING

echo $FILE

$HOME/bin/kro/utesperring_update.pl > $DUMPDIR/$FILE
if ! [ -s  $DUMPDIR/$FILE ]; then
     echo "Filen $DUMPDIR/$FILE er tom" > $LOGDIR/utesperring_update.log
     exit 1
fi

###########################
set -a  # export variables to the environment of subsequent commands
set -e  # Exit if a simple shell command fails
#set -x  # for debugging, remove later

MAILTO="terjeer@met.no"
OKDB="false"

PSQL=psql
PGDATABASE=kvalobs
PGUSER=kvalobs
: ${PGUSER:=$USER}
: ${PGPORT:=5432}
: ${PGHOST:=localhost}

# echo "mypghost $PGHOST:$PGPORT:$PGDATABASE:$PGUSER:$PGPASSWORD"

# Create a .pgpass file to use so we do not need to give the
# password for each call to psql
# It works by creating a temporary file. Get a filehandle (3) to the file
# and delete it. Set the PGPASSFILE environment variable to /proc/PID/fd/3
# write the credentials to the file. The file is automaticly removed on exit.

rm -f "$HOME/.pgpass.kvget.*"
PGPASSFILE=$(mktemp $HOME/.pgpass.kvget.XXXXXXX)
chmod 0600 $PGPASSFILE
exec 3>$PGPASSFILE
rm $PGPASSFILE
PGPASSFILE="/proc/$$/fd/3"
# echo "PGPASSFILE: $PGPASSFILE"

if [ -f $HOME/.pgpass ]; then
    echo "The file $HOME/.pgpass does exist"
else
    echo "The file $HOME/.pgpass does not exist"
    echo "The file $HOME/.pgpass does not exist" | mail -s "kvget_utesperring: The file $HOME/.pgpass does not exist" $MAILTO
    exit 1
fi


for ll in `cat $HOME/.pgpass | grep 'kvalobs:kvalobs'| cut -f1 -d:`
do
       echo $ll	
       PGHOST=$ll
       # echo "HEI000"
       if cat $HOME/.pgpass | grep $ll | grep 'kvalobs:kvalobs' 1>&3
       then
          # echo "HEI01"
	  # PGHOST="brumle"
	  PGHOST=$ll 
	  if pg_isready
	  then
              VARn=`$PSQL --quiet --tuples-only -c 'select pg_is_in_recovery()'`
              VAR=`echo $VARn | tr -d '\n'`
              # echo -e "length(VAR)==$(echo -ne "${VAR}" | wc -m)"
              #if [ "z$VAR" != "z" ] && [ $VAR == "f" ]; then
              if [ "z$VAR" = "zf" ]; then
	          # echo "selected database is $ll"
		  OKDB="true"
	          break 
              fi
	  else
	      echo "Database connection problem : $?"
	      # echo "Database connection problem : $?" | mail -s "kvget_utesperring: Database connection problem " $MAILTO
	      # exit 1
	  fi
       else
	   echo "Noe galt med passordtilordning" | mail -s "kvget_utesperring: Noe galt med passordtilordning" $MAILTO
	   exit 1
       fi
	  
done


if [ "z$OKDB" != "ztrue" ]; then
	echo "No database that is not in recovery is found" | mail -s "kvget_utesperring: No database that is not in recovery is found" $MAILTO
        exit 1
fi

echo "Database OK"

if ! diff -q  $DUMPDIR/$FILE $UTESPERRING/utesperring_update.sql
then
    if [ -f $UTESPERRING/$FILE  ]; then
            mv -uv $UTESPERRING/$FILE $UTESPERRING/$FILE.old
    fi 
    cp -pv $DUMPDIR/$FILE $UTESPERRING/$FILE
    $PSQL -f $UTESPERRING/$FILE
fi
