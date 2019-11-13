set long 10000000
set longchunksize 10000000
set linesize 200
set pagesize 5000
select dbms_sqltune.report_sql_monitor from dual;