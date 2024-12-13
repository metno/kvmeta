spool on
spool KV2KLIMA_PARAM_FILTER.lst
set heading off
set ECHO OFF
SET TRIMSPOOL ON
SET FEEDBACK  OFF
set space 1 lines 500
select STNR||'|'||TYPEID||'|'||PARAMID||'|'||SENSOR||'|'||XLEVEL||'|'||to_char(FDATO,'YYYY-MM-DD HH24:MI:SS')||'|'||to_char(TDATO,'YYYY-MM-DD HH24:MI:SS')||'|'||to_char(AUDIT_DATO,'YYYY-MM-DD HH24:MI:SS')
from T_KV2KLIMA_PARAM_FILTER;
spool off
