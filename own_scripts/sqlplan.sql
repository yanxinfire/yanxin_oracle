select * from table(dbms_xplan.display_cursor(null,null,'advanced allstats peeked_binds'));
