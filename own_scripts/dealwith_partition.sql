declare
  TYPE scopeList IS TABLE OF varchar2(100);
  scopeLists scopeList;
  v_sql      varchar2(1000);
  v_partName varchar2(20);
begin
  select high_value
    bulk collect
    into scopeLists
    from dba_tab_partitions
   where table_name = 'TEST_PART_DAY';
  for i in scopeLists.first .. scopeLists.last loop
    v_sql := 'select ''PART_''||to_char(' || scopeLists(i) || ',''yyyymmdd'') part_name from dual';
    execute IMMEDIATE v_sql into v_partName;
    dbms_output.put_line(v_partName);
  end loop;
end;
/


create table test_part_day(insert_time date)
PARTITION BY RANGE (insert_time) INTERVAL (NUMTODSINTERVAL(1, 'day'))
(partition part_t01 values less than(to_date('2019-09-05', 'yyyy-mm-dd')));


SQL> insert into test_part_day values(sysdate+1);
1 row created.
SQL> insert into test_part_day values(sysdate+2);
1 row created.
SQL> insert into test_part_day values(sysdate+3);
1 row created.
SQL> commit;
Commit complete.





分区表修改分区名
declare
  l_str varchar2(8);
begin
    for x in (select distinct partition_name from user_tab_partitions where table_name='T_DW_XA_GLOG_SHOPTRADE' and partition_name like  'SYS%')
loop
      execute immediate
              'select distinct to_char(logtime,''yyyymmdd'') from t_dw_xa_glog_shoptrade partition('||x.partition_name||')' into l_str;
      execute immediate
         'alter table t_dw_xa_glog_shoptrade rename partition "'||x.partition_name ||'" to "'||'P'||l_str||'"';
      end loop;
    end;
/



TRUNCATE分区表分区：

create or replace procedure clean_history(v_tabOwner  varchar2,
                                          v_tabName   varchar2,
                                          v_beginDate varchar2,
                                          v_endDate   varchar2) AUTHID CURRENT_USER IS
  TYPE partRecord is record(
    part_name  varchar2(100),
    position   varchar2(10),
    date_scope varchar2(100));
  TYPE scopeList IS TABLE OF partRecord;
  scopeLists  scopeList;
  v_partDate  date;
  v_sql       varchar2(1000);
  v_trunc_sql varchar2(1000);
  v_partList  varchar2(1000);
  v_sql_check varchar2(4000);
begin
  dbms_output.put_line('
  
  
  ');
  select partition_name, partition_position, high_value
    bulk collect
    into scopeLists
    from dba_tab_partitions
   where table_name = upper(v_tabName)
     and table_owner = upper(v_tabOwner);
  for i in scopeLists.first .. scopeLists.last loop
    v_sql := 'select ' || scopeLists(i).date_scope ||
             ' part_name from dual';
    execute IMMEDIATE v_sql
      into v_partDate;
    IF v_partDate > to_date(v_beginDate, 'yyyymmdd') and
       v_partDate <= to_date(v_endDate, 'yyyymmdd') + 1 THEN
      v_partList  := v_partList || scopeLists(i).position || ',';
      v_trunc_sql := 'alter table ' || upper(v_tabOwner) || '.' ||
                     upper(v_tabName) || ' truncate partition ' || scopeLists(i)
                    .part_name || ';';
      dbms_output.put_line(v_trunc_sql);
    END IF;
  end loop;
  dbms_output.put_line('
  
  
  ');
  dbms_output.put_line('/*--------------------------------------------- ');
  dbms_output.put_line('The following SQL is for checking whether the partition has been selected is correct!!!');
  dbms_output.put_line('如下SQL用于确认所要清除的分区是否选择正确！！！');
  dbms_output.put_line('---------------------------------------------*/');
  dbms_output.put_line('set lines 200 pagesize 5000');
  dbms_output.put_line('col partition_name for a20');
  dbms_output.put_line('col high_value for a90');
  dbms_output.put_line('col tablespace_name for a30');
  v_sql_check := 'select partition_name,high_value,tablespace_name from dba_tab_partitions  where table_owner=''' ||
                 upper(v_tabOwner) || ''' and table_name=''' ||
                 upper(v_tabName) || ''' and partition_position in (' ||
                 substr(v_partList, 1, length(v_partList) - 1) || ');';
  dbms_output.put_line(v_sql_check);

end;
/

