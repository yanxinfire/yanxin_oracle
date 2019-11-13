set lines 200
set pagesize 5000
col username for a10
col osuser for a10
col machine for a10
col module for a12
col client_info for a14
col program for a30
col tablespace for a12
SELECT vt.inst_id,
vs.sid,
vs.serial#,
vs.username,
vs.osuser,
vs.machine,
vs.saddr,
vs.client_info,
vs.program,
vs.module,
vs.logon_time,
vt.tablespace,
vt.SQL_ID_TEMPSEG,
vt.segtype
FROM gv$session vs,
(SELECT inst_id,
tablespace,
username,
session_addr,
segtype,
SQL_ID_TEMPSEG,
ROUND(SUM(blocks) * 8192 / 1024 / 1024 / 1024, 2) tempseg_usage
FROM gv$tempseg_usage
GROUP BY inst_id, username, session_addr, segtype,tablespace,SQL_ID_TEMPSEG
ORDER BY 4 DESC) vt
WHERE vs.inst_id = vt.inst_id
AND vs.saddr = vt.session_addr
order by tempseg_usage desc;

