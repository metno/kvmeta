#!/bin/bash

date

set -e  # Exit if a simple shell command fails

export PYTHONPATH=$HOME/lib/python

export ORACLE_HOME=/usr/lib/oracle/11.2/client64
export PATH=$PATH:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

mkdir -pv $HOME/share/range_check/

echo "start make_range_check.py"

$HOME/bin/range_check/make_range_check_now.py 5 211 MET $HOME/share/range_check/range_check_211.out >  $HOME/var/log/make_range_check_211.log 2>&1
$HOME/bin/range_check/make_range_check_now.py 5 81  MET $HOME/share/range_check/range_check_81.out >  $HOME/var/log/make_range_check_81.log 2>&1
$HOME/bin/range_check/make_range_check_now.py 5 173 MET $HOME/share/range_check/range_check_173.out >  $HOME/var/log/make_range_check_173.log 2>&1
$HOME/bin/range_check/make_range_check_now.py 5 178 MET $HOME/share/range_check/range_check_178.out >  $HOME/var/log/make_range_check_178.log 2>&1
# $HOME/bin/range_check/make_range_check.py 5 211 SVV $HOME/share/range_check/range_check_211_SVV.out >  $HOME/var/log/make_range_check_211_SVV.log
$HOME/bin/range_check/make_range_check_now.py 5 81 SVV $HOME/share/range_check/range_check_81_SVV.out >  $HOME/var/log/make_range_check_81_SVV.log 2>&1

echo "done make_range_check.py"

cat $HOME/share/range_check/range_check_211.out $HOME/share/range_check/range_check_81.out $HOME/share/range_check/range_check_173.out $HOME/share/range_check/range_check_178.out $HOME/share/range_check/range_check_81_SVV.out > $HOME/share/range_check/range_check_data.out

psql -h stinfodb.met.no -U stinfosys -c "delete from range_check_data where stationid in (select stationid from station where totime is NULL)"
psql -h stinfodb.met.no -U stinfosys -c "\copy range_check_data(stationid,month,paramid,st_low,st_lowest,no_of_years,st_high,st_highest,edit_dato) from $HOME/share/range_check/range_check_data.out DELIMITER '|'"


# update amsl in table range_check_data not necessary

$HOME/bin/range_check/make_range_check2_all.py 5 211 > $HOME/var/log/make_range_check2_all_211.log
$HOME/bin/range_check/make_range_check2_all.py 5 81  > $HOME/var/log/make_range_check2_all_81.log
$HOME/bin/range_check/make_range_check2_all.py 5 173 > $HOME/var/log/make_range_check2_all_173.log
$HOME/bin/range_check/make_range_check2_all.py 5 178 > $HOME/var/log/make_range_check2_all_178.log

# make low,lowest,high, highest
$HOME/bin/range_check/make_range_check_low_high.py
## $HOME/bin/range_check/make_range_check_low_high.py 5 211
## $HOME/bin/range_check/make_range_check_low_high.py 5 81
## $HOME/bin/range_check/make_range_check_low_high.py 5 173
## $HOME/bin/range_check/make_range_check_low_high.py 5 178

# make range_check_data for paramid 83 based on 81 multiplied with l_factor
# $HOME/bin/range_check/make_range_check_83.py l_factor
$HOME/bin/range_check/make_range_check_83.py 2  >  $HOME/var/log/make_range_check_83.log

# Make range_check_data for svv data is based on the SVV reference stations
$HOME/bin/range_check/make_svv_range_check_211.py  >  $HOME/var/log/make_range_check_211_SVV.log


#delete from t_range_check_data;
#p_calc_range_check1_met(5,211);
#p_calc_range_check1_met(5,81);
#p_calc_range_check1_met(5,173);
#p_calc_range_check1_met(5,178);
#--p_calc_range_check1_svv(5,211);
#p_calc_range_check1_svv(5,81);
#p_calc_range_check2_all(5,211);
#p_calc_range_check2_all(5,81);
#p_calc_range_check2_all(5,173);
#p_calc_range_check2_all(5,178);

#p_calc_range_check3;
#p_svv_range_check_temp;
#null;

date
