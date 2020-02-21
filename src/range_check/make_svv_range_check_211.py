#!/usr/bin/python3

import sys
import glob
import os
import re
import psycopg2
from collections import defaultdict
## import stinfosys
from stinfosys import *

try:
    # use our connection values to establish a connection
    conn = st_connect()
except Exception as e:
    print("can't connect")
    print(e)


c_svvst = conn.cursor()
c_refst = conn.cursor()
c_select = conn.cursor()
c_insert = conn.cursor()

c_svvst.execute("select stationid, kyst_innland, countyid from range_check_st_cat where paramid = 211 and st_group = 'SVV' order by stationid")

for l_svvst, l_kyst_innland, l_countyid in c_svvst:
    c_refst.execute("select stationid from range_check_ref where countyid=" + str(l_countyid) + " and kyst_innland='" + str(l_kyst_innland) + "' and param_group=211" )
    for l_refst, in c_refst:
        c_select.execute("select count(*) from range_check_data where stationid=" + str(l_svvst) + " and paramid=211")
        count, = c_select.fetchone()
        print( "count=" + str(count) + ": l_svvst= " + str(l_svvst) )
        if ( count == 0 ):
            print( "count == 0: l_svvst= " + str(l_svvst) )
            c_insert.execute("""insert into range_check_data select """ + str(l_svvst) + """, month, paramid, amsl, st_low, st_lowest, calc_low, calc_lowest, no_of_years,
                            st_high, st_highest, calc_high, calc_highest, countyid, hlevel, low, lowest, high, highest, edit_dato, st_group, edited_by, edited_at 
                            from range_check_data
                            where stationid=""" + str(l_refst) + """ and paramid=211""")
            conn.commit()
