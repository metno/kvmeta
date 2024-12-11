spool on
spool GRENSEV_ST_CAT.lst
set heading off
set ECHO OFF
SET TRIMSPOOL ON
SET FEEDBACK  OFF
set space 1 lines 500
select STNR||'|'||PARAMID||'|'||KYST_INNLAND||'|'||COUNTYID||'|'||to_char(FDATO,'YYYY-MM-DD HH24:MI:SS')||'|'||to_char(TDATO,'YYYY-MM-DD HH24:MI:SS')||'|'||NAME||'|'||ST_GROUP||'|'||to_char(EDIT_DATO,'YYYY-MM-DD HH24:MI:SS')
from T_GRENSEV_ST_CAT;
spool off
