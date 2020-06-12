#!/usr/bin/python3

import sys
import glob
import os
import re
import psycopg2
from collections import defaultdict
## import stinfosys
from stinfosys import *

import cx_Oracle

import datetime

today = datetime.date.today()
print(today)
first = today.replace(day=1)
print(first)
lastMonth = first - datetime.timedelta(days=1)
print(lastMonth)
print(lastMonth.strftime("%Y%m%d"))
last_time=lastMonth.strftime("%Y%m%d") + '23'
print(last_time)

nowtime=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
print(nowtime)
edit_dato=nowtime

# p_calc_range_check1_met(5,211);
# p_calc_range_check1_met(5,81);
# p_calc_range_check1_met(5,173);
# p_calc_range_check1_met(5,178);
# --p_calc_range_check1_svv(5,211); Kjøres ikke denne ??
# p_calc_range_check1_svv(5,81);

# Connect as user "hr" with password "welcome" to the "orclpdb1" service running on this computer.
# connection = cx_Oracle.connect("kaxx", "kaxx", "typhoon.met.no/klima11")
#kaxx/kaxx@hamsin.oslo.dnmi.no:1521/dvh10
connection = cx_Oracle.connect("kaxx", "kaxx", "hamsin.oslo.dnmi.no/dvh10")

conn = st_connect()

#cursor = connection.cursor()
#cursor.execute("select paramid,name from t_param")
#for lparamid, lname in cursor:
#    print("Values:", lparamid, lname)



if( len(sys.argv) < 5 ):
    print("To few arguments")
    exit(1)
        
print ( 'Argument 1:', str(sys.argv[1]) )
p_outer_limit=sys.argv[1]

print ( 'Argument 2:', str(sys.argv[2]) )
p_paramid=sys.argv[2]

print ( 'Argument 3:', str(sys.argv[3]) )
p_st_group=sys.argv[3]

print ( 'Argument 4:', str(sys.argv[4]) )
p_outputfilename=sys.argv[4]

print("p_paramid", p_paramid)
print("p_paramid_type", type(p_paramid))

# NB!  p_paramid_char is not the name of p_paramid, this is an associated parameter to use for asking t_month
if( p_paramid == "81" ):
    p_paramid_char_min='FXN'
    p_paramid_char_max='FXX'
elif( p_paramid == "173" ):
    # p_paramid_char='POM'
    p_paramid_char_min='PON'
    p_paramid_char_max='POX'
elif( p_paramid == "178" ):
    # p_paramid_char='PRM'
    p_paramid_char_min='PRN'
    p_paramid_char_max='PRX'
elif( p_paramid == "211" ):
    # p_paramid_char='TAM' not in use
    p_paramid_char_min='TAN'
    p_paramid_char_max='TAX'
else:
    exit(0)

# l_paramid_char= substr( p_paramid_char, 1, 2 );
# l_paramid_char=p_paramid_char[:2]

print("p_paramid",p_paramid)
print("p_paramid_char_min",p_paramid_char_min)
print("p_paramid_char_max",p_paramid_char_max)

with open(p_outputfilename,'w') as f:
  #cursor2 = connection.cursor()
  cursor3 = connection.cursor()
  cursor4 = connection.cursor()
  ###cursor2.execute("select distinct stnr from t_grensev_st_cat where st_group='MET' and paramid=:p_paramid",p_paramid)
  #cursor2.execute("select distinct stnr from t_grensev_st_cat where st_group='" + p_st_group + "' and paramid=" + p_paramid)
  c_refst = conn.cursor()
  c_refst.execute("select distinct stationid from range_check_st_cat where st_group='" + p_st_group + "' and paramid=" + p_paramid + " and stationid in (select stationid from station where totime is NULL)")
  print("select distinct stationid from range_check_st_cat where st_group='" + p_st_group + "' and paramid=" + p_paramid + " and stationid in (select stationid from station where totime is NULL)")
  
  L_TELLER=0 #=1
  l_finnes=0
  for l_stnr, in c_refst:
      print("l_stnr:", l_stnr)
      L_TELLER += 1 
      print("L_TELLER", type(L_TELLER))          
      for i in range(1,13):
            print ("i=",i)
            ### cursor3.execute("""select count(TAN)
            cursor3.execute("""select count(""" + p_paramid_char_min + """)
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """ and to_char ( m.dato,'mm')=""" + str(i) +
                               """ and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('""" + last_time + """','yyyymmddhh24')""")
            
            tuple_l_finnes=cursor3.fetchall()
            l_finnes_l=tuple_l_finnes[0]
            l_finnes=l_finnes_l[0]

            print ("l_finnes2=", l_finnes)

            if( l_finnes > 0):
                 no_of_years=l_finnes
                 cursor4.execute("""select MIN (""" + str(p_paramid_char_min) + """), MAX(""" + str(p_paramid_char_max) + """)
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """ and to_char ( m.dato,'mm')=""" + str(i) +
                               """ and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('""" + last_time + """','yyyymmddhh24')
                               GROUP BY stnr, TO_CHAR (dato, 'mm' )
                               """)
                 
                 for st_low, st_high in cursor4:
                    # if( st_high is None ):
                    #    print( "type5:", str(type(st_high)),str(type(p_outer_limit)) )
                    # if( st_low is None ):
                    #    print( "type5:", str(type(st_low)),str(type(p_outer_limit)) )
                    if( ( st_high is not None ) and ( st_low is not None ) ):
                        st_lowest="{:.1f}".format(float(st_low) - float(p_outer_limit))
                        st_highest="{:.1f}".format(float(st_high) + float(p_outer_limit))
                        # print ( "HELLO" + str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|' +  str(st_low) + '|' + str(st_lowest) + '|' + str(no_of_years) + '|' + str(st_high) + '|' + str(st_highest) + '|' + str(edit_dato)) 
                        print ( str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|' +  str(st_low) + '|' + str(st_lowest) + '|' + str(no_of_years) + '|' + str(st_high) + '|' + str(st_highest) + '|' + str(edit_dato), file=f )
                    else:
                        print("type:", str(type(st_high)),str(type(st_low)),str(type(p_outer_limit)), l_stnr) 
                 
            else:
                print ( str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|\\N|\\N|\\N|\\N|\\N|' + str(edit_dato), file=f )
