#!/usr/bin/python3

import sys
import glob
import os
import re
import psycopg2
from collections import defaultdict
## import stinfosys
from stinfosys import *

if( len(sys.argv) < 3 ):
    print("To few arguments")
    exit(1)

print ( 'Argument 1:', str(sys.argv[1]) )
p_outer_limit=sys.argv[1]

print ( 'Argument 2:', str(sys.argv[2]) )
p_paramid=sys.argv[2]

try:
    # use our connection values to establish a connection
    conn = st_connect()
except Exception as e:
    print("can't connect")
    print(e)

c_range_check = conn.cursor()

c_range_check.execute("select * from range_check_data
