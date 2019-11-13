set lines 200
set pages 5000
set verify off
column uservar new_value Table_Owner noprint
select upper('&owner') uservar from dual
/
column tabvar new_value Table_Name noprint
select upper('&tname') tabvar from dual
/
column wherevar new_value where noprint
select upper('&predicate') wherevar from dual
/
column tabvar new_value Table_Name noprint
select dbms_rowid.ROWID_OBJECT(rowid) obj#,
       dbms_rowid.rowid_to_ABSOLUTE_fno(rowid,'&Table_Owner','&Table_Name') file#,
       dbms_rowid.rowid_block_number(rowid) block#,
       dbms_rowid.rowid_row_number(rowid) row#
  from &Table_Owner..&Table_Name &where
/

