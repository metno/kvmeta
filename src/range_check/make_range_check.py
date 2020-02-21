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


if( p_paramid == "81" ):
    p_paramid_char='FXX'
    print("HELLO")
elif( p_paramid == "173" ):
    p_paramid_char='POM'
elif( p_paramid == "178" ):
    p_paramid_char='PRM'
elif( p_paramid == "211" ):
    p_paramid_char='TAM'
else:
    exit(0)

# l_paramid_char= substr( p_paramid_char, 1, 2 );
l_paramid_char=p_paramid_char[:2]

print("p_paramid",p_paramid)
print("p_paramid_char",p_paramid_char)

with open(p_outputfilename,'w') as f:
  cursor2 = connection.cursor()
  cursor3 = connection.cursor()
  cursor4 = connection.cursor()
  #cursor2.execute("select distinct stnr from t_grensev_st_cat where st_group='MET' and paramid=:p_paramid",p_paramid)
  cursor2.execute("select distinct stnr from t_grensev_st_cat where st_group='" + p_st_group + "' and paramid=" + p_paramid)
  L_TELLER=0 #=1
  l_finnes=0
  for l_stnr, in cursor2:
    print("l_stnr:", l_stnr)
    L_TELLER += 1 
    print("L_TELLER", type(L_TELLER))
    if( p_paramid == "211" ):
        for i in range(1,13):
            print ("i=",i)
            cursor3.execute("""select count(TAN) 
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                               """and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('2019123123','yyyymmddhh24')""")
            
            tuple_l_finnes=cursor3.fetchall()
            l_finnes_l=tuple_l_finnes[0]
            l_finnes=l_finnes_l[0]

            print ("l_finnes=", l_finnes)

            if( l_finnes > 0):
                 no_of_years=l_finnes
                 cursor4.execute("""select MIN (TAN), MAX(TAN), SYSDATE 
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                               """and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('2019123123','yyyymmddhh24')
                               GROUP BY stnr, TO_CHAR (dato, 'mm' )
                               """)
                 
                 #cursor4.execute("""select stnr, to_char (dato,'mm'), MIN (TAN), MAX(TAN),count(TAN),""" +
                 #                """(select count(TAN) 
                 #              from t_month m 
                 #              where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                 #              """and dato between to_date('1957010100','yyyymmddhh24')
                 #                           and to_date('2019123123','yyyymmddhh24'))""" +
                 #              """from t_month m 
                 #              where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                 #              """and dato between to_date('1957010100','yyyymmddhh24')
                 #                           and to_date('2019123123','yyyymmddhh24')
                 #              GROUP BY stnr, TO_CHAR (dato, 'mm' )
                 #              """)

                 for st_low, st_high, edit_dato in cursor4:
                    st_lowest="{:.1f}".format(float(st_low) - float(p_outer_limit))
                    st_highest="{:.1f}".format(float(st_high) + float(p_outer_limit))
                     
                    print ( str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|' +  str(st_low) + '|' + str(st_lowest) + '|' + str(no_of_years) + '|' + str(st_high) + '|' + str(st_highest) + '|' + str(edit_dato), file=f )

                 #

            #else:
            #    print ( l_stnr, i, p_paramid ) 
                    
    else:          
        for i in range(1,13):
            print ("i=",i)
            ### cursor3.execute("""select count(TAN)
            cursor3.execute("""select count(""" + p_paramid_char + """)
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                               """and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('2019123123','yyyymmddhh24')""")
            
            tuple_l_finnes=cursor3.fetchall()
            l_finnes_l=tuple_l_finnes[0]
            l_finnes=l_finnes_l[0]

            print ("l_finnes2=", l_finnes)

            if( l_finnes > 0):
                 no_of_years=l_finnes
                 cursor4.execute("""select MIN (""" + str(p_paramid_char) + """), MAX(""" + str(p_paramid_char) + """), SYSDATE 
                               from t_month m 
                               where stnr=""" + str(l_stnr) + """and to_char ( m.dato,'mm')=""" + str(i) +
                               """and dato between to_date('1957010100','yyyymmddhh24')
                                            and to_date('2019123123','yyyymmddhh24')
                               GROUP BY stnr, TO_CHAR (dato, 'mm' )
                               """)
                 
                 for st_low, st_high, edit_dato in cursor4:
                    st_lowest="{:.1f}".format(float(st_low) - float(p_outer_limit))
                    st_highest="{:.1f}".format(float(st_high) + float(p_outer_limit))
                    
                    # print ( "HELLO" + str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|' +  str(st_low) + '|' + str(st_lowest) + '|' + str(no_of_years) + '|' + str(st_high) + '|' + str(st_highest) + '|' + str(edit_dato)) 
                    print ( str(l_stnr) +  str('|')  +  str(i) + '|' +  str(p_paramid) + '|' +  str(st_low) + '|' + str(st_lowest) + '|' + str(no_of_years) + '|' + str(st_high) + '|' + str(st_highest) + '|' + str(edit_dato), file=f )
                 
