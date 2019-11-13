col name for a50
col describ for a100
col value for a10
set lines 200
SELECT x.ksppinm NAME, y.ksppstvl VALUE, x.ksppdesc describ
  FROM SYS.x$ksppi x,SYS.x$ksppcv y
 WHERE x.inst_id = USERENV ('Instance')
   AND y.inst_id = USERENV ('Instance')
   AND x.indx = y.indx
   AND x.ksppinm LIKE '%&par%'
   /