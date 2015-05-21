spool on
spool RANGE_PARAM_GROUPS.lst
set heading off
set ECHO OFF
SET TRIMSPOOL ON
SET FEEDBACK  OFF
set space 1 lines 500
select PARAMID||','||G_PARAMID
from T_RANGE_CHECK_PARAM_GROUP;
spool off
