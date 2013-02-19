spool RANGE_CHECK.lst;
col HIGHEST form 9990.9;
col HIGH form 9990.9;
col LOW form 9990.9;
col LOWEST form 9990.9;
col CALC_HIGHEST form 9990.9;
col CALC_HIGH form 9990.9;
col CALC_LOW form 9990.9;
col CALC_LOWEST form 9990.9;
set heading off;
set ECHO OFF;
SET TRIMSPOOL ON;
SET FEEDBACK  OFF;
set space 1 lines 500;
select STNR,'|',PARAMID,'|',XLEVEL,'|',MONTH,'|',HIGHEST,'|',HIGH,'|',LOW,'|',LOWEST,'|',CALC_HIGHEST,'|',CALC_HIGH,'|',CALC_LOW,'|',CALC_LOWEST
from t_grensev_data;
spool off;
