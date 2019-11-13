create or replace procedure migrate_table_big_sql(l_number number)
is
  l_owner              VARCHAR2(30);
  l_tablename          VARCHAR2(40);
  l_table_sql_filename VARCHAR2(30);
  l_sql                VARCHAR2(1000);
BEGIN
  FOR c_table IN (SELECT * FROM SYSTEM.migrate_table_big@to_old) LOOP
      FOR c_table_rowid IN (SELECT /*+LEADING(@"SEL$20" "F"@"SEL$20" "DS"@"SEL$20" "E"@"SEL$20") USE_NL(@"SEL$20" "E"@"SEL$20")*/
                                         'where rowid between ''' || dbms_rowid.rowid_create(1, oid1, fid1, bid1, 0)
                                         || ''' and ''' ||  dbms_rowid.rowid_create(1, oid2, fid2, bid2, 9999)
                                         || '''' || ' ;' as "TABLE_ROWID"
                                     FROM
                                         (  SELECT distinct
                                                  chunk_no,
                                                  FIRST_VALUE(data_object_id) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) oid1,
                                                  LAST_VALUE(data_object_id) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) oid2,
                                                  FIRST_VALUE(relative_fno) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) fid1,
                                                  LAST_VALUE(relative_fno) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) fid2,
                                                  FIRST_VALUE(block_id) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) bid1,
                                                  LAST_VALUE(block_id + blocks - 1) OVER(
                                                      PARTITION BY chunk_no
                                                      ORDER BY
                                                          data_object_id, relative_fno, block_id
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  ) bid2
                                              FROM
                                                  (
                                                      SELECT /*+ rule */
                                                          data_object_id,
                                                          relative_fno,
                                                          block_id,
                                                          blocks,
                                                          ceil(sum2 / chunk_size) chunk_no
                                                      FROM
                                                          (
                                                              SELECT
                                                                  b.data_object_id,
                                                                  a.relative_fno,
                                                                  a.block_id,
                                                                  a.blocks,
                                                                  SUM(a.blocks) OVER(
                                                                  ORDER BY
                                                                      b.data_object_id, a.relative_fno, a.block_id
                                                                  ) sum2,
                                                                  ceil(SUM(a.blocks) OVER() / l_number) chunk_size
                                                              FROM
                                                                  dba_extents@to_old a,
                                                                  dba_objects@to_old b
                                                              WHERE
                                                                  a.owner = b.owner
                                                                  AND a.segment_name = b.object_name
                                                                  AND nvl(a.partition_name, '-1') = nvl(b.subobject_name, '-1')
                                                                  AND b.data_object_id IS NOT NULL
                                                                  AND a.owner = UPPER(c_table.owner)
                                                                  AND a.segment_name =UPPER(c_table.table_name)
                                                          )
                                                  )
                                         )) LOOP
        l_sql := 'insert into ' || c_table.owner||'.'||c_table.table_name||
                 ' select * from ' || c_table.owner || '.' ||
                 c_table.table_name || '@to_old a ' ||
                 c_table_rowid.table_rowid;
        DBMS_OUTPUT.put_line(l_sql);
      END LOOP;
  END LOOP;
END;
/