var B varchar2(8)
exec :B:='&DBA'
select dbms_utility.data_block_address_file(to_number(:B,'xxxxxxxxxxxxxxxx')) file#,dbms_utility.data_block_address_block(to_number(:B,'xxxxxxxxxxxxxxxx')) block# from dual;