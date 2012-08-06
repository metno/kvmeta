spool on
spool RANGE_CHECK.lst
set heading off
set ECHO OFF
SET TRIMSPOOL ON
SET FEEDBACK  OFF
set space 1 lines 500
select STNR||','||PARAMID||','||XLEVEL||','||MONTH||','||HIGHEST||','||HIGH||','||LOW||','||LOWEST||','||CALC_HIGHEST||','||CALC_HIGH||','||CALC_LOW||','||CALC_LOWEST
from t_grensev_data;
spool off

