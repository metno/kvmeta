spool on
spool T_KC.lst
set heading off
set ECHO OFF
SET TRIMSPOOL ON
SET FEEDBACK  OFF
set space 1 lines 500
select STNR||','||ELEM_CODE||','||FYEAR||','||FMONTH||','||TYEAR ||','||TMONTH ||','||JAN ||','||FEB ||','||MAR ||','||APR||','||MAY||','||JUN||','||JUL||','||AUG||','||SEP||','||OCT||','||NOV ||','||DEC||','||TO_CHAR(FDATO,'YYYY-MM-DD')||','||TO_CHAR(TDATO,'YYYY-MM-DD') from T_KC;
spool off

