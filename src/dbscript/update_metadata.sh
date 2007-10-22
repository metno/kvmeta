#!/bin/sh

## Script for updating metadata on test machine (rime) or
## production machine (kvalobs = warm/cool)

## Usage: $0 <rime | kvalobs>


Continue_or_not() {
echo -n "Continue $1 (y/n)?  "
read ANS
ANS=`echo $ANS | tr "[A-Z]" "[a-z]"` # convert to lower case.
if [ $ANS = y -o $ANS = yes ]; then
    echo "Ok, continuing..."
    echo
else
    echo "Aborting."
    exit 1
fi
}



USAGE="Usage: $0  <rime | kvalobs>"

if [ $# -ne 1 ]
then
    echo $USAGE
    exit 1
fi

DBHOST=$1

case "$1" in
    rime)
	;;
    kvalobs)
	;;
    *)
	echo $USAGE
	exit 1
	;;
esac

if [ $DBHOST = kvalobs ]; then
    THIS_HOST=`hostname`
    if [ "$THIS_HOST" != 'overcast' ]; then
	echo "You have to be at overcast to run this script for kvalobs, not at $THIS_HOST"
	exit 1
    fi
    USER=`whoami`
    if [ "$USER" != 'kvalobsdev' ]; then
	echo "You have to be user kvalobsdev to run this script for kvalobs, not user $USER"
	exit 1
    fi
    echo "Updating of metadata on host kvalobs should be done between 20 and 40 minutes past whole hour"
    echo "Also remember to notice Helpdesk that Kvalobs will be shut down for some few minutes"
    Continue_or_not
fi


echo -e "\tcd $METADIR/share/metadata"
cd $METADIR/share/metadata || {
    echo "Perhaps enviroment variable \$METADIR is not set?"
    echo "Aborting."
    exit 1
}

echo -e "\tcvs update ...."
cvs update;

Continue_or_not "with installing $KVALOBS in runtime system"


echo -e "\t./INSTALL -d $KVALOBS"
./INSTALL -d $KVALOBS


echo -e "\tssh kvalobs@$DBHOST kvstop"
ssh kvalobs@$DBHOST kvstop


Continue_or_not "with run_metadata"

echo -e "\trun_metadata on $DBHOST"
if [ $DBHOST = kvalobs ]; then
    ssh kvalobs@kvalobs run_metadata
else
    run_metadata
fi


Continue_or_not "with kvstart"

echo -e "\tssh kvalobs@$DBHOST kvstart"
ssh kvalobs@$DBHOST kvstart

echo Finished!


