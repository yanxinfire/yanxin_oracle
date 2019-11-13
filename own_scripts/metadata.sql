set long 50000
select dbms_metadata.get_ddl(upper(trim('&TYPE')),upper(trim('&OBJ')),upper(trim('&OWNER'))) from dual;
