#!/usr/bin/python3

import sys
import glob
import os
import re
import psycopg2
from collections import defaultdict
## import stinfosys
from stinfosys import *

# import cx_Oracle

# Hmm, sannsynligvis så må vi importere fra  

#p_calc_range_check2_all(5,211);
#p_calc_range_check2_all(5,81);
#p_calc_range_check2_all(5,173);
#p_calc_range_check2_all(5,178);

# Connect as user "hr" with password "welcome" to the "orclpdb1" service running on this computer.
# connection = cx_Oracle.connect("kaxx", "kaxx", "typhoon.met.no/klima11")
# kaxx/kaxx@hamsin.oslo.dnmi.no:1521/dvh10
# connection = cx_Oracle.connect("kaxx", "kaxx", "hamsin.oslo.dnmi.no/dvh10")


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
    
# create a psycopg2 cursor that can execute queries
c_min = conn.cursor()
c_update_min= conn.cursor()
c_max = conn.cursor()
c_update_max= conn.cursor()


param_const=defaultdict(dict)
param_const["211"]=-0.006
param_const["173"]=-0.1073
param_const["178"]=-0.1073

#try:
#    cursor.execute("select distinct stationid, paramid, fromtime, totime from obspgm_h order by stationid, paramid, fromtime")
#    rows_opgm = cursor.fetchall()
#except Exception as e:
#    print("rows_opgm execute problem")
#    print(e)



c_stationid = conn.cursor()
c_category = conn.cursor()
 
# c_meta = conn.cursor()
c_amsl = conn.cursor()
amsl_dict=defaultdict(dict)
c_amsl.execute("select sta.stationid, sta.amsl from st_amsl sta where totime is NULL or totime in ( select MAX(stb.totime) from st_amsl stb where stationid=sta.stationid)")
for stationid, amsl in c_amsl:
    amsl_dict[stationid]=amsl

      
c_stationid.execute("select distinct stationid from range_check_data where (no_of_years < 15 OR no_of_years is NULL) AND paramid=" + p_paramid)
  
L_TELLER=0 #=1
l_finnes=0
for l_stnr, in c_stationid:
    print("*******l_stnr:", l_stnr)
    l_amsl=""
    if l_amsl in amsl_dict:
        l_amsl=amsl_dict[l_stnr]
    print("l_stnr=",l_stnr,"type_l_amsl",str(type(l_amsl)))
    if( l_amsl is None or l_amsl=="" ):
        l_amsl=10
        print("stationid=",stationid,"l_amsl is set to 10")

    c_category.execute("select countyid, kyst_innland from range_check_st_cat where stationid=" + str(l_stnr) + " and paramid=" + p_paramid)
    for l_countyid, l_kyst_innland in c_category:
        #c_meta.execute("select distinct amsl from t_range_check_ref where countyid=" + l_countyid + " and kyst_innland='" + l_kyst_innland + "' AND paramid=" + p_paramid)
        #for ref_amsl in c_meta:
        if( p_paramid in param_const):
            for i in range(1,13):
                print ("i=", i)
                print ("countyid=", str(l_countyid))
                print ("kyst_innland =", str(l_kyst_innland))
                print ("paramid =", str(p_paramid))
                print("*******2 l_stnr:", l_stnr)
               
## MIN
                # Get the stationid to the reference station
                print("""select A.stationid, A.st_low FROM range_check_data A
                             where A.st_low in (
                                  select MIN(M.st_low) FROM range_check_data M
                                       WHERE M.stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND M.paramid = """ + str(p_paramid) + """
                                             AND M.month = """ + str(i) + """)
                                       AND A.paramid = """ + str(p_paramid) + """
                                       AND A.month = """ + str(i) )

                print("""select A.stnr, A.st_low FROM t_range_check_data A
                             where A.st_low in (
                                  select MIN(M.st_low) FROM t_range_check_data M
                                       WHERE M.stnr in 
                                             ( select stnr
                                               from t_range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND M.paramid = """ + str(p_paramid) + """
                                             AND M.month = """ + str(i) + """)
                                       AND A.paramid = """ + str(p_paramid) + """
                                       AND A.month = """ + str(i) )
                

                
                c_min.execute("""select A.stationid, A.st_low FROM range_check_data A
                             where A.st_low in (
                                  select MIN(M.st_low) FROM range_check_data M
                                       WHERE M.stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND M.paramid = """ + str(p_paramid) + """
                                             AND M.month = """ + str(i) + """)
                                       AND A.paramid = """ + str(p_paramid) + """
                                       AND A.month = """ + str(i) )
                            
                
                
                
                t_diff=float(-1)
                ref_amsl=float(-1)
                # t_stationid=-1
                for stationid,st_low in c_min:
                    print("stationid=",stationid,"st_low=", st_low, "*******3A0 l_stnr:", l_stnr)
                    #if more than one station is selected that with least amsl difference between l_amsl and r_amsl should be selected
                    r_amsl=amsl_dict[stationid]
                    if( r_amsl is None or r_amsl=="" ):
                        r_amsl=10
                    print("stationid=",stationid,"type_r_amsl",str(type(r_amsl)),"type_l_amsl",str(type(l_amsl)))
                    diff=abs( r_amsl - l_amsl )
                    if( t_diff < 0 ):
                        t_diff=diff
                        # t_stationid=stationid
                        ref_amsl=r_amsl
                    elif( t_diff > diff ):
                        t_diff=diff
                        # t_stationid=stationid
                        ref_amsl=r_amsl

                print("t_diff= ",t_diff)
                print("*******3AA l_stnr:", l_stnr)
                if( t_diff > 0 ):
                    print("*******3BB l_stnr:", l_stnr)
                    pconst=param_const[p_paramid]
                    calc_low ="{:.1f}".format(st_low + ( l_amsl - ref_amsl ) *  pconst)
                    print("calc_low=",calc_low)                   
                    print("""update range_check_data set edited_by=2, calc_low =""" + str(calc_low) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    
                    c_update_max.execute("""update range_check_data set edited_by=2, calc_low =""" + str(calc_low) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )

                    #print("""update range_check_data set edited_by=2, calc_low =""" + str(st_low) + """ + ( """ + str(l_amsl) + """ - """ + str(ref_amsl) + """ ) * """ 
                    #      + pconst + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    #
                    #c_update_min.execute("""update range_check_data set edited_by=2, calc_low =""" + str(st_low) + """ + ( """ + str(l_amsl) + """ - """ + str(ref_amsl) + """ ) * """ 
                    #                     + str(pconst) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    conn.commit()
                
## MAX
                # Get the stationid to the reference station
                print("""select A.stationid, A.st_high FROM range_check_data A
                             where A.st_high in (
                                  select MAX(M.st_high) FROM range_check_data M
                                       WHERE M.stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND M.paramid = """ + str(p_paramid) + """
                                             AND M.month = """ + str(i) + """)
                                       AND A.paramid = """ + str(p_paramid) + """
                                       AND A.month = """ + str(i) )

                
                c_max.execute("""select A.stationid, A.st_high FROM range_check_data A
                             where A.st_high in (
                                  select MAX(M.st_high) FROM range_check_data M
                                       WHERE M.stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND M.paramid = """ + str(p_paramid) + """
                                             AND M.month = """ + str(i) + """)
                                       AND A.paramid = """ + str(p_paramid) + """
                                       AND A.month = """ + str(i) )
                            
                
                
                
                t_diff=float(-1)
                ref_amsl=float(-1)
                # t_stationid=-1
                for stationid,st_high in c_max:
                    print("stationid=",stationid,"st_high=", st_high)
                    #if more than one station is selected that with least amsl difference between l_amsl and r_amsl should be selected
                    r_amsl=amsl_dict[stationid]
                    if( r_amsl is None or r_amsl=="" ):
                        r_amsl=10
                    diff=abs( r_amsl - l_amsl )
                    if( t_diff < 0 ):
                        t_diff=diff
                        # t_stationid=stationid
                        ref_amsl=r_amsl
                    elif( t_diff > diff ):
                        t_diff=diff
                        # t_stationid=stationid
                        ref_amsl=r_amsl

                print("t_diff= ",t_diff)
                print("*******4 l_stnr:", l_stnr)
                if( t_diff > 0 ):
                    print("*******4BB l_stnr:", l_stnr)
                    pconst=param_const[p_paramid]
                    calc_high ="{:.1f}".format(st_high + ( l_amsl - ref_amsl ) *  pconst)
                    print("calc_high=",calc_high)
                    
                    print("""update range_check_data set edited_by=2, calc_high =""" + str(calc_high) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    
                    c_update_max.execute("""update range_check_data set edited_by=2, calc_high =""" + str(calc_high) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )

                    
                    #print("""update range_check_data set edited_by=2, calc_high =""" + str(st_high) + """ + ( """ + str(l_amsl) + """ - """ + str(ref_amsl) + """ ) * """ 
                    #      + pconst + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    #
                    #c_update_max.execute("""update range_check_data set edited_by=2, calc_high =""" + str(st_high) + """ + ( """ + str(l_amsl) + """ - """ + str(ref_amsl) + """ ) * """ 
                    #                     + str(pconst) + """ where stationid =""" + str(l_stnr) + """ AND month = """ + str(i) +  """ AND paramid = """ + str(p_paramid) )
                    conn.commit()


###########################################################################################################################
#                        
#                cursor.execute("""update range_check_data d
#                                  set calc_low =
#                                     ( select MIN(st_low) + (""" + str(l_amsl) + """ - """ + str(ref_amsl) + """) * """ + param_const[p_paramid] +
#                                       """FROM range_check_data M
#                                       WHERE stationid in 
#                                             ( select stationid 
#                                               from range_check_ref
#                                               where countyid=""" + str(l_countyid) +
#                                               """ AND kyst_innland =""" +  str(l_kyst_innland) +
#                                               """ AND param_group =""" + str(p_paramid) + """)
#                                             AND paramid = """ + str(p_paramid) + """
#                                             AND month = """ + str(i) + """)
#                                   where stationid =""" + str(l_stnr) +
#                                   """AND month = """ + str(i) +                 
#                                   """AND paramid = """ + str(p_paramid) )
                    

#                    cursor.execute("""update range_check_data d
#                                  set calc_high =
#                                     ( select MAX(st_high) + (""" + str(l_amsl) + """ - """ + str(ref_amsl) + """) * """ + param_const[p_paramid] +
#                                       """FROM range_check_data M
#                                       WHERE stationid in 
#                                             ( select stationid 
#                                               from range_check_ref
#                                               where countyid=""" + str(l_countyid) +
#                                               """ AND kyst_innland =""" +  str(l_kyst_innland) +
#                                               """ AND param_group =""" + str(p_paramid) + """)
#                                             AND paramid = """ + str(p_paramid) + """
#                                             AND month = """ + str(i) + """)
#                                   where stationid =""" + str(l_stnr) +
#                                   """AND month = """ + str(i) +                 
#                                   """AND paramid = """ + str(p_paramid) )
#######################################################################################################################################################################

        else:
            if( not p_paramid in param_const):
                print("******* else 55 l_stnr:", l_stnr)
                for i in range(1,13):
                    print ("i=",i)
                    print ("countyid=", str(l_countyid))
                    print ("kyst_innland =", str(l_kyst_innland))
                    print ("paramid =", str(p_paramid))
                    c_update_min.execute("""update range_check_data d
                                  set edited_by=2, calc_low =
                                     ( select MIN(st_low) 
                                       FROM range_check_data M
                                       WHERE stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND paramid = """ + str(p_paramid) + """
                                             AND month = """ + str(i) + """)
                                   where stationid =""" + str(l_stnr) +
                                   """AND month = """ + str(i) +                 
                                   """AND paramid = """ + str(p_paramid) )
                    conn.commit()

                    c_update_min.execute("""update range_check_data d
                                  set edited_by=2, calc_high =
                                     ( select MAX(st_high)
                                       FROM range_check_data M
                                       WHERE stationid in 
                                             ( select stationid 
                                               from range_check_ref
                                               where countyid=""" + str(l_countyid) +
                                               """ AND kyst_innland ='""" +  str(l_kyst_innland) + """'
                                               AND param_group =""" + str(p_paramid) + """)
                                             AND paramid = """ + str(p_paramid) + """
                                             AND month = """ + str(i) + """)
                                   where stationid =""" + str(l_stnr) +
                                   """AND month = """ + str(i) +
                                   """AND paramid = """ + str(p_paramid) )
                    conn.commit()

c_update= conn.cursor()

c_update.execute("update range_check_data set calc_highest=calc_high + " + str(p_outer_limit) + " where paramid = " + str(p_paramid) )
conn.commit()

c_update.execute("update range_check_data set calc_lowest=calc_low - " + str(p_outer_limit) + " where paramid = " + str(p_paramid) )
conn.commit()

                
