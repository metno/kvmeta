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


c_update= conn.cursor()

#HIGH
#a)
c_update.execute("update range_check_data set high=st_high, highest=st_highest where st_high is NOT NULL")
conn.commit()

#b)
c_update.execute("update range_check_data set high=calc_high, highest=calc_highest where st_high is NULL and calc_high is NOT NULL")
conn.commit()

#c)
c_update.execute("update range_check_data set high=calc_high, highest=calc_highest where calc_high > st_high and st_high is NOT NULL and calc_high is NOT NULL")
conn.commit()


#LOW
#a)
c_update.execute("update range_check_data set low=st_low, lowest=st_lowest where st_low is NOT NULL")
conn.commit()

#b)
c_update.execute("update range_check_data set low=calc_low, lowest=calc_lowest where st_low is NULL and calc_low is NOT NULL")
conn.commit()

#c)
c_update.execute("update range_check_data set low=calc_low, lowest=calc_lowest where calc_low < st_low and st_low is NOT NULL and calc_low is NOT NULL")
conn.commit()

# paramid=81
c_update.execute("update range_check_data set low=0 where low < 0 and paramid=81")
conn.commit()

c_update.execute("update range_check_data set lowest=0 where lowest < 0 and paramid=81")
conn.commit()

c_update.execute("update range_check_data set st_low=0 where st_low < 0 and paramid=81")
conn.commit()

c_update.execute("update range_check_data set st_lowest=0 where st_lowest < 0 and paramid=81")
conn.commit()

c_update.execute("update range_check_data set calc_low=0 where calc_low < 0 and paramid=81")
conn.commit()

c_update.execute("update range_check_data set calc_lowest=0 where calc_lowest < 0 and paramid=81")
conn.commit()

# paramid=178
c_update.execute("update range_check_data set st_lowest=931 where st_lowest<931 and paramid=178")
conn.commit()

c_update.execute("update range_check_data set lowest=931 where lowest<931 and paramid=178")
conn.commit() 
