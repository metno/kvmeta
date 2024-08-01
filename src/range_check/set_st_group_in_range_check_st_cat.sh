#!/bin/bash

# psql -h stinfodb.met.no -U stinfosys -c "select distinct stationid from network_station where networkid=46"


# psql -h stinfodb.met.no -U stinfosys -c "select distinct stationid from range_check_st_cat where ( st_group<>'SVV' AND st_group<>'MET' )"

#1 SVV
for SVVSTASJON in `psql -h stinfodb.met.no -U stinfosys -t -c "select distinct stationid from range_check_st_cat where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid in (select distinct stationid from network_station where networkid=46)"`
do
    echo "SVVSTASJON=$SVVSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "select stationid,paramid,st_group,edited_by from range_check_st_cat where stationid=$SVVSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "update range_check_st_cat set st_group='SVV' where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid=$SVVSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "select stationid,paramid,st_group,edited_by from range_check_st_cat where stationid=$SVVSTASJON"
done


#2 MET
for METSTASJON in `psql -h stinfodb.met.no -U stinfosys -t -c "select distinct stationid from range_check_st_cat where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid not in (select distinct stationid from network_station where networkid=46)"`
do
    echo "METSTASJON=$METSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "select stationid,paramid,st_group,edited_by from range_check_st_cat where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid=$METSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "update range_check_st_cat set st_group='MET' where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid=$METSTASJON"
    psql -h stinfodb.met.no -U stinfosys -t -c "select stationid,paramid,st_group,edited_by from range_check_st_cat where ( st_group<>'SVV' AND st_group<>'MET' ) and stationid=$METSTASJON"
done
