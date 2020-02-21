#!/usr/bin/python3

import sys
import glob
import os
import re
import psycopg2
from collections import defaultdict
## import stinfosys
from stinfosys import *


if( len(sys.argv) < 2 ):
    print("To few arguments")
    exit(1)

print ( 'Argument 1:', str(sys.argv[1]) )
l_factor=sys.argv[1]


try:
    # use our connection values to establish a connection
    conn = st_connect()
except Exception as e:
    print("can't connect")
    print(e)


c_st_cat= conn.cursor()
c_select_data= conn.cursor()
c_insert_data= conn.cursor()

c_st_cat.execute("select distinct stationid from range_check_data where paramid=81 and stationid in ( select distinct stationid from range_check_st_cat where paramid=81 and ( kyst_innland='I' or kyst_innland='K' )");

for l_st, in c_st_cat:    
    c_select_data.execute("INSERT INTO range_check_data SELECT stationid, month, 83, amsl, st_low * " + l_factor + ", st_lowest * " + l_factor + ", calc_low * " + l_factor + ", calc_lowest * " + l_factor + ", no_of_years, st_high * " + l_factor + ", st_highest * " + l_factor + ", calc_high * " + l_factor + ", calc_highest * " + l_factor + ", countyid, hlevel, low * " + l_factor + ", lowest * " + l_factor + ", high * " + l_factor + ", highest * " + l_factor + ", edit_dato, st_group, edited_by,  edited_at from range_check_data where paramid=81 and stationid=" + str(l_st))
    conn.commit()
    
    #for stationid, month, paramid, amsl, st_low, st_lowest, calc_low, calc_lowest, no_of_years, st_high, st_highest, calc_high, calc_highest, countyid, hlevel, low, lowest, high, highest, edit_dato, st_group, edited_by,  edited_at in c_select_data:
        #print ( stationid, month, paramid, amsl, st_low, st_lowest, calc_low, calc_lowest, no_of_years, st_high, st_highest, calc_high, calc_highest, countyid, hlevel, low, lowest, high, highest, edit_dato, st_group, edited_by,  edited_at )
    
    
